#!/bin/sh

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

# 检查 Homebrew 是否已安装
if ! command -v brew &>/dev/null; then
    show_status "未找到 Homebrew，请先安装 Homebrew。" "error"
    echo "请访问 https://brew.sh/ 以获取安装说明。"
    exit 1
fi

# 检查 Node.js 和 npm 是否已安装
show_status "检查 Node.js 和 npm 是否已安装..." "progress"
if ! command -v node &>/dev/null; then
    show_status "未找到 Node.js，正在安装..." "progress"
    brew install node
fi

if ! command -v npm &>/dev/null; then
    show_status "未找到 npm，正在安装..." "progress"
    brew install npm
fi

# 确保 Node.js 和 npm 安装成功
if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
    show_status "Node.js 或 npm 安装失败，请检查安装。" "error"
    exit 1
else
    show_status "Node.js 和 npm 已安装。" "success"
fi

# 检查 Rust 是否已安装，若未安装则安装并加载环境变量
show_status "检查 Rust 是否已安装..." "progress"
if ! command -v rustc &>/dev/null; then
    show_status "Rust 未安装，正在安装..." "progress"
    curl https://sh.rustup.rs -sSf | sh
    source $HOME/.cargo/env
else
    show_status "Rust 已安装。" "success"
fi

# 设置 Nexus home 目录
NEXUS_HOME=$HOME/.nexus

# 检查 git 是否可用
show_status "检查 Git 是否可用..." "progress"
if ! command -v git &>/dev/null; then
    show_status "未找到 Git。请安装它并重试。" "error"
    exit 1
else
    show_status "Git 已安装。" "success"
fi

# 检查 PM2 是否已安装
show_status "检查 PM2 是否已安装..." "progress"
if ! command -v pm2 &>/dev/null; then
    show_status "未找到 PM2，正在安装..." "progress"
    npm install -g pm2
    if [ $? -ne 0 ]; then
        show_status "PM2 安装失败，请检查 npm。" "error"
        exit 1
    fi
else
    show_status "PM2 已安装。" "success"
fi

# 检查 Nexus 的 network-api 目录是否存在，存在则更新，不存在则克隆
if [ -d "$NEXUS_HOME/network-api" ]; then
    show_status "$NEXUS_HOME/network-api 已存在，正在更新..." "progress"
    (cd $NEXUS_HOME/network-api && git pull)
else
    show_status "正在克隆 Nexus network-api..." "progress"
    mkdir -p $NEXUS_HOME
    (cd $NEXUS_HOME && git clone https://github.com/nexus-xyz/network-api)
fi

# 确保 cargo 工具可用
if ! command -v cargo &>/dev/null; then
    show_status "Cargo 未安装或未找到，请确保 Rust 安装正确。" "error"
    exit 1
fi

# 进入 CLI 客户端并构建项目
show_status "进入 CLI 客户端并构建项目..." "progress"
cd $NEXUS_HOME/network-api/clients/cli

if [ ! -f Cargo.toml ]; then
