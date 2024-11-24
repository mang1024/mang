#!/bin/bash

# 函数：检查命令是否成功执行
check_command() {
    if [ $? -ne 0 ]; then
        echo "命令执行失败: $1"
        exit 1
    fi

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

# 主菜单循环
while true; do
    echo "请选择命令:"
    echo "1. 下载配置环境并设置地址"
    echo "2. 启动验证器"
    echo "3. 停止并删除验证器"
    echo "4) 更新验证者（自动停止跟启动）"
    echo "5) 查看日志"
    echo "0. 退出"
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
            if [ ! -f pm2-start.sh ]; then
                echo "正在创建 pm2-start.sh 脚本..."
                echo -e '#!/bin/bash\ncd ~/cysic-verifier/ && bash start.sh' > pm2-start.sh
                chmod +x pm2-start.sh
            fi

            echo "正在启动验证器..."
            if pm2 start ./pm2-start.sh --interpreter bash --name cysic-verifier; then
                echo "Cysic Verifier 启动完成，返回主菜单..."
                
                # 启动 Node.js 监控脚本
                if [ ! -f ~/cysic-verifier/monitor.js ]; then
                    echo "监控脚本不存在，正在创建 monitor.js 脚本..."
                    cat << 'EOF' > ~/cysic-verifier/monitor.js
const { spawn } = require('child_process');
const fs = require('fs').promises;
const os = require('os');
const path = require('path');

const homeDir = os.homedir();
const logFilePath = path.join(homeDir, '.pm2/logs/cysic-verifier-error.log');
const outputLogFilePath = path.join(homeDir, '.pm2/logs/cysic-verifier-monitor.log');
const delay = 5 * 60 * 1000;

async function logMessage(message) {
    const timestamp = new Date().toISOString();
    const logEntry = `${timestamp} - ${message}\n`;
    try {
        await fs.appendFile(outputLogFilePath, logEntry);
        console.log(`Logged message: ${logEntry}`);
    } catch (err) {
        console.error(`Error writing to log file: ${err}`);
    }
}

setInterval(async () => {
    try {
        console.log('Checking log file...');
        const stats = await fs.stat(logFilePath);
        const lastModifiedTime = new Date(stats.mtime);
        const currentTime = new Date();
        const timeDiff = currentTime - lastModifiedTime;

        await logMessage(`Checked log file. Last modified time: ${lastModifiedTime.toISOString()}. Time since last update: ${timeDiff / 1000} seconds.`);

        if (timeDiff > delay) {
            const restartMessage = 'No log updates in the last minute. Restarting cysic-verifier...';
            await logMessage(restartMessage);
            restartPM2();
        } else {
            console.log('Log file has been updated recently.');
        }
    } catch (err) {
        console.error(`Error checking log file: ${err}`);
        await logMessage(`Error checking log file: ${err}`);
    }
}, delay);

function restartPM2() {
    console.log('Attempting to restart PM2 service...');
    const restart = spawn('pm2', ['restart', 'cysic-verifier']);
    
    restart.stdout.on('data', (data) => {
        const output = data.toString();
        console.log(`PM2 stdout: ${output}`);
        logMessage(`PM2 stdout: ${output}`);
    });

    restart.stderr.on('data', (data) => {
        const errorOutput = data.toString();
        console.error(`PM2 stderr: ${errorOutput}`);
        logMessage(`PM2 stderr: ${errorOutput}`);
    });

    restart.on('close', (code) => {
        const closeMessage = `pm2 restart process exited with code ${code}`;
        console.log(closeMessage);
        logMessage(closeMessage);
    });
}
EOF
                    chmod +x ~/cysic-verifier/monitor.js
                fi

                echo "正在启动监控脚本..."
                pm2 start ~/cysic-verifier/monitor.js --name cysic-verifier-monitor

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
            # 更新配置文件
            echo "正在停止验证器，2秒后执行更新。"
            pm2 stop cysic-verifier
            sleep 2
            curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/verifier_linux > ~/cysic-verifier/verifier
            curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/libdarwin_verifier.so > ~/cysic-verifier/libdarwin_verifier.so
            echo "更新完成，5秒后将重新启动验证器。"
            sleep 5
            chmod +x ~/cysic-verifier/verifier
            pm2 start cysic-verifier
            ;;

        5)
            # 查看 PM2 状态
            echo "正在获取 PM2 状态..."
            pm2 status
            ;;

        6)
            # 查看日志
            echo "正在查看 cysic-verifier 日志..."
            pm2 logs cysic-verifier
            ;;

        7)
            # 停止监控脚本
            echo "正在停止监控脚本..."
            pm2 stop cysic-verifier-monitor
            pm2 delete cysic-verifier-monitor
            echo "监控脚本已停止并删除，返回主菜单..."
            ;;

        8)
            # 退出脚本
            echo "正在退出..."
            exit 0
            ;;

        *)
            echo "无效的选项，请选择一个有效的菜单选项。"
            ;;
    esac
done
