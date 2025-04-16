#!/bin/bash

# 设置错误处理
set -euo pipefail

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 定义日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 检查 xcodebuild 是否可用
if ! command -v xcodebuild &> /dev/null; then
    log_error "xcodebuild 未找到，请确保已安装 Xcode 命令行工具"
    exit 1
fi

# 清理之前的构建
log_info "清理之前的构建..."
rm -rf build

# 构建应用和扩展
log_info "开始构建应用和扩展..."
xcodebuild -project RightClickTools.xcodeproj -scheme RightClickTools -configuration Release build

# 检查构建是否成功
if [ $? -ne 0 ]; then
    log_error "构建失败"
    exit 1
fi

# 获取构建目录
BUILD_DIR="build/Release"
APP_PATH="$BUILD_DIR/RightClickTools.app"
EXT_PATH="$BUILD_DIR/RightClickTools.app/Contents/PlugIns/RightClickExtension.appex"

# 检查应用包结构
if [ ! -d "$APP_PATH" ] || [ ! -d "$EXT_PATH" ]; then
    log_error "应用包结构不完整"
    exit 1
fi

# 复制模板文件到应用包
log_info "复制模板文件到应用包..."
TEMPLATES_SRC="Templates"
TEMPLATES_DEST="$APP_PATH/Contents/Resources"

# 确保目标目录存在
mkdir -p "$TEMPLATES_DEST"

# 复制模板文件
cp -R "$TEMPLATES_SRC" "$TEMPLATES_DEST/"

# 检查复制是否成功
if [ $? -ne 0 ]; then
    log_error "复制模板文件失败"
    exit 1
fi

# 设置文件权限
log_info "设置文件权限..."
chmod -R 644 "$TEMPLATES_DEST/Templates"/*

# 安装应用到应用程序目录
log_info "安装应用到应用程序目录..."
APP_INSTALL_PATH="/Applications/RightClickTools.app"

# 如果已存在，先删除
if [ -d "$APP_INSTALL_PATH" ]; then
    log_info "删除已存在的应用..."
    rm -rf "$APP_INSTALL_PATH"
fi

# 复制应用到应用程序目录
cp -R "$APP_PATH" "/Applications/"

# 检查安装是否成功
if [ $? -ne 0 ]; then
    log_error "安装失败"
    exit 1
fi

# 提示用户启用扩展
log_info "安装完成！请按照以下步骤启用扩展："
echo "1. 打开系统设置"
echo "2. 进入隐私与安全性 > 扩展"
echo "3. 找到 Finder 扩展"
echo "4. 启用 RightClickTools 扩展"

# 清理构建目录
log_info "清理构建文件..."
rm -rf build

log_info "安装完成！" 