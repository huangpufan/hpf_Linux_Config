#!/usr/bin/env bash
# ssot-lint.sh — 项目 SSOT 一致性的确定性校验脚本
#
# 用途：把 Doctor L1 中可机械判断的项从 Agent 自律改为脚本自动化，
#       消除高频低收益的人工检查负担。
#
# 适用对象：包含 SSOT/ 目录的项目仓库。
# 不适用：纯协议项目本身（如 SSOT-SKILL 仓库）。
#
# 用法：
#   ./ssot-lint.sh [SSOT_DIR]        # 默认 SSOT_DIR = ./SSOT
#   ./ssot-lint.sh --json            # 输出结构化 JSON（CI 友好）
#   ./ssot-lint.sh --strict          # 把 WARN 也视为 FAIL（CI gate 模式）
#
# 退出码：
#   0  PASS（无 FAIL，无 WARN）
#   1  WARN（无 FAIL，有 WARN；strict 模式视为 FAIL）
#   2  FAIL（有 FAIL）
#   3  脚本本身错误（参数错误、SSOT 目录不存在等）
#
# 设计原则：
#   - 只做确定性检查（grep / 路径存在性 / git ancestry），不做语义判断。
#   - 不调用任何外部 LLM / 网络服务。
#   - 不修改任何文件；只输出诊断结果。
#   - 失败信息必须给出具体路径和行号（如果适用），便于 Agent / 人定位。

set -euo pipefail

# ---------- 参数解析 ----------
SSOT_DIR="${1:-SSOT}"
OUTPUT_FORMAT="text"
STRICT_MODE=0

for arg in "$@"; do
  case "$arg" in
    --json) OUTPUT_FORMAT="json" ;;
    --strict) STRICT_MODE=1 ;;
    --help|-h)
      sed -n '2,28p' "$0"
      exit 0
      ;;
  esac
done

# 第一个非 flag 参数若是目录则覆盖 SSOT_DIR
for arg in "$@"; do
  if [[ "$arg" != --* && -d "$arg" ]]; then
    SSOT_DIR="$arg"
    break
  fi
done

if [[ ! -d "$SSOT_DIR" ]]; then
  echo "ERROR: SSOT 目录不存在: $SSOT_DIR" >&2
  exit 3
fi

# ---------- 诊断收集 ----------
declare -a FAILS=()
declare -a WARNS=()
declare -a PASSES=()

add_fail() { FAILS+=("$1"); }
add_warn() { WARNS+=("$1"); }
add_pass() { PASSES+=("$1"); }

# 内容 hash（前 12 位），跨平台兼容 sha256sum / shasum；都不可用时退化为 cksum
ssot_hash() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -c1-12
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -c1-12
  else
    cksum "$1" | awk '{print $1}'
  fi
}

# ---------- 检查 1：STATUS.md 必需字段 ----------
STATUS_FILE="$SSOT_DIR/STATUS.md"
if [[ ! -f "$STATUS_FILE" ]]; then
  add_fail "STATUS.md 缺失: $STATUS_FILE"
else
  for field in "tracked_commit" "documentation_language" "documentation_language_evidence" "coverage_result"; do
    if ! grep -qE "(\|\s*$field\s*\||^$field:|^- \*\*$field\*\*)" "$STATUS_FILE"; then
      add_fail "STATUS.md 缺少必需字段: $field"
    fi
  done
  if grep -qE "\|\s*tracked_commit\s*\|" "$STATUS_FILE"; then
    add_pass "STATUS.md 必需字段完整"
  fi
fi

# ---------- 检查 2：tracked_commit 是 HEAD 祖先 ----------
if [[ -f "$STATUS_FILE" ]] && command -v git >/dev/null 2>&1; then
  TRACKED_COMMIT=$(grep -oE '`[0-9a-f]{7,40}`' "$STATUS_FILE" | head -n 1 | tr -d '`' || true)
  if [[ -n "$TRACKED_COMMIT" ]]; then
    if git -C "$(dirname "$SSOT_DIR")" cat-file -e "$TRACKED_COMMIT" 2>/dev/null; then
      HEAD_SHA=$(git -C "$(dirname "$SSOT_DIR")" rev-parse HEAD)
      if git -C "$(dirname "$SSOT_DIR")" merge-base --is-ancestor "$TRACKED_COMMIT" "$HEAD_SHA" 2>/dev/null; then
        DRIFT=$(git -C "$(dirname "$SSOT_DIR")" rev-list "$TRACKED_COMMIT..$HEAD_SHA" --count 2>/dev/null || echo 0)
        if [[ "$DRIFT" -gt 50 ]]; then
          add_warn "tracked_commit 落后 HEAD $DRIFT 个 commit（> 50 阈值）；建议进入 commit-audit 或更新 tracked_commit"
        else
          add_pass "tracked_commit 是 HEAD 祖先，漂移 $DRIFT 个 commit"
        fi

        # 如果声明 converged 但漂移大于 0，警告
        if grep -qE "coverage_result\s*\|\s*\`?converged\`?" "$STATUS_FILE" && [[ "$DRIFT" -gt 0 ]]; then
          add_fail "coverage_result=converged 但 tracked_commit 落后 HEAD $DRIFT 个 commit；converged 是停止结论，应先重新审查"
        fi
      else
        add_fail "tracked_commit ($TRACKED_COMMIT) 不是当前 HEAD 的祖先；可能已被 rebase/reset"
      fi
    else
      add_fail "tracked_commit ($TRACKED_COMMIT) 在 git 历史中不存在"
    fi
  else
    add_warn "无法从 STATUS.md 解析 tracked_commit SHA"
  fi
fi

