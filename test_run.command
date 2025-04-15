#!/bin/bash

# 获取脚本所在的目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_NAME="RightClickTools"
EXTENSION_NAME="RightClickExtension"
BUILD_DIR="$SCRIPT_DIR/build"
DEBUG_DIR="$BUILD_DIR/Build/Products/Debug"
APP_PATH="$DEBUG_DIR/$APP_NAME.app"

echo "===== 右键工具测试脚本 ====="
echo "此脚本将构建并运行应用（不安装到系统）"
echo ""

# 检查是否安装了Xcode命令行工具
if ! command -v xcodebuild &> /dev/null; then
    echo "错误: 未找到xcodebuild工具。请安装Xcode命令行工具。"
    echo "可以通过运行 'xcode-select --install' 命令安装。"
    exit 1
fi

# 创建build目录
mkdir -p "$BUILD_DIR"

# 构建应用
echo "正在构建应用及扩展..."
cd "$SCRIPT_DIR"
xcodebuild -project RightClickTools.xcodeproj -scheme RightClickTools -configuration Debug -derivedDataPath "$BUILD_DIR" build

# 检查构建结果
if [ ! -d "$APP_PATH" ]; then
    echo "构建失败！请尝试在Xcode中手动编译项目。"
    exit 1
fi

# 准备复制模板文件
echo "正在复制模板文件到应用包中..."
RESOURCES_DIR="$APP_PATH/Contents/Resources"
TEMPLATES_DIR="$RESOURCES_DIR/Templates"
mkdir -p "$TEMPLATES_DIR"

# 复制模板文件到两个位置
# 1. Resources目录 - 供AppDelegate访问
# 2. Templates子目录 - 供FinderSync访问
echo "复制模板文件..."
for template in "$SCRIPT_DIR/Templates/"*.*; do
    if [ -f "$template" ]; then
        filename=$(basename "$template")
        echo "处理 $filename"
        # 复制到Resources目录
        cp -f "$template" "$RESOURCES_DIR/"
        # 复制到Templates子目录
        cp -f "$template" "$TEMPLATES_DIR/"
    fi
done

echo "模板文件已成功复制到应用包中"
echo "验证结果:"
echo "Resources目录:"
ls -la "$RESOURCES_DIR" | grep Template
echo "Templates子目录:"
ls -la "$TEMPLATES_DIR"

# 复制模板文件到扩展包
EXTENSION_PATH="$DEBUG_DIR/$EXTENSION_NAME.appex"
if [ -d "$EXTENSION_PATH" ]; then
    echo "正在复制模板文件到扩展包中..."
    EXT_RESOURCES_DIR="$EXTENSION_PATH/Contents/Resources"
    EXT_TEMPLATES_DIR="$EXT_RESOURCES_DIR/Templates"
    mkdir -p "$EXT_TEMPLATES_DIR"
    
    # 同样复制到两个位置
    for template in "$SCRIPT_DIR/Templates/"*.*; do
        if [ -f "$template" ]; then
            filename=$(basename "$template")
            # 复制到Resources目录
            cp -f "$template" "$EXT_RESOURCES_DIR/"
            # 复制到Templates子目录
            cp -f "$template" "$EXT_TEMPLATES_DIR/"
        fi
    done
    
    echo "模板文件已成功复制到扩展包中"
    echo "验证结果:"
    echo "扩展Resources目录:"
    ls -la "$EXT_RESOURCES_DIR" | grep Template
    echo "扩展Templates子目录:"
    ls -la "$EXT_TEMPLATES_DIR"
fi

# 运行应用
echo "正在启动应用..."
open "$APP_PATH"

echo ""
echo "注意：这只是测试运行，不会将扩展安装到系统中。"
echo "要测试右键菜单功能，请使用install.command脚本安装应用，"
echo "并在系统设置中启用Finder扩展。"
echo ""
echo "您可以使用以下快捷键直接测试菜单功能："
echo "Option+Command+R（在鼠标位置显示菜单）"

exit 0 