#!/usr/bin/env bash
# run-tests.sh — ssot-lint.sh 冒烟测试
#
# 设计：不在磁盘留 fixture 文件，运行时用 mktemp 构造最小 SSOT 场景，
#       断言关键输出与退出码。自包含、易读，覆盖 v2.13 检查 6/7/8/9、
#       v2.17 handwritten vs SSOT-generated adapter 边界 + clean 基线。
#
# 用法：bash assets/scripts/test/run-tests.sh
# 退出码：0 全部通过；1 有失败。
set -uo pipefail

LINT="$(cd "$(dirname "$0")/.." && pwd)/ssot-lint.sh"
DOCTOR_SKILL="$(cd "$(dirname "$0")/../../.." && pwd)"
SKILLS_DIR="$(cd "$DOCTOR_SKILL/.." && pwd)"
PASS=0
FAIL=0

# 与 ssot-lint.sh 的 ssot_hash 保持一致（测试环境假定有 sha256sum）
thash() { sha256sum "$1" | cut -c1-12; }

assert_contains() { # desc out needle
  if printf '%s' "$2" | grep -qF "$3"; then echo "  ok   : $1"; PASS=$((PASS + 1));
  else echo "  FAIL : $1（输出未包含: $3）"; FAIL=$((FAIL + 1)); fi
}
assert_not_contains() { # desc out needle
  if printf '%s' "$2" | grep -qF "$3"; then echo "  FAIL : $1（输出不应包含: $3）"; FAIL=$((FAIL + 1));
  else echo "  ok   : $1"; PASS=$((PASS + 1)); fi
}
assert_exit() { # desc actual expected
  if [[ "$2" == "$3" ]]; then echo "  ok   : $1"; PASS=$((PASS + 1));
  else echo "  FAIL : $1（退出码 $2 != $3）"; FAIL=$((FAIL + 1)); fi
}
assert_file() { # desc path
  if [[ -f "$2" ]]; then echo "  ok   : $1"; PASS=$((PASS + 1));
  else echo "  FAIL : $1（缺少文件: $2）"; FAIL=$((FAIL + 1)); fi
}

make_base() { # $1=root —— 构造一个干净、应全 PASS 的最小 SSOT 项目（git 仓库）
  local r="$1"
  mkdir -p "$r/SSOT/architecture" "$r/SSOT/gotchas" "$r/src"
  printf '# SSOT 导航\n\n- [architecture](architecture/README.md)\n' > "$r/SSOT/README.md"
  printf '# 架构\n\n核心不变量：请求必须经过鉴权。\n' > "$r/SSOT/architecture/README.md"
  printf '# 陷阱索引\n\n- [0001](0001-x.md)\n' > "$r/SSOT/gotchas/README.md"
  printf -- '---\nconfidence: candidate\nsource: code-analysis\ndiscovered_at: 2026-05-29\nevidence: "src/foo.ts#barFunc"\n---\n# 陷阱 X\n' > "$r/SSOT/gotchas/0001-x.md"
  printf 'export function barFunc() { return 1 }\n' > "$r/src/foo.ts"
  printf '| tracked_commit | `PLACEHOLDER` |\n| documentation_language | 中文 |\n| documentation_language_evidence | README |\n| coverage_result | in_progress |\n' > "$r/SSOT/STATUS.md"
  git -C "$r" init -q
  git -C "$r" add -A >/dev/null 2>&1
  git -C "$r" -c user.email=t@t.t -c user.name=t commit -qm init >/dev/null 2>&1
  local head
  head=$(git -C "$r" rev-parse HEAD)
  sed -i "s/PLACEHOLDER/$head/" "$r/SSOT/STATUS.md"
}

add_clean_adapter() { # $1=root —— 带 marker + 正确 source hash + SSOT 路由的薄适配器
  local r="$1" ha
  ha=$(thash "$r/SSOT/architecture/README.md")
  {
    printf '<!-- SSOT-generated | generated_at: 2026-05-29 -->\n'
    printf '<!-- SSOT-source: SSOT/architecture/README.md@%s -->\n' "$ha"
    printf '<!-- 本文件由 SSOT 生成 -->\n\n'
    printf '# proj\n\n开始任何任务前先读 SSOT/STATUS.md。\n'
  } > "$r/AGENTS.md"
}

run() { bash "$LINT" "$1/SSOT" 2>&1; }

