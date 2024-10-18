#!/bin/bash

# 下载 Go
echo "正在下载 Go..."
curl -LO https://go.dev/dl/go1.22.8.linux-amd64.tar.gz

# 解压
echo "正在解压 Go..."
sudo tar -C /usr/local -xzf go1.22.8.linux-amd64.tar.gz

# 配置环境
echo "配置 Go 环境变量..."
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc

# 检查 Go 是否安装成功
if ! command -v go &> /dev/null; then
  echo "Go 安装失败，退出安装。"
  exit 1
else
  echo "Go 安装成功，版本为：$(go version)"
fi

# 安装 Node.js
echo "正在安装 Node.js..."
if ! curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -; then
  echo "添加 NodeSource 仓库失败，尝试 Node.js 16.x..."
  sudo apt update
  if ! curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -; then
    echo "添加 NodeSource 仓库 (Node.js 16.x) 失败，退出安装。"
    exit 1
  fi
fi

if ! sudo apt-get install -y nodejs; then
  echo "安装 Node.js 失败，退出安装。"
  exit 1
fi

echo "Node.js 和 npm 版本："
node -v
npm -v

# 新建一个配置文件
echo "正在创建 .env 配置文件..."
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

# 克隆 GitHub 仓库
echo "正在克隆 GitHub 仓库..."
if ! git clone https://github.com/masa-finance/masa-oracle.git; then
  echo "克隆仓库失败，退出安装。"
  exit 1
fi

echo "基础配置环境安装完成！"
