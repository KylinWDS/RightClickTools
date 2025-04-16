# RightClickTools

macOS Finder 扩展工具，提供便捷的右键菜单功能。

## 功能特性

### 基础工具
- **复制文件路径**
  - 选中文件时：复制文件的完整路径
  - 未选中文件时：复制当前目录路径

- **用Sublime打开**
  - 选中文件时：用 Sublime Text 打开选中的文件
  - 未选中文件时：直接打开 Sublime Text 编辑器

- **在此打开终端**
  - 在当前目录打开终端窗口

- **切换隐藏文件**
  - 快速切换 Finder 中隐藏文件的显示状态

### 新建文件功能
支持快速创建多种类型的文件：

文本文件：
- TXT 文本文件
- Markdown 文件
- RTF 富文本文件

Office 文件：
- Word 文档 (docx)
- Excel 表格 (xlsx)
- PowerPoint 演示文稿 (pptx)

iWork 文件：
- Pages 文档
- Numbers 表格
- Keynote 演示文稿

## 系统要求
- macOS 10.15 或更高版本
- Xcode 12.0 或更高版本（仅开发时需要）

## 安装说明
1. 下载最新版本的 RightClickTools
2. 将应用拖入应用程序文件夹
3. 首次运行时需要授予 Finder 扩展权限
4. 在系统偏好设置 > 扩展 > 访达扩展 中启用 RightClickTools

## 开发说明
1. 克隆项目
```bash
git clone https://github.com/yourusername/RightClickTools.git
```

2. 打开项目
```bash
cd RightClickTools
open RightClickTools.xcodeproj
```

3. 构建和运行项目

## 注意事项
- 首次使用需要在系统偏好设置中启用扩展
- 某些功能可能需要相应的应用程序支持（如 Sublime Text）

## 许可证
MIT License 