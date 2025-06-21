#!/bin/bash

echo "==========================================="
echo "     Cysic 验证者脚本 v3.0"
echo "     作者: mang"
echo "     免费分享"
echo "     国内网华为云慎用！"
echo "==========================================="

# 函数：检查命令是否成功执行
check_command() {
    if [ $? -ne 0 ]; then
        echo "❌ 执行失败: $1"
        exit 1
    fi
}

# 检查 PM2 是否已安装
check_installed() {
    command -v pm2 >/dev/null 2>&1 && PM2_INSTALLED=true || PM2_INSTALLED=false
}

# 安装 PM2
install_pm2() {
    echo "更新软件包..."
    sudo apt update
    check_command "更新软件包失败"

    echo "安装 Node.js 20.x LTS（PM2 依赖）..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    check_command "Node.js 安装失败"

    echo "安装 PM2..."
    sudo npm install pm2 -g
    check_command "PM2 安装失败"

    echo "PM2: $(pm2 -v)"
}

# 函数：设置多个验证者
setup_multiple_verifiers() {
    read -p "请输入需要启动的验证者数量: " verifier_count
    if [[ ! "$verifier_count" =~ ^[0-9]+$ ]] || [ "$verifier_count" -le 0 ]; then
        echo "❌ 请输入有效的正整数"
        return
    fi

    # 查找现有的验证者目录，确定下一个序号
    next_index=1
    while [ -d "$HOME/cysic-verifier$next_index" ]; do
        ((next_index++))
    done

    for ((i=1; i<=verifier_count; i++)); do
        current_index=$next_index
        ((next_index++))

        read -p "请输入第 $i 个验证者的奖励地址: " reward_address
        if [ -z "$reward_address" ]; then
            echo "❌ 奖励地址不能为空"
            return
        fi

        echo "创建验证者目录 cysic-verifier$current_index..."
        mkdir ~/cysic-verifier$current_index
        check_command "创建目录 cysic-verifier$current_index 失败"

        echo "复制 cysic-verifier 文件到 cysic-verifier$current_index..."
        cp -r ~/cysic-verifier/* ~/cysic-verifier$current_index/
        check_command "复制文件到 cysic-verifier$current_index 失败"

        echo "修改 config.yaml 中的奖励地址..."
        sed -i "s/claim_reward_address: \"0x[0-9a-fA-F]\{40\}\"/claim_reward_address: \"$reward_address\"/" ~/cysic-verifier$current_index/config.yaml
        check_command "修改 config.yaml 失败"

        echo "进入 cysic-verifier$current_index 目录..."
        cd ~/cysic-verifier$current_index || { echo "❌ 无法进入 cysic-verifier$current_index 目录"; exit 1; }

        echo "设置 start.sh 执行权限..."
        chmod +x start.sh
        check_command "设置 start.sh 执行权限失败"

        echo "启动 PM2 进程 cysic-verifier$current_index..."
        if pm2 start ./start.sh --name "cysic-verifier$current_index"; then
            echo "✅ 验证者 cysic-verifier$current_index 启动成功"
            pm2 save
        else
            echo "❌ PM2 启动 cysic-verifier$current_index 失败"
            exit 1
        fi

        # 返回主目录以便下一次循环
        cd ~ || { echo "❌ 无法返回主目录"; exit 1; }
    done
}

# 主菜单循环
while true; do
    echo "==========================================="
    echo "选择命令:"
    echo "1. 安装并启动验证者"
    echo "2. 停止并删除所有验证者"
    echo "3. 查看日志"
    echo "4. 增加虚拟内存"
    echo "0. 退出"
    echo "==========================================="
    read -p "输入命令: " command

    case $command in
        1)
            check_installed
            if [ "$PM2_INSTALLED" = false ]; then
                install_pm2
            else
                echo "PM2 已安装"
            fi

            read -p "奖励地址: " reward_address
            if [ -z "$reward_address" ]; then
                echo "❌ 奖励地址不能为空"
                exit 1
            fi

            echo "下载并运行配置脚本..."
            curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh
            check_command "下载 setup_linux.sh 失败"

            chmod +x ~/setup_linux.sh
            check_command "设置 setup_linux.sh 执行权限失败"

            bash ~/setup_linux.sh "$reward_address"
            check_command "运行 setup_linux.sh 失败"

            if [ ! -d "$HOME/cysic-verifier" ]; then
                echo "❌ cysic-verifier 目录未生成"
                exit 1
            fi

            if [ ! -f "$HOME/cysic-verifier/start.sh" ]; then
                echo "❌ start.sh 文件未生成"
                exit 1
            fi

            if [ ! -f "$HOME/cysic-verifier/config.yaml" ]; then
                echo "❌ config.yaml 文件未生成"
                exit 1
            fi

            cd ~/cysic-verifier || { echo "❌ 无法进入验证器目录"; exit 1; }
            chmod +x start.sh
            check_command "设置 start.sh 执行权限失败"

            echo "启动 PM2 进程..."
            if pm2 start "./start.sh" --name "cysic-verifier"; then
                echo "✅ 验证者安装并启动成功"
                pm2 save
            else
                echo "❌ PM2 启动失败"
                exit 1
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
 Bern                        else
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
