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
    command -v node &gt;/dev/null 2&gt;&amp;1 &amp;&amp; NODE_INSTALLED=true || NODE_INSTALLED=false
    command -v npm &gt;/dev/null 2&gt;&amp;1 &amp;&amp; NPM_INSTALLED=true || NPM_INSTALLED=false
    command -v pm2 &gt;/dev/null 2&gt;&amp;1 &amp;&amp; PM2_INSTALLED=true || PM2_INSTALLED=false
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
    if ! command -v pm2 &amp;&gt; /dev/null; then
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
    echo "6) 创建pm2监控配置文件并启动"
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
                echo -e '#!/bin/bash\ncd ~/cysic-verifier/ &amp;&amp; bash start.sh' &gt; pm2-start.sh
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
            #更新配置文件
            echo "正在停止验证器，2秒后执行更新。"
            pm2 stop cysic-verifier
            sleep 2
            curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/verifier_linux &gt; ~/cysic-verifier/verifier
            curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/libdarwin_verifier.so &gt; ~/cysic-verifier/libdarwin_verifier.so
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
            # 创建pm2监控配置文件并启动
            echo "创建 pm2 监控配置文件..."
            cat &lt;&lt; 'EOF' &gt; ~/cyjk.js
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
        console.log(`Logged message: ${logEntry}`); // 调试信息：确认日志已写入
    } catch (err) {
        console.error(`Error writing to log file: ${err}`);
    }
}

setInterval(async () =&gt; {
    try {
        console.log('Checking log file...'); // 调试信息：开始检查日志文件
        const stats = await fs.stat(logFilePath);
        console.log(`Log file stats retrieved: ${JSON.stringify(stats)}`); // 打印日志文件的状态

        const lastModifiedTime = new Date(stats.mtime);
        const currentTime = new Date();
        const timeDiff = currentTime - lastModifiedTime;

        await logMessage(`Checked log file. Last modified time: ${lastModifiedTime.toISOString()}. Time since last update: ${timeDiff / 1000} seconds.`);

        if (timeDiff &gt; delay) {
            const restartMessage = 'No log updates in the last minute. Restarting cysic-verifier...';
            await logMessage(restartMessage);
            restartPM2();
        } else {
            console.log('Log file has been updated recently.'); // 调试信息：最近有更新
        }
    } catch (err) {
        console.error(`Error checking log file: ${err}`);
        await logMessage(`Error checking log file: ${err}`);
    }
}, delay);

function restartPM2() {
    console.log('Attempting to restart PM2 service...'); // 调试信息：正在尝试重启
    const restart = spawn('pm2', ['restart', 'cysic-verifier']);
    
    restart.stdout.on('data', (data) =&gt; {
        const output = data.toString();
        console.log(`PM2 stdout: ${output}`); // 调试信息：PM2 的标准输出
        logMessage(`PM2 stdout: ${output}`); // 记录 PM2 的标准输出
    });

    restart.stderr.on('data', (data) =&gt; {
        const errorOutput = data.toString();
        console.error(`PM2 stderr: ${errorOutput}`); // 调试信息：PM2 的错误输出
        logMessage(`PM2 stderr: ${errorOutput}`); // 记录 PM2 的错误输出
    });

    restart.on('close', (code) =&gt; {
        const closeMessage = `pm2 restart process exited with code ${code}`;
        console.log(closeMessage); // 调试信息：重启进程结束
        logMessage(closeMessage);
    });
}
EOF

            chmod +x ~/cyjk.js
            pm2 start ~/cyjk.js
            echo "PM2 监控配置文件已创建并启动。"
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