echo "== S0 bundle package shape（每个 skill 有 SKILL.md + agents/openai.yaml） =="
for skill in ssot-preflight ssot-bootstrap ssot-closeout ssot-audit ssot-doctor ssot-skill; do
  assert_file "$skill has SKILL.md" "$SKILLS_DIR/$skill/SKILL.md"
  assert_file "$skill has agents/openai.yaml" "$SKILLS_DIR/$skill/agents/openai.yaml"
done

echo "== S1 clean（应全 PASS，退出 0） =="
T=$(mktemp -d); make_base "$T"; add_clean_adapter "$T"
out=$(run "$T"); code=$?
assert_exit "clean 退出 0" "$code" "0"
assert_not_contains "clean 无 FAIL" "$out" "[FAIL]"
assert_not_contains "clean 无 WARN" "$out" "[WARN]"
rm -rf "$T"

echo "== S2 architecture 正文含 hypothesis（检查 6 → FAIL） =="
T=$(mktemp -d); make_base "$T"
printf '\nconfidence: hypothesis\n' >> "$T/SSOT/architecture/README.md"
out=$(run "$T"); code=$?
assert_contains "hypothesis 触发 FAIL" "$out" "confidence: hypothesis"
assert_exit "hypothesis 退出 2" "$code" "2"
rm -rf "$T"

echo "== S3 手写 AGENTS 带 SSOT 路由（不触发 ADAPTER WARN） =="
T=$(mktemp -d); make_base "$T"
printf '# 手写 AGENTS\n\n实质性任务开始前使用 $ssot-preflight，并按 SSOT/README.md 路由。\n' > "$T/AGENTS.md"
out=$(run "$T"); code=$?
assert_exit "手写路由文件退出 0" "$code" "0"
assert_not_contains "手写路由文件不报 ADAPTER" "$out" "[ADAPTER]"
assert_not_contains "手写路由文件无 WARN" "$out" "[WARN]"
rm -rf "$T"

echo "== S4 手写 AGENTS 缺 SSOT 路由（检查 9 → CONSUMPTION） =="
T=$(mktemp -d); make_base "$T"
printf '# 手写 AGENTS\n\n这里只有仓库命令，没有长期记忆入口。\n' > "$T/AGENTS.md"
out=$(run "$T"); code=$?
assert_contains "手写无路由触发 CONSUMPTION" "$out" "[CONSUMPTION]"
assert_exit "手写无路由退出 1" "$code" "1"
assert_not_contains "手写无路由不报 ADAPTER" "$out" "[ADAPTER]"
rm -rf "$T"

echo "== S5 生成型适配器源 hash 漂移（检查 7 → WARN） =="
T=$(mktemp -d); make_base "$T"; add_clean_adapter "$T"
printf '\n额外改动导致源 hash 变化。\n' >> "$T/SSOT/architecture/README.md"
out=$(run "$T"); code=$?
assert_contains "源漂移触发 WARN" "$out" "源文件已变更"
rm -rf "$T"

echo "== S6 生成型适配器超长（检查 7 → WARN） =="
T=$(mktemp -d); make_base "$T"; add_clean_adapter "$T"
for i in $(seq 1 55); do printf 'extra line %s\n' "$i" >> "$T/AGENTS.md"; done
out=$(run "$T"); code=$?
assert_contains "超长触发 WARN" "$out" "超过 50 行"
rm -rf "$T"

echo "== S7 evidence 符号失效（检查 8 → STALE） =="
T=$(mktemp -d); make_base "$T"
sed -i 's/#barFunc/#ghostFunc/' "$T/SSOT/gotchas/0001-x.md"
out=$(run "$T"); code=$?
assert_contains "符号缺失触发 STALE" "$out" "[STALE] evidence 符号未找到"
rm -rf "$T"

echo "== S8 生成型适配器未路由 SSOT（检查 9 → CONSUMPTION） =="
T=$(mktemp -d); make_base "$T"
{
  printf '<!-- SSOT-generated | generated_at: 2026-05-29 -->\n'
  printf '# proj\n\n这里没有指向长期记忆目录的指令。\n'
} > "$T/AGENTS.md"
out=$(run "$T"); code=$?
assert_contains "无 SSOT 路由触发 CONSUMPTION" "$out" "[CONSUMPTION]"
rm -rf "$T"

echo ""
echo "===== 测试汇总：PASS=$PASS FAIL=$FAIL ====="
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
