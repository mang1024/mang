#!/bin/bash

# 安装 Go
install_go() {
    if command -v go &> /dev/null; then
        echo "Go 已经安装，跳过安装步骤。"
        return
    fi

    echo "正在安装 Go..."
    while true; do
        wget https://go.dev/dl/go1.22.8.linux-amd64.tar.gz
        if [ $? -ne 0 ]; then
            echo "下载失败，请重试。"
            continue
        fi
        sudo tar -C /usr/local -xzf go1.22.8.linux-amd64.tar.gz
        echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
        source ~/.bashrc

        if go version; then
            echo "Go 安装成功！"
            break
        else
            echo "Go 安装失败，请重试。"
            rm go1.22.8.linux-amd64.tar.gz
        fi
    done
}

# 安装 Node.js 和 PM2
install_node_pm2() {
    if command -v node &> /dev/null && command -v pm2 &> /dev/null; then
        echo "Node.js 和 PM2 已经安装，跳过安装步骤。"
        return
    fi

    echo "正在安装 Node.js 和 PM2..."
    while true; do
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs

        if node -v && npm -v; then
            echo "Node.js 安装成功！"
            break
        else
            echo "Node.js 安装失败，尝试安装 Node.js 16.x..."
            sudo apt-get purge -y nodejs
            curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
            sudo apt-get install -y nodejs
        fi
    done

    if ! command -v npm &> /dev/null; then
        echo "npm 未安装，正在安装..."
        sudo apt install -y npm
    fi

    if ! command -v pm2 &> /dev/null; then
        while true; do
            sudo npm install pm2 -g
            if pm2 -v; then
                echo "PM2 安装成功！"
                break
            else
                echo "PM2 安装失败，请重试。"
            fi
        done
    else
        echo "PM2 已经安装，跳过安装步骤。"
    fi
}

# 克隆官方仓库
clone_repository() {
    echo "正在克隆官方仓库..."
    git clone https://github.com/masa-finance/masa-oracle.git
    cd masa-oracle || { echo "克隆失败，目录不存在！"; return; }

    echo "安装项目依赖..."
    cd contracts
    npm install
    cd ..
}

# 构建项目
build_project() {
    echo "正在构建项目，请耐心等待..."
    cd
    cd masa-oracle || { echo "构建失败，目录不存在！"; return; }
    make build
    echo "构建完成！"
}

# 创建配置文件
create_env_file() {
    echo "创建配置文件..."
    mkdir -p ~/masa-oracle
    cat <<EOL > ~/.env
# Default .env configuration
BOOTNODES=/ip4/52.6.77.89/udp/4001/quic-v1/p2p/16Uiu2HAmBcNRvvXMxyj45fCMAmTKD4bkXu92Wtv4hpzRiTQNLTsL,/ip4/3.213.117.85/udp/4001/quic-v1/p2p/16Uiu2HAm7KfNcv3QBPRjANctYjcDnUvcog26QeJnhDN9nazHz9Wi,/ip4/52.20.183.116/udp/4001/quic-v1/p2p/16Uiu2HAm9Nkz9kEMnL1YqPTtXZHQZ1E9rhquwSqKNsUViqTojLZt
RPC_URL=https://ethereum-sepolia.publicnode.com
ENV=test
FILE_PATH=.
VALIDATOR=false
PORT=8080
TWITTER_SCRAPER=true
TWITTER_ACCOUNTS=masabigbigbig:masabigbigbig0825
USER_AGENTS="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36,Mozilla/5.0 (Macintosh; Intel Mac OS X 14.7; rv:131.0) Gecko/20100101 Firefox/131.0"
EOL

    cp ~/.env ~/masa-oracle/.env
}

# 修改 Twitter 配置
update_twitter_accounts() {
    read -p "请输入账号:密码: " twitter_accounts
    if [[ ! "$twitter_accounts" =~ ^[^:]+:[^:]+$ ]]; then
        echo "格式错误，请输入账号:密码。"
        return
    fi
    sed -i "s/TWITTER_ACCOUNTS=.*/TWITTER_ACCOUNTS=\"$twitter_accounts\"/" ~/.env
    sed -i "s/TWITTER_ACCOUNTS=.*/TWITTER_ACCOUNTS=\"$twitter_accounts\"/" ~/masa-oracle/.env
}

# 配置交换内存
configure_swap() {
    echo "正在配置交换内存..."
    sudo rm /swapfile.img
    sudo fallocate -l 12G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
    echo "交换内存配置完成！"
}

# 显示私钥
show_private_key() {
    echo "显示私钥..."
    cd ~ || exit
    if [[ -f ~/.masa/masa_oracle_key.ecdsa ]]; then
        cat ~/.masa/masa_oracle_key.ecdsa
    else
        echo "私钥文件不存在！"
    fi
}

# 领币质押
stake_tokens() {
    echo "正在进行领币质押..."
    cd ~/masa-oracle || { echo "目录 masa-oracle 不存在！"; return; }
    
    make faucet    
    if [ $? -eq 0 ]; then
        echo "领币成功！"
    else
        echo "领币失败！"
    fi

    make stake
    if [ $? -eq 0 ]; then
        echo "质押成功！"
    else
        echo "质押失败！"
    fi
}

# 使用 PM2 启动项目
start_with_pm2() {
    echo "正在使用 PM2 启动项目..."
    cd ~/masa-oracle || { echo "目录 masa-oracle 不存在！"; return; }
    
    if pm2 list | grep -q masa; then
        echo "项目已存在，正在启动..."
        pm2 start masa
    else
        echo "不存在，正在创建并启动..."
        pm2 start make --name masa -- run
    fi

    if [ $? -eq 0 ]; then
        echo "启动成功！"
    else
        echo "启动失败！"
    fi
}

view_pm2_logs() {
    echo "正在查看日志"
    pm2 logs masa
}

stop_pm2_masa() {
    pm2 stop masa
    echo "正在停止"
}

# 主菜单
main_menu() {
    while true; do

        echo "---------------------------------"    
        echo "---------------------------------"    
        echo "请选择操作:"
        echo "1) 安装配置文件并 Build"
        echo "2) 修改 Twitter 配置"
        echo "3) 配置交换内存12GB"
        echo "4) 显示私钥"
        echo "5) 领币质押"
        echo "6) 使用 PM2 启动"  
        echo "7) 查看日志" 
        echo "8) 停止"
        echo "0) 退出"
        read -p "请输入选项: " option

        case $option in
            1) 
                install_go
                install_node_pm2
                clone_repository
                build_project
                create_env_file
                ;;
            2) update_twitter_accounts ;;
            3) configure_swap ;;
            4) show_private_key ;;
            5) stake_tokens ;;
            6) start_with_pm2 ;;
            7) view_pm2_logs ;;
            8) stop_pm2_masa ;;
            0) echo "退出程序。"; exit 0 ;;
            *) echo "无效选项，请重试。" ;;
        esac
    done
}

# 开始程序
main_menu
