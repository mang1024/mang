#!/bin/bash

# 定义文本格式
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
PINK='\033[1;35m'

# 自定义状态显示函数
show_status() {
    local message="$1"
    local status="$2"
    case $status in
        "error")
            echo -e "${RED}${BOLD}出错: ${message}${NORMAL}"
            ;;
        "progress")
            echo -e "${YELLOW}${BOLD}进行中: ${message}${NORMAL}"
            ;;
        "success")
            echo -e "${GREEN}${BOLD}成功: ${message}${NORMAL}"
            ;;
        *)
            echo -e "${PINK}${BOLD}${message}${NORMAL}"
            ;;
    esac
}

# 定义服务名称
SERVICE_NAME="nexus"

# 安装 Homebrew（如果未安装）
if ! command -v brew &> /dev/null; then
    show_status "正在安装 Homebrew..." "progress"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 安装 PM2
show_status "正在安装 PM2..." "progress"
if ! npm install -g pm2; then
    show_status "安装 PM2 失败。" "error"
    exit 1
fi

# 安装 Rust
show_status "正在安装 Rust..." "progress"
if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
    show_status "安装 Rust 失败。" "error"
    exit 1
fi

# 加载 Rust 环境
source $HOME/.cargo/env

# 更新软件包列表（macOS 不需要这一步）

# 检查并安装 Git
if ! command -v git &> /dev/null; then
    show_status "Git 未安装。正在安装 Git..." "progress"
    if ! brew install git; then
        show_status "安装 Git 失败。" "error"
        exit 1
    fi
else
    show_status "Git 已安装。" "success"
fi

# 删除已有的仓库（如果存在）
if [ -d "$HOME/network-api" ]; then
    show_status "正在删除现有的仓库..." "progress"
    rm -rf "$HOME/network-api"
fi

# 克隆 Nexus-XYZ 网络 API 仓库
show_status "正在克隆 Nexus-XYZ 网络 API 仓库..." "progress"
if ! git clone https://github.com/nexus-xyz/network-api.git "$HOME/network-api"; then
    show_status "克隆仓库失败。" "error"
    exit 1
fi

# 安装依赖项
cd $HOME/network-api/clients/cli
show_status "安装所需的依赖项..." "progress"
if ! brew install pkg-config openssl; then
    show_status "安装依赖项失败。" "error"
    exit 1
fi

# 直接启动服务（假设 PM2 已经安装）
show_status "使用 PM2 启动 Nexus 服务..." "progress"
if ! pm2 start "$HOME/.cargo/bin/cargo" --name "$SERVICE_NAME" -- run --release --bin prover -- beta.orchestrator.nexus.xyz 2>/dev/null; then
    show_status "启动服务失败。" "error"
    exit 1
fi

# 保存当前进程列表
pm2 save 2>/dev/null

# 改进的服务状态检查逻辑
show_status "服务状态：" "progress"
if pm2 isRunning "$SERVICE_NAME" 2>/dev/null; then
    show_status "服务正在运行。" "success"
else
    show_status "获取服务状态失败。" "error"
fi

show_status "Nexus Prover 安装和服务设置完成！" "success"
