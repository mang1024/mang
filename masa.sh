#!/bin/bash

set -e  # 发生错误时退出
trap 'echo "脚本被中断"; exit 1;' SIGINT

# 检查是否以 root 用户运行
function check_root {
  if [ "$EUID" -ne 0 ]; then
    echo "请以 root 用户运行此操作"
    exit 1
  fi
}

function install_base_environment {
  echo "正在安装基础配置环境..."
  
  # 下载 Go
  wget -q https://go.dev/dl/go1.22.8.linux-amd64.tar.gz
  # 解压
  sudo tar -C /usr/local -xzf go1.22.8.linux-amd64.tar.gz
  # 配置环境
  echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
  source ~/.bashrc

  # 安装 Node.js
  echo "正在安装 Node.js..."
  if ! curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -; then
    echo "添加 NodeSource 仓库失败，尝试 Node.js 16.x..."
    sudo apt update
    if ! curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -; then
      echo "添加 NodeSource 仓库 (Node.js 16.x) 失败，退出安装。"
      return 1
    fi
  fi

  if ! sudo apt-get install -y nodejs; then
    echo "安装 Node.js 失败，退出安装。"
    return 1
  fi

  node -v
  npm -v

  # 克隆仓库
  git clone https://github.com/masa-finance/masa-oracle.git
  cd masa-oracle || { echo "切换到 masa-oracle 目录失败"; exit 1; }
  
  # 进入 contracts 目录
  cd contracts || { echo "切换到 contracts 目录失败"; exit 1; }

  # 安装依赖
  npm install || { echo "安装依赖失败"; exit 1; }
  cd ../..  # 返回到 masa-oracle 目录

  # 新建一个配置文件
  cat <<EOL > .env
# Default .env configuration
RPC_URL=https://ethereum-sepolia.publicnode.com
ENV=test
FILE_PATH=.
VALIDATOR=false
PORT=8080
TWITTER_SCRAPER=true
TWITTER_ACCOUNTS=masabigbigbig:masabigbigbig0825
USER_AGENTS="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36,Mozilla/5.0 (Macintosh; Intel Mac OS X 14.7; rv:131.0) Gecko/20100101 Firefox/131.0"
EOL

  echo "基础配置环境安装完成！"
}

function change_twitter_config {
  read -p "请输入您的 Twitter 账号和密码（格式：账号:密码）: " user_input
  sed -i "s/^TWITTER_ACCOUNTS=.*/TWITTER_ACCOUNTS=\"$user_input\"/" .env
  echo ".env 文件中的 Twitter 配置已更新！"
}

function start_make {
  echo "正在构建项目..."
  cd masa-oracle || { echo "切换到 masa-oracle 目录失败"; exit 1; }
  make build
  echo "构建完成！"
}

function run_make {
  echo "正在启动程序..."
  cd masa-oracle || { echo "切换到 masa-oracle 目录失败"; exit 1; }
  screen -S masa -dm make run
  echo "程序已在后台运行，您可以使用 'screen -r masa' 来重新连接。"
}

function main_menu {
  while true; do
    # 主菜单
    echo -e "\n1. 安装基础配置环境\n2. 更改 Twitter 配置\n3. 启动 Makefile\n4. 退出"

    read -p "请选择操作: " choice

    case $choice in
      1)
        check_root
        install_base_environment
        ;;
      2)
        change_twitter_config
        ;;
      3)
        start_make
        run_make
        ;;
      4)
        echo "退出程序。"
        exit 0
        ;;
      *)
        echo "无效的选择，请重试。"
        ;;
    esac
  done
}

# 调用主菜单
main_menu