# ---------- 检查 3：SSOT 内部 markdown 链接有效性 ----------
LINK_FAIL_COUNT=0
while IFS= read -r -d '' md_file; do
  # 提取 markdown 中的相对路径链接：[label](./path) 或 [label](../path) 或 [label](path.md)
  while IFS= read -r link; do
    # 去除 anchor 部分（#section）
    target_path="${link%#*}"
    # 跳过外部链接和邮件
    [[ "$target_path" =~ ^https?:// ]] && continue
    [[ "$target_path" =~ ^mailto: ]] && continue
    [[ -z "$target_path" ]] && continue
    # 相对于当前 markdown 文件所在目录解析
    md_dir=$(dirname "$md_file")
    resolved="$md_dir/$target_path"
    # 规范化路径（去除 ./ 和 ../）
    resolved_canonical=$(cd "$(dirname "$resolved")" 2>/dev/null && pwd -P)/$(basename "$resolved") || resolved_canonical=""
    if [[ -n "$resolved_canonical" && ! -e "$resolved_canonical" ]] && [[ ! -e "$resolved" ]]; then
      add_fail "失效内部链接: $md_file -> $target_path"
      LINK_FAIL_COUNT=$((LINK_FAIL_COUNT + 1))
      [[ "$LINK_FAIL_COUNT" -ge 20 ]] && break 2  # 限制输出量
    fi
  done < <(grep -oE '\]\([^)]+\)' "$md_file" | sed -E 's/^\]\(([^)]+)\)$/\1/' | grep -vE '^https?://|^mailto:|^#')
done < <(find "$SSOT_DIR" -name '*.md' -type f -print0)

if [[ "$LINK_FAIL_COUNT" -eq 0 ]]; then
  add_pass "SSOT 内部链接全部有效"
elif [[ "$LINK_FAIL_COUNT" -ge 20 ]]; then
  add_fail "失效链接数已达限制 20，可能还有更多"
fi

# ---------- 检查 4：bug/tech-debt frontmatter ----------
for entry_dir in "bugs" "tech-debt"; do
  if [[ -d "$SSOT_DIR/$entry_dir" ]]; then
    missing_count=0
    while IFS= read -r -d '' entry_file; do
      filename=$(basename "$entry_file")
      # README.md 不要求 frontmatter
      [[ "$filename" == "README.md" ]] && continue
      # 只检查带数字前缀的条目文件
      [[ ! "$filename" =~ ^[0-9]{4}-.+\.md$ ]] && continue
      # 检查文件前 3 行是否包含 YAML frontmatter 起始 ---
      if ! head -n 3 "$entry_file" | grep -qE '^---$'; then
        add_warn "$entry_dir 条目缺少 YAML frontmatter: $entry_file"
        missing_count=$((missing_count + 1))
      fi
    done < <(find "$SSOT_DIR/$entry_dir" -name '*.md' -type f -print0)
    if [[ "$missing_count" -eq 0 ]]; then
      add_pass "$entry_dir 条目 frontmatter 完整"
    fi
  fi
done

# ---------- 检查 5：STATUS.md 备注列禁止冗余检查（v2.12） ----------
if [[ -f "$STATUS_FILE" ]]; then
  # 检测备注列是否含明显的计数表达：N 个 active、N 条、N 个 deb
  REDUNDANT_PATTERNS=(
    "[0-9]+ 个 active"
    "[0-9]+ 个 \`active\`"
    "[0-9]+ 条 active"
    "[0-9]+ 个 long.?term bug"
    "[0-9]+ 个长期 bug"
    "[0-9]+ 个 gotcha"
    "[0-9]+ 个 ADR"
    "[0-9]+ active.*[0-9]+ resolved"
  )
  found_redundant=0
  for pattern in "${REDUNDANT_PATTERNS[@]}"; do
    if grep -qE "$pattern" "$STATUS_FILE"; then
      found_redundant=1
      break
    fi
  done
  if [[ "$found_redundant" -eq 1 ]]; then
    add_warn "STATUS.md 区域备注列疑似维护计数信息（v2.12 禁止）；应改为指向子目录 README 的指针"
  else
    add_pass "STATUS.md 备注列无明显计数冗余"
  fi
fi

# ---------- 检查 6：confidence: hypothesis 不得出现在 architecture/ 正文（v2.13） ----------
# 依据 knowledge-integrity.md §1：hypothesis 只能写 gotchas / STATUS.md 开放缺口。
# candidate 在 architecture 的 gap/unknown 注释中可合法存在（需语义判断），留给 Doctor L2，此处不查。
ARCH_DIR="$SSOT_DIR/architecture"
if [[ -d "$ARCH_DIR" ]]; then
  hyp_hits=0
  while IFS= read -r -d '' arch_file; do
    if grep -qE 'confidence:[[:space:]]*hypothesis' "$arch_file"; then
      add_fail "architecture 正文出现 confidence: hypothesis（应迁移到 gotchas 或 STATUS.md 开放缺口）: $arch_file"
      hyp_hits=$((hyp_hits + 1))
    fi
  done < <(find "$ARCH_DIR" -name '*.md' -type f -print0)
  if [[ "$hyp_hits" -eq 0 ]]; then
    add_pass "architecture 正文无 confidence: hypothesis"
  fi
fi

# ---------- 检查 7：SSOT-generated 薄适配器 marker 与体积（v2.13 / v2.17 划界） ----------
# 启动参考文件位于仓库根（SSOT_DIR 的父目录），不在 SSOT/ 内。
# 只有带 SSOT-generated marker 的文件属于生成型薄适配器，接受 [ADAPTER] 形态检查。
# 无 marker 的手写 / mixed 启动文件不因缺 marker 报 ADAPTER；其 SSOT 路由走检查 9，事实正确性走 CORE-REF。
REPO_ROOT=$(dirname "$SSOT_DIR")
ADAPTER_MARKER='<!-- SSOT-generated'
declare -a STARTUP_REF_FILES=()
declare -a GENERATED_ADAPTER_FILES=()
for ref_name in "AGENTS.md" "CLAUDE.md" "GEMINI.md"; do
  [[ -f "$REPO_ROOT/$ref_name" ]] && STARTUP_REF_FILES+=("$REPO_ROOT/$ref_name")
done
if [[ -d "$REPO_ROOT/.cursor/rules" ]]; then
  while IFS= read -r -d '' cf; do
    STARTUP_REF_FILES+=("$cf")
  done < <(find "$REPO_ROOT/.cursor/rules" -maxdepth 1 -type f \( -name '*.md' -o -name '*.mdc' \) -print0)
fi
if [[ -d "$REPO_ROOT/.windsurf/rules" ]]; then
  while IFS= read -r -d '' wf; do
    STARTUP_REF_FILES+=("$wf")
  done < <(find "$REPO_ROOT/.windsurf/rules" -maxdepth 1 -type f -print0)
fi

for sf in "${STARTUP_REF_FILES[@]}"; do
  if head -n 3 "$sf" | grep -qF "$ADAPTER_MARKER"; then
    GENERATED_ADAPTER_FILES+=("$sf")
  fi
done

if [[ "${#GENERATED_ADAPTER_FILES[@]}" -gt 0 ]]; then
  adapter_issue=0
  for af in "${GENERATED_ADAPTER_FILES[@]}"; do
    lines=$(wc -l < "$af" | tr -d ' ')
    if [[ "$lines" -gt 50 ]]; then
      add_warn "SSOT-generated 薄适配器超过 50 行（应精简为路由 + 核心不变量）: $af（$lines 行）"
      adapter_issue=$((adapter_issue + 1))
    fi
    # 若声明了 SSOT 源 hash 行，校验源文件是否漂移（v2.13）。未声明则跳过，不强制。
    src_line=$(grep -m1 '<!-- SSOT-source:' "$af" || true)
    if [[ -n "$src_line" ]]; then
      refs=$(printf '%s' "$src_line" | sed -E 's/^.*SSOT-source:[[:space:]]*//; s/[[:space:]]*-->.*$//')
      for ref in $refs; do
        [[ "$ref" != *@* ]] && continue
        src_path="${ref%@*}"
        declared_hash="${ref##*@}"
        abs_src="$REPO_ROOT/$src_path"
        if [[ ! -f "$abs_src" ]]; then
          add_warn "SSOT-generated 薄适配器引用的 SSOT 源文件不存在: $src_path（$af）"
          adapter_issue=$((adapter_issue + 1))
        elif [[ "$(ssot_hash "$abs_src")" != "$declared_hash" ]]; then
          add_warn "SSOT-generated 薄适配器源文件已变更，可能需重新生成: $src_path（$af）"
          adapter_issue=$((adapter_issue + 1))
        fi
      done
    fi
  done
  if [[ "$adapter_issue" -eq 0 ]]; then
    add_pass "SSOT-generated 薄适配器 marker 与体积合规"
  fi
fi

# ---------- 检查 8：evidence 符号锚复核（v2.13） ----------
# 解析 confidence frontmatter 的 evidence 中 path#symbol 锚，校验路径与符号是否仍存在。
# evidence 是自由文本，这里只处理形如 path#symbol 的锚，行号式旧指针不在此检查（向后兼容）。
ptr_stale=0
while IFS= read -r -d '' md_file; do
  while IFS= read -r anchor; do
    a_path="${anchor%#*}"
    a_sym="${anchor#*#}"
    abs_a="$REPO_ROOT/$a_path"
    if [[ ! -f "$abs_a" ]]; then
      add_warn "[STALE] evidence 路径不存在: $a_path（$md_file）"
      ptr_stale=$((ptr_stale + 1))
    elif ! grep -qF "$a_sym" "$abs_a"; then
      add_warn "[STALE] evidence 符号未找到: $a_path#$a_sym（$md_file）"
      ptr_stale=$((ptr_stale + 1))
    fi
    [[ "$ptr_stale" -ge 20 ]] && break 2
  done < <(grep -oE 'evidence:[[:space:]]*"?[A-Za-z0-9_./-]+#[A-Za-z0-9_]+' "$md_file" 2>/dev/null | grep -oE '[A-Za-z0-9_./-]+#[A-Za-z0-9_]+' || true)
done < <(find "$SSOT_DIR" -name '*.md' -type f -print0)
if [[ "$ptr_stale" -eq 0 ]]; then
  add_pass "evidence 符号锚复核通过（或无符号锚）"
fi

# ---------- 检查 9：消费链路（v2.13） ----------
# 验证 SSOT 是否真会被 Agent 读到：启动参考文件是否路由到 SSOT / $ssot-*，README 导航入口是否存在。
# 行为层探针（L4：fresh-context agent 是否真用 SSOT）属语义判断，不在脚本内做，由 references/consumption-audit.md 承载。
consumption_issue=0
if [[ "${#STARTUP_REF_FILES[@]}" -gt 0 ]]; then
  routed=0
  for sf in "${STARTUP_REF_FILES[@]}"; do
    if grep -qE 'SSOT/|\$ssot-' "$sf"; then routed=1; fi
  done
  if [[ "$routed" -eq 0 ]]; then
    add_warn "[CONSUMPTION] 存在启动参考文件但无一指向 SSOT/ 或 \$ssot-*，Agent 可能不会读取 SSOT"
    consumption_issue=$((consumption_issue + 1))
  fi
fi
if [[ ! -f "$SSOT_DIR/README.md" ]]; then
  add_warn "[CONSUMPTION] 缺少 SSOT/README.md 导航入口，读取路由无落点"
  consumption_issue=$((consumption_issue + 1))
fi
if [[ "$consumption_issue" -eq 0 ]]; then
  add_pass "消费链路检查通过"
fi

# ---------- 输出 ----------
fail_count=${#FAILS[@]}
warn_count=${#WARNS[@]}
pass_count=${#PASSES[@]}

if [[ "$OUTPUT_FORMAT" == "json" ]]; then
  printf '{\n'
  printf '  "ssot_dir": "%s",\n' "$SSOT_DIR"
  printf '  "summary": { "pass": %d, "warn": %d, "fail": %d },\n' "$pass_count" "$warn_count" "$fail_count"
  printf '  "fails": ['
  for i in "${!FAILS[@]}"; do
    [[ $i -gt 0 ]] && printf ','
    printf '\n    %s' "$(printf '%s' "${FAILS[$i]}" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || printf '"%s"' "${FAILS[$i]}")"
  done
  printf '\n  ],\n  "warns": ['
  for i in "${!WARNS[@]}"; do
    [[ $i -gt 0 ]] && printf ','
    printf '\n    %s' "$(printf '%s' "${WARNS[$i]}" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || printf '"%s"' "${WARNS[$i]}")"
  done
  printf '\n  ]\n}\n'
else
  echo "===== SSOT Lint: $SSOT_DIR ====="
  if [[ "$pass_count" -gt 0 ]]; then
    echo ""
    echo "[PASS] $pass_count 项"
    for msg in "${PASSES[@]}"; do echo "  - $msg"; done
  fi
  if [[ "$warn_count" -gt 0 ]]; then
    echo ""
    echo "[WARN] $warn_count 项"
    for msg in "${WARNS[@]}"; do echo "  - $msg"; done
  fi
  if [[ "$fail_count" -gt 0 ]]; then
    echo ""
    echo "[FAIL] $fail_count 项"
    for msg in "${FAILS[@]}"; do echo "  - $msg"; done
  fi
  echo ""
  echo "===== 汇总：PASS=$pass_count WARN=$warn_count FAIL=$fail_count ====="
fi

# 退出码
if [[ "$fail_count" -gt 0 ]]; then
  exit 2
elif [[ "$warn_count" -gt 0 ]]; then
  if [[ "$STRICT_MODE" -eq 1 ]]; then
    exit 2
  else
    exit 1
  fi
else
  exit 0
fi
