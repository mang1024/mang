#!/bin/bash

echo "==========================================="
echo "     Cysic 验证者脚本 v2.1"
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

    echo "安装 Node.js 20.x LTS..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    echo "Node.js: $(node -v)"
    echo "npm: $(npm -v)"

    echo "安装 PM2..."
    sudo npm install pm2 -g
    
    echo "PM2: $(pm2 -v)"
}

# 检查并安装 PowerShell
install_powershell() {
    if ! command -v pwsh &> /dev/null; then
        echo "安装 PowerShell..."
        # 对于Ubuntu/Debian
        sudo apt-get install -y wget apt-transport-https
        wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt-get update
        sudo apt-get install -y powershell
        rm packages-microsoft-prod.deb
    fi
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
        if pm2 start "pwsh" --name "cysic-verifier$dir_num" -- -Command "./start.ps1"; then
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
    echo "1. 安装并启动验证者"
    echo "2. 停止并删除所有验证者"
    echo "3. 查看日志"
    echo "4. 增加虚拟内存"
    echo "5. 多开验证者"
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
            
            install_powershell

            read -p "奖励地址: " reward_address
            echo "下载配置..."
            if curl -L "https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/setup.ps1" -o "$HOME/setup_win.ps1"; then
                # 确保目录存在
                mkdir -p "$HOME/cysic-verifier"
                
                # 使用PM2启动PowerShell脚本
                pm2 start "pwsh" --name "cysic-setup" -- -Command "$HOME/setup_win.ps1 -CLAIM_REWARD_ADDRESS '$reward_address'"
                
                # 进入验证器目录并使用PM2启动
                cd "$HOME/cysic-verifier" || { echo "❌ 无法进入验证器目录"; exit 1; }
                pm2 start "pwsh" --name "cysic-verifier" -- -Command "./start.ps1"
                
                echo "✅ 验证者安装并启动成功"
            else
                echo "❌ 下载失败"
            fi
            ;;

        2)
            echo "停止所有验证器..."
            pm2 list | grep "cysic-verifier" | awk '{print $2}' | while read -r name; do
                pm2 stop "$name"
                pm2 delete "$name"
                echo "✅ 已停止并删除: $name"
            done
            echo "所有验证器已停止"
            ;;

        3)
            pm2 logs cysic-verifier
            ;;
            
        4)
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

        5)
            setup_multiple_verifiers
            ;;

        0)
            exit 0
            ;;

        *)
            echo "无效选项"
            ;;
    esac
done
