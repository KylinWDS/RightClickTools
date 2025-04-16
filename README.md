# RightClickTools

macOS Finder 扩展工具，提供便捷的右键菜单功能。

![版本](https://img.shields.io/badge/版本-1.0.0-blue.svg)
![平台](https://img.shields.io/badge/平台-macOS-lightgrey.svg)
![语言](https://img.shields.io/badge/语言-Swift%205-orange.svg)
![许可证](https://img.shields.io/badge/许可证-MIT-green.svg)

## 项目简介
RightClickTools 是一个为 macOS Finder 开发的扩展工具，通过原生右键菜单为用户提供一系列实用的文件操作功能。它能够帮助用户更高效地管理文件和执行常见操作，提升工作效率。

## 功能特性

### 基础工具
- **复制文件路径**
  - 选中文件时：复制文件的完整路径
  - 未选中文件时：复制当前目录路径
  - 支持各种特殊字符的路径

- **用Sublime打开**
  - 选中文件时：用 Sublime Text 打开选中的文件
  - 未选中文件时：直接打开 Sublime Text 编辑器
  - 自动检测 Sublime Text 是否安装

- **在此打开终端**
  - 在当前目录打开终端窗口
  - 自动 cd 到当前目录
  - 支持各种特殊字符的路径

- **切换隐藏文件**
  - 快速切换 Finder 中隐藏文件的显示状态
  - 无需重启 Finder（自动刷新）
  - 全局生效

### 新建文件功能
支持快速创建多种类型的文件，所有模板文件都经过优化：

文本文件：
- TXT 文本文件（UTF-8编码）
- Markdown 文件（包含基础模板）
- RTF 富文本文件（支持中文）

Office 文件：
- Word 文档 (docx)（预设页面格式）
- Excel 表格 (xlsx)（预设单元格格式）
- PowerPoint 演示文稿 (pptx)（预设幻灯片模板）

iWork 文件：
- Pages 文档（优化排版设置）
- Numbers 表格（预设计算格式）
- Keynote 演示文稿（预设动画效果）

## 系统要求
- macOS 10.15 (Catalina) 或更高版本
- 约 10MB 可用存储空间
- Xcode 12.0 或更高版本（仅开发时需要）

## 安装说明
1. 下载最新版本的 RightClickTools
2. 将应用拖入应用程序文件夹
3. 首次运行时需要授予以下权限：
   - Finder 扩展权限
   - 自动化权限（用于终端操作）
   - 辅助功能权限（可选，用于高级功能）
4. 在系统偏好设置 > 扩展 > 访达扩展 中启用 RightClickTools

## 开发说明
1. 克隆项目
```bash
git clone https://github.com/KylinWDS/RightClickTools.git
cd RightClickTools
git checkout develop  # 切换到开发分支
```

2. 安装依赖（如果有）
```bash
# 目前项目不需要额外依赖
```

3. 打开项目
```bash
open RightClickTools.xcodeproj
```

4. 构建和运行项目
   - 选择正确的开发者证书
   - 确保目标设备为 macOS
   - 使用 Product > Run 运行项目

## 项目结构
```
RightClickTools/
├── RightClickTools.xcodeproj/    # Xcode 项目文件
├── Templates/                     # 文件模板目录
│   ├── Template.txt              # 文本文件模板
│   ├── Template.md               # Markdown 模板
│   ├── Template.rtf              # RTF 模板
│   ├── Template.docx             # Word 文档模板
│   ├── Template.xlsx             # Excel 表格模板
│   ├── Template.pptx             # PowerPoint 模板
│   ├── Template.pages            # Pages 文档模板
│   ├── Template.numbers          # Numbers 表格模板
│   └── Template.key              # Keynote 演示文稿模板
├── Core/                         # 核心功能实现
│   ├── FinderSync.swift          # Finder 扩展核心实现
│   ├── FileOperations.swift      # 文件操作管理
│   └── TemplateManager.swift     # 模板文件管理
├── Support/                      # 支持文件
│   ├── Info.plist               # 项目配置文件
│   └── RightClickExtension.entitlements  # 权限配置文件
└── Scripts/                      # 辅助脚本
    ├── install.command           # 安装脚本
    └── test_run.command          # 测试运行脚本
```

## 常见问题
1. **安装后找不到扩展**
   - 检查系统偏好设置中的扩展是否启用
   - 尝试重启 Finder（在终端执行：`killall Finder`）
   - 确保应用在后台运行

2. **某些功能无法使用**
   - 检查相关应用是否安装（如 Sublime Text）
   - 确认是否授予了必要的系统权限
   - 查看控制台日志以获取详细错误信息

3. **模板文件不可用**
   - 确保 Templates 目录存在且有正确权限
   - 检查模板文件格式是否正确
   - 尝试重新安装应用

## 贡献指南
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m '添加一些特性'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 更新日志
### v1.0.0 (2025-04-15)
- 首次发布
- 实现基础文件操作功能
- 添加多种文件模板支持

## 维护者
- [@KylinWDS](https://github.com/KylinWDS)

## 免责声明

### 重要提示
**本工具仅供学习和研究使用。请在下载后 24 小时内删除。不得用于商业用途。**

### 版权声明
1. 本工具涉及的所有第三方商标或品牌（包括但不限于）：
   - Microsoft Office (Word, Excel, PowerPoint)
   - Apple iWork (Pages, Numbers, Keynote)
   - Sublime Text
   均为其各自所有者的财产。

2. 本工具仅提供便捷操作功能，不对以下内容负责：
   - 用户使用本工具创建的任何文件内容
   - 用户对第三方软件的使用
   - 因使用本工具而可能产生的任何问题或损失

### 使用限制
1. 严禁将本工具用于任何商业用途
2. 严禁对本工具进行反编译、反向工程或破解
3. 严禁将本工具用于任何非法用途

### 下载使用即代表您同意：
1. 遵守本免责声明的所有条款
2. 承诺在 24 小时内删除本工具
3. 承担因使用本工具而产生的一切后果

## 许可证
本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 文件了解更多细节 