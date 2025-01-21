#!/bin/bash

echo "==========================================="
echo "     Cysic 验证者脚本 v2.0"
echo "     作者: mang"
echo "     免费分享，请勿商用"
echo "     国内网华为云慎用！！！"
echo "     国内网华为云慎用！！"
echo "==========================================="

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

    echo "正在安装 Node.js 和 PM2..."
    if ! curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -; then
        echo "添加 NodeSource 仓库失败，尝试备用方法..."
        if ! curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -; then
            echo "添加 NodeSource 仓库失败，退出。"
            exit 1
        fi
    fi

    if ! sudo apt-get install -y nodejs; then
        echo "安装 Node.js 失败，退出。"
        exit 1
    fi

    echo "Node.js 版本: $(node -v)"
    echo "npm 版本: $(npm -v)"

    # 检查 PM2 是否已安装
    if ! command -v pm2 &> /dev/null; then
        echo "PM2 未安装，正在安装..."
        if ! sudo npm install pm2 -g; then
            echo "通过 npm 安装 PM2 失败，退出。"
            exit 1
        fi
    else
        echo "PM2 已安装，跳过安装。"
    fi

    echo "PM2 版本: $(pm2 -v)"
}

# 设置多开验证者
setup_multiple_verifiers() {
    # 检查基础验证者是否存在
    if [ ! -d "$HOME/cysic-verifier" ]; then
        echo "❌ 基础验证者不存在，请先执行选项1安装！！"
        return 1
    fi

    read -p "请输入要多开的数量: " num_instances
    if ! [[ "$num_instances" =~ ^[0-9]+$ ]] || [ "$num_instances" -lt 1 ]; then
        echo "❌ 请输入有效的正整数！"
        return 1
    fi

    for ((i=1; i<=num_instances; i++)); do
        # 找到可用的目录编号
        dir_num=1
        while [ -d "$HOME/cysic-verifier$dir_num" ]; do
            ((dir_num++))
        done
        
        echo "----------------------------------------"
        echo "正在设置第 $i 个验证者（将使用编号 $dir_num）"
        read -p "请输入奖励地址: " reward_address
        
        # 创建新的验证者目录
        echo "正在创建验证者 $dir_num..."
        mkdir -p "$HOME/cysic-verifier$dir_num"
        cp -r "$HOME/cysic-verifier/"* "$HOME/cysic-verifier$dir_num/"
        
        # 更新配置文件
        if ! sed -i "s|claim_reward_address: \".*\"|claim_reward_address: \"$reward_address\"|" "$HOME/cysic-verifier$dir_num/config.yaml"; then
            echo "❌ 更新配置文件失败！"
            continue
        fi
        
        # 启动新的验证者
        cd "$HOME/cysic-verifier$dir_num" || continue
        if pm2 start start.sh --name "cysic-verifier$dir_num"; then
            echo "✅ 验证者 $dir_num 启动成功！"
        else
            echo "❌ 验证者 $dir_num 启动失败！"
        fi
        echo "----------------------------------------"
    done
    
    echo "✅ 多开设置完成！当前运行的验证者："
    pm2 list | grep cysic-verifier
}

# 主菜单循环
while true; do
    echo "==========================================="
    echo "请选择命令:"
    echo "1. 下载配置环境并设置地址"
    echo "2. 启动验证器"
    echo "3. 停止并删除验证器"
    echo "4. 更新验证者"
    echo "5. 查看日志"
    echo "6. 增加虚拟内存"
    echo "7. 多开验证者"
    echo "0. 退出"
    echo "==========================================="
    read -p "请输入命令: " command

    case $command in
        1)
            check_installed
            if [ "$NODE_INSTALLED" = false ] || [ "$NPM_INSTALLED" = false ] || [ "$PM2_INSTALLED" = false ]; then
                install_dependencies
            else
                echo "Node.js、npm 和 PM2 已安装，跳过安装。"
            fi
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
            echo "正在启动验证器..."
            cd ~/cysic-verifier/
            if pm2 start start.sh --name cysic-verifier; then
                echo "✅ Cysic Verifier 启动成功！"
            else
                echo "❌ 启动失败，请检查验证器配置。"
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
            # 更新配置文件
            echo "正在停止验证器，2秒后执行更新。"
            pm2 stop cysic-verifier
            sleep 2
            sudo rm -rf ~/cysic-verifier/data
            curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/verifier_linux > ~/cysic-verifier/verifier
            curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/libdarwin_verifier.so > ~/cysic-verifier/libdarwin_verifier.so
            echo "更新完成，5秒后将重新启动验证器。"
            sleep 5
            chmod +x ~/cysic-verifier/verifier
            pm2 start cysic-verifier
            ;;

        5)
            # 查看验证器日志
            echo "正在查看验证器日志..."
            pm2 logs cysic-verifier
            echo "按 Ctrl+C 退出日志查看。"
            ;;
            
        6)
            # 增加虚拟内存
            read -p "请输入想要增加的虚拟内存大小(GB): " swap_size
            if [[ "$swap_size" =~ ^[0-9]*\.?[0-9]+$ ]] && (( $(echo "$swap_size > 0" | bc -l) )); then
                echo "正在创建 ${swap_size}GB 虚拟内存..."
                if sudo fallocate -l ${swap_size}G /swapfile; then
                    sudo chmod 600 /swapfile
                    sudo mkswap /swapfile
                    if sudo swapon /swapfile; then
                        echo "✅ 虚拟内存创建成功！"
                        echo "当前系统内存使用情况："
                        free -h
                    else
                        echo "❌ 启用虚拟内存失败！"
                    fi
                else
                    echo "❌ 创建虚拟内存文件失败！"
                fi
            else
                echo "❌ 请输入有效的正数！"
            fi
            ;;

        7)
            setup_multiple_verifiers
            ;;

        0)
            echo "感谢使用，欢迎加入电报群交流：https://t.me/mangmang888"
            echo "退出程序。"
            exit 0
            ;;

        *)
            echo "无效选项，请选择有效的菜单选项。"
            echo "无效的命令编号，请重新输入。"
            ;;
    esac
done
