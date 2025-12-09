# 更新日志

## v2.1.1 - TUI 渲染稳定性修复 (2025-12-09)

### 修复
- 🐛 **修复 TUI 界面上下闪烁问题**
  - **问题原因**：`tools_config.json` 中"系统配置"分类使用的 `⚙️` (gear) emoji 包含 Unicode Variation Selector-16 (U+FE0F)
  - **技术细节**：该字符在终端中宽度计算不稳定（1/2 字符宽度振荡），导致 Rich 库布局引擎渲染状态振荡
  - **解决方案**：将 `⚙️` 替换为稳定的 `🛠` (hammer and wrench)
  - **定位方法**：二分测试法精确定位到单个 emoji 字符

### 文档
- 📚 **新增 Emoji 图标选择指南**（README.md）
  - 已验证稳定的图标列表
  - 问题图标黑名单
  - Unicode Variation Selector 检查方法
  - 新增图标验证流程

### 技术债务清理
- ✅ 建立 emoji 图标稳定性验证规范
- ✅ 防止未来出现类似渲染问题

---

## v2.1.0 - 项目结构规范化 (2025-12-03)

### 重大变更
- 📦 采用现代 Python 项目结构 (`pyproject.toml`)
- 📁 源码目录重命名：`src/` → `tui_installer/`
- ✨ 支持 `python -m tui_installer` 和 `tui-installer` 命令运行
- 🧪 添加完整的 pytest 测试框架

### 项目结构
```
tui-installer/
├── pyproject.toml           # 项目配置
├── Makefile                  # 开发命令
├── tui_installer/            # 主程序包
│   ├── __init__.py
│   ├── __main__.py           # 程序入口
│   ├── app.py
│   ├── config.py
│   ├── models.py
│   ├── executor.py
│   ├── input.py
│   ├── ui.py
│   ├── system.py
│   └── data/
│       └── tools_config.json
├── tests/                    # 测试目录
└── scripts/                  # 辅助脚本
```

### 新增
- ✅ `pyproject.toml` 替代 `requirements.txt`
- ✅ `Makefile` 简化常用开发命令
- ✅ pytest 测试框架与 fixtures
- ✅ 类型标记文件 `py.typed`
- ✅ 可配置的脚本根目录路径

### 改进
- 🔧 配置文件迁移到 `tui_installer/data/` 目录
- 📚 更新所有文档以反映新结构
- 🧹 优化 `.gitignore` 覆盖更多场景

---

## v2.0.0 - 模块化重构 (2025-12-03)

### 重大变更
- ✨ 完全重构为模块化架构
- 📁 文件夹重命名：`tui_workspace` → `tui-installer`
- 🗑️ 移除旧的单文件实现
- 📦 拆分为独立模块，职责单一

### 新增功能
- ✅ Vim 风格按键操作 (hjkl 导航)
- ⚡ 异步并发执行多个安装任务
- 📊 实时日志流显示
- 🔍 智能系统检查 (sudo/SSH/WSL)
- 🎨 基于 Rich 的现代化 TUI 界面

### 修复
- 🐛 修复 `fzf` 安装时的交互式阻塞问题
- 🐛 修复 `config-install.sh` 的路径依赖问题
- 🐛 修复键盘输入阻塞导致 jk 无法移动的问题

---

## v1.0.0 - 原型设计

- 🎨 基于 `proto_modern.py` 的静态视觉设计
- 📦 基础的脚本集成
