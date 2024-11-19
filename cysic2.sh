#!/bin/bash

# 函数：检查命令是否成功执行
check_command() {
    if [ $? -ne 0 ]; then
        echo "命令执行失败: $1"
        exit 1
    fi
}

# 检查 Node.js、npm 和 PM2 是否已安装
check_installed() {
    command -v node >/dev/null 2>&1 && NODE_INSTALLED=true || NODE_INSTALLED=false
    command -v npm >/dev/null 2>&1 && NPM_INSTALLED=true || NPM_INSTALLED=false
    command -v pm2 >/dev/null 2>&1 && PM2_INSTALLED=true || PM2_INSTALLED=false
}

# 安装 Node.js 和 PM2
install_dependencies() {
    echo "正在更新软件包列表..."
    sudo apt update
    check_command "更新软件包列表失败"

    if [ "$NODE_INSTALLED" = false ]; then
        echo "正在安装 Node.js 和 npm..."
        sudo apt install -y nodejs npm
        check_command "安装 Node.js 和 npm 失败"
    else
        echo "Node.js 和 npm 已安装，跳过安装。"
    fi

    if [ "$PM2_INSTALLED" = false ]; then
        echo "正在安装 PM2..."
        if ! curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -; then
            echo "Failed to add NodeSource repository. Trying alternative method..."
            if ! curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -; then
                echo "Failed to add NodeSource repository for Node.js 16.x. Exiting."
                exit 1
            fi
        fi

        if ! sudo apt-get install -y nodejs; then
            echo "Failed to install Node.js. Exiting."
            exit 1
        fi

        echo "Node.js 版本: $(node -v)"
        echo "npm 版本: $(npm -v)"

        if ! sudo npm install pm2 -g; then
            echo "Failed to install PM2 using npm. Trying alternative method..."
            if ! sudo apt install -y npm && sudo npm install pm2 -g; then
                echo "Failed to install PM2. Exiting."
                exit 1
            fi
        fi

        echo "PM2 版本: $(pm2 -v)"
    else
        echo "PM2 已安装，跳过安装。"
    fi
}

# 主菜单循环
while true; do
    echo "请选择命令:"
    echo "1. 安装 PM2 和配置验证器"
    echo "2. 启动验证器"
    echo "3. 停止并删除验证器"
    echo "4. 删除第一阶段测试网的相关信息"
    echo "0. 退出"
    read -p "请输入命令: " command

    case $command in
        1)
            check_installed
            install_dependencies
            echo "PM2 和配置验证器安装完成，返回主菜单..."

            # 提示用户输入奖励地址
            read -p "请输入你的实际奖励地址: " reward_address

            # 下载并配置验证器
            echo "正在下载并配置验证器..."
            if curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh -o ~/setup_linux.sh; then
                bash ~/setup_linux.sh "$reward_address"
            else
                echo "下载失败，请检查 URL 或网络连接。"
            fi
            ;;

        2)
            # 启动验证器
            if [ ! -f pm2-start.sh ]; then
                echo "正在创建 pm2-start.sh 脚本..."
                echo -e '#!/bin/bash\ncd ~/cysic-verifier/ && bash start.sh' > pm2-start.sh
                chmod +x pm2-start.sh
            fi

            echo "正在启动验证器..."
            if pm2 start ./pm2-start.sh --interpreter bash --name cysic-verifier; then
                echo "Cysic Verifier 启动完成，返回主菜单..."
            else
                echo "启动失败，请检查 PM2 和脚本。"
            fi
            ;;

        3)
            # 停止并删除验证器
            echo "正在停止并删除验证器..."
            pm2 stop cysic-verifier
            pm2 delete cysic-verifier
            echo "验证器已停止并删除，返回主菜单..."
            ;;

        4)
            # 删除第一阶段测试网的相关信息
            read -p "确认删除第一阶段测试网的相关信息吗？(y/n): " confirm
            if [ "$confirm" = "y" ]; then
                echo "正在删除第一阶段测试网的相关信息..."
                sudo rm -rf ~/cysic-verifier
                sudo rm -rf ~/.cysic
                sudo rm -rf ~/.scr*
                echo "第一阶段测试网的相关信息已删除，返回主菜单..."
            else
                echo "取消删除操作，返回主菜单。"
            fi
            ;;

        0)
            echo "退出程序。"
            exit 0
            ;;

        *)
            echo "无效的命令编号，请重新输入。"
            ;;
    esac
done
