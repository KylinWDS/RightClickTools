#!/bin/bash

# 获取脚本所在的目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 检查是否提供了应用路径参数
if [ $# -lt 1 ]; then
    echo "错误: 未提供应用路径参数"
    echo "用法: $0 <应用路径>"
    exit 1
fi

APP_PATH="$1"
TEMPLATES_SRC="$SCRIPT_DIR/Templates"
TEMPLATES_DEST="$APP_PATH/Contents/Resources/Templates"
RESOURCES_DEST="$APP_PATH/Contents/Resources"

# 检查源模板目录是否存在
if [ ! -d "$TEMPLATES_SRC" ]; then
    echo "错误: 模板源目录不存在: $TEMPLATES_SRC"
    exit 1
fi

# 检查应用包是否存在
if [ ! -d "$APP_PATH" ]; then
    echo "错误: 应用包不存在: $APP_PATH"
    exit 1
fi

# 创建目标目录
mkdir -p "$TEMPLATES_DEST"

# 复制模板文件到Templates子目录
echo "复制模板文件从 $TEMPLATES_SRC 到 $TEMPLATES_DEST"
cp -R "$TEMPLATES_SRC/"* "$TEMPLATES_DEST/"

# 检查复制结果
if [ $? -eq 0 ]; then
    echo "模板文件已成功复制到应用包的Templates目录中"
else
    echo "复制模板文件到Templates目录失败!"
    exit 1
fi

# 同时复制模板文件到Resources根目录（供AppDelegate访问）
echo "复制模板文件到应用Resources根目录"
cp -R "$TEMPLATES_SRC/"* "$RESOURCES_DEST/"

# 检查复制结果
if [ $? -eq 0 ]; then
    echo "模板文件已成功复制到应用Resources根目录"
else
    echo "复制模板文件到Resources根目录失败!"
    exit 1
fi

# 列出复制后的文件，验证结果
echo "验证复制结果:"
echo "Templates目录中的文件:"
ls -la "$TEMPLATES_DEST"
echo "Resources目录中的文件:"
ls -la "$RESOURCES_DEST" | grep Template

exit 0 