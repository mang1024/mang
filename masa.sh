#!/bin/bash

# 检查是否以 root 用户运行
function check_root {
  if [ "$EUID" -ne 0 ]; then
    echo "请以 root 用户运行此操作"
    exit 1
  fi
}

while true; do
  # 主菜单
  echo -e "\n1. 安装基础配置环境\n2. 更改 Twitter 配置\n3. 开始构建环境\n4. 启动节点\n5. 获取 MASA 代币并质押\n6. 显示私钥\n7. 退出"

  read -p "请选择操作: " choice

  case $choice in
    1)
      check_root  # 仅在命令1时检查root权限
      echo "正在安装基础配置环境..."
      
      # 下载 Go
      wget https://go.dev/dl/go1.22.8.linux-amd64.tar.gz
      # 解压
      sudo tar -C /usr/local -xzf go1.22.8.linux-amd64.tar.gz
      # 配置环境
      echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
      source ~/.bashrc

      # 安装 npm
      curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
      sudo apt-get install -y nodejs

      # 克隆仓库
      git clone https://github.com/masa-finance/masa-oracle.git
      cd masa-oracle || { echo "切换目录失败"; exit 1; }

      # 安装依赖
      npm install
      cd ..

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
      ;;

    2)
      read -p "请输入您的 Twitter 账号和密码（格式：账号:密码）: " user_input
      sed -i "s/^TWITTER_ACCOUNTS=.*/TWITTER_ACCOUNTS=\"$user_input\"/" .env
      echo ".env 文件中的 Twitter 配置已更新！"
      ;;

    3)
      echo "开始构建环境..."
      make build
      ;;

    4)
      echo "启动节点..."
      make run
      ;;

    5)
      cd masa-oracle || { echo "切换目录失败"; exit 1; }
      echo "获取 MASA 代币并质押..."
      make faucet 
      echo "注意：请先领取代币，完成后再运行质押命令。"
      make stake
      ;;

    6)
      echo "显示私钥..."
      # 确保显示当前用户的私钥
      cat ~/.masa/masa_oracle_key.ecdsa
      ;;

    7)
      echo "退出程序。"
      exit 0
      ;;

    *)
      echo "无效的选择，请重新选择。"
      ;;
  esac
done
