# 仓库优化计划

## P0 — 立即清理（安全删除）
1. 删除 `install-script/nvim.log`（日志文件）
2. 删除 `install-script/todo`（临时待办）
3. 删除 `install-script/no-use/` 目录（已归档废弃脚本）
4. 删除 `nvim/vim-tutorial-cn.md`（教程文档，非配置）
5. 删除 `install-script/nvim/readme.md`（重复文档，已有 README.md）
6. 删除 `install-script/nvim.log`（已被 gitignore 但仍在目录中）

## P1 — 结构标准化
1. 创建 `home/` 目录作为 stow 根
2. 将运行时配置从 `install-script/basic/` 迁移到 `home/`
3. 用 stow 替代手动符号链接
4. 统一 nvim 配置位置

## P2 — 持续优化
1. 更新 README 反映实际结构
2. 统一脚本风格
3. 添加必要的文档注释
