#!/bin/bash

echo "==========================================="
echo "     Cysic 验证者脚本 v2.0"
echo "     作者: mang"
echo "     免费分享，请勿商用"
echo "     国内网华为云慎用！"
echo "==========================================="

# 函数：检查命令是否成功执行
check_command() {
    if [ $? -ne 0 ]; then
        echo "执行失败: $1"
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
    echo "更新软件包..."
    sudo apt update
    check_command "更新失败"

    echo "安装 Node.js..."
    if ! curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -; then
        echo "尝试备用源..."
        if ! curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -; then
            echo "源添加失败"
            exit 1
        fi
    fi

    if ! sudo apt-get install -y nodejs; then
        echo "安装失败"
        exit 1
    fi

    echo "Node.js: $(node -v)"
    echo "npm: $(npm -v)"

    if ! command -v pm2 &> /dev/null; then
        echo "安装 PM2..."
        if ! sudo npm install pm2 -g; then
            echo "PM2 安装失败"
            exit 1
        fi
    fi

    echo "PM2: $(pm2 -v)"
}

# 设置多开验证者
setup_multiple_verifiers() {
    if [ ! -d "$HOME/cysic-verifier" ]; then
        echo "❌ 请先执行选项1安装基础验证者"
        return 1
    fi

    read -p "多开数量: " num_instances
    if ! [[ "$num_instances" =~ ^[0-9]+$ ]] || [ "$num_instances" -lt 1 ]; then
        echo "❌ 请输入正确数字"
        return 1
    fi

    for ((i=1; i<=num_instances; i++)); do
        dir_num=1
        while [ -d "$HOME/cysic-verifier$dir_num" ]; do
            ((dir_num++))
        done
        
        echo "----------------------------------------"
        echo "设置第 $i 个验证者（编号 $dir_num）"
        read -p "奖励地址: " reward_address
        
        echo "创建验证者 $dir_num..."
        mkdir -p "$HOME/cysic-verifier$dir_num"
        cp -r "$HOME/cysic-verifier/"* "$HOME/cysic-verifier$dir_num/"
        
        if ! sed -i "s|claim_reward_address: \".*\"|claim_reward_address: \"$reward_address\"|" "$HOME/cysic-verifier$dir_num/config.yaml"; then
            echo "❌ 配置失败"
            continue
        fi
        
        cd "$HOME/cysic-verifier$dir_num" || continue
        if pm2 start start.sh --name "cysic-verifier$dir_num"; then
            echo "✅ 验证者 $dir_num 已启动"
        else
            echo "❌ 启动失败"
        fi
        echo "----------------------------------------"
    done
    
    echo "✅ 多开完成，当前运行："
    pm2 list | grep cysic-verifier
}

# 主菜单循环
while true; do
    echo "==========================================="
    echo "选择命令:"
    echo "1. 安装环境及验证者"
    echo "2. 启动验证器"
    echo "3. 停止并删除验证器"
    echo "4. 更新验证器"
    echo "5. 查看日志"
    echo "6. 增加虚拟内存"
    echo "7. 多开验证者"
    echo "0. 退出"
    echo "==========================================="
    read -p "输入命令: " command

    case $command in
        1)
            check_installed
            if [ "$NODE_INSTALLED" = false ] || [ "$NPM_INSTALLED" = false ] || [ "$PM2_INSTALLED" = false ]; then
                install_dependencies
            else
                echo "环境已安装"
            fi

            read -p "奖励地址: " reward_address
            echo "下载配置..."
            if curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh -o ~/setup_linux.sh; then
                bash ~/setup_linux.sh "$reward_address"
            else
                echo "下载失败"
            fi
            ;;

        2)
            echo "启动验证器..."
            cd ~/cysic-verifier/
            if pm2 start start.sh --name cysic-verifier; then
                echo "✅ 启动成功"
            else
                echo "❌ 启动失败"
            fi
            ;;

        3)
            echo "停止验证器..."
            pm2 stop cysic-verifier
            pm2 delete cysic-verifier
            echo "已停止"
            ;;

        4)
            echo "更新验证者..."
            pm2 stop cysic-verifier
            sleep 2
            sudo rm -rf ~/cysic-verifier/data
            curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/verifier_linux > ~/cysic-verifier/verifier
            curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/libdarwin_verifier.so > ~/cysic-verifier/libdarwin_verifier.so
            chmod +x ~/cysic-verifier/verifier
            sleep 2
            pm2 start cysic-verifier
            echo "更新完成"
            ;;

        5)
            pm2 logs cysic-verifier
            ;;
            
        6)
            read -p "虚拟内存大小(GB): " swap_size
            if [[ "$swap_size" =~ ^[0-9]*\.?[0-9]+$ ]] && (( $(echo "$swap_size > 0" | bc -l) )); then
                echo "创建 ${swap_size}GB 虚拟内存..."
                if sudo fallocate -l ${swap_size}G /swapfile; then
                    sudo chmod 600 /swapfile
                    sudo mkswap /swapfile
                    if sudo swapon /swapfile; then
                        echo "✅ 创建成功"
                        free -h
                    else
                        echo "❌ 启用失败"
                    fi
                else
                    echo "❌ 创建失败"
                fi
            else
                echo "❌ 输入无效"
            fi
            ;;

        7)
            setup_multiple_verifiers
            ;;

        0)
            echo "欢迎加入电报群：https://t.me/mangmang888"
            exit 0
            ;;

        *)
            echo "无效选项"
            ;;
    esac
done
