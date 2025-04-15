#!/bin/bash

# 获取脚本所在的目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_NAME="RightClickTools"
APP_PATH="$SCRIPT_DIR/build/Release/$APP_NAME.app"

echo "===== 右键工具安装脚本 ====="
echo "此脚本将帮助您安装并配置右键工具。"
echo ""

# 检查是否已经编译应用
if [ ! -d "$APP_PATH" ]; then
    echo "未找到编译好的应用。正在尝试编译..."
    
    # 检查是否安装了Xcode命令行工具
    if ! command -v xcodebuild &> /dev/null; then
        echo "错误: 未找到xcodebuild工具。请安装Xcode命令行工具。"
        echo "可以通过运行 'xcode-select --install' 命令安装。"
        exit 1
    fi
    
    # 创建build目录
    mkdir -p "$SCRIPT_DIR/build"
    
    # 编译应用
    echo "正在编译应用..."
    cd "$SCRIPT_DIR"
    xcodebuild -project RightClickTools.xcodeproj -scheme RightClickTools -configuration Release -derivedDataPath "$SCRIPT_DIR/build" clean build
    
    # 检查编译结果
    if [ ! -d "$APP_PATH" ]; then
        echo "编译失败！请尝试在Xcode中手动编译项目。"
        exit 1
    fi
    
    echo "应用编译成功！"
fi

# 复制模板文件到应用包
echo "正在复制模板文件到应用包中..."
"$SCRIPT_DIR/copy_templates.sh" "$APP_PATH"

# 验证模板文件是否已正确复制
echo "验证模板文件..."
if [ ! -d "$APP_PATH/Contents/Resources/Templates" ]; then
    echo "警告: 模板子目录不存在，创建中..."
    mkdir -p "$APP_PATH/Contents/Resources/Templates"
fi

# 确保模板文件同时存在于两个位置
# 1. Resources目录中 - 供AppDelegate访问
# 2. Resources/Templates子目录中 - 供FinderSync访问
echo "确保模板文件位于正确位置..."
for template in "$SCRIPT_DIR/Templates/"*; do
    if [ -f "$template" ]; then
        filename=$(basename "$template")
        echo "处理 $filename"
        # 复制到Resources目录
        cp -f "$template" "$APP_PATH/Contents/Resources/"
        # 复制到Templates子目录
        cp -f "$template" "$APP_PATH/Contents/Resources/Templates/"
    fi
done

# 移动应用到Applications文件夹
DEST_PATH="/Applications/$APP_NAME.app"
echo "正在安装应用到 $DEST_PATH..."

if [ -d "$DEST_PATH" ]; then
    echo "发现已存在的安装，正在移除..."
    rm -rf "$DEST_PATH"
fi

# 复制应用
cp -R "$APP_PATH" "/Applications/"

if [ ! -d "$DEST_PATH" ]; then
    echo "安装失败！请确保您有足够的权限。"
    echo "可以尝试手动将 $APP_PATH 拖到应用程序文件夹。"
    exit 1
fi

echo "应用已安装到应用程序文件夹。"

# 设置权限
echo "正在设置权限..."
chmod +x "$DEST_PATH/Contents/MacOS/$APP_NAME"

# 提示启用Finder扩展
echo ""
echo "安装完成！接下来需要启用Finder扩展以获得原生右键菜单功能："
echo ""
echo "1. 请在系统设置中启用Finder扩展："
echo "   系统设置 -> 隐私与安全性 -> 扩展 -> 访达 -> 勾选「RightClickExtension」"
echo ""
echo "2. 授予必要的权限："
echo "   首次使用某些功能（如打开终端）时，系统会请求额外权限"
echo "   请点击「允许」以确保功能正常工作"
echo ""
echo "是否现在打开扩展设置页面？(y/n)"
read answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    # 打开扩展设置
    open "x-apple.systempreferences:com.apple.preference.extensions"
    echo "请在打开的设置中，选择左侧的「访达」，然后勾选「RightClickExtension」"
fi

echo ""
echo "安装完成！请从应用程序文件夹启动右键工具应用。"
echo "如需开机自启动，请将应用添加到登录项中。"
echo ""
echo "感谢使用右键工具！"

exit 0 