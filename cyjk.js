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

setInterval(async () => {
    try {
        console.log('Checking log file...'); // 调试信息：开始检查日志文件
        const stats = await fs.stat(logFilePath);
        console.log(`Log file stats retrieved: ${JSON.stringify(stats)}`); // 打印日志文件的状态

        const lastModifiedTime = new Date(stats.mtime);
        const currentTime = new Date();
        const timeDiff = currentTime - lastModifiedTime;

        await logMessage(`Checked log file. Last modified time: ${lastModifiedTime.toISOString()}. Time since last update: ${timeDiff / 1000} seconds.`);

        if (timeDiff > delay) {
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
    
    restart.stdout.on('data', (data) => {
        const output = data.toString();
        console.log(`PM2 stdout: ${output}`); // 调试信息：PM2 的标准输出
        logMessage(`PM2 stdout: ${output}`); // 记录 PM2 的标准输出
    });

    restart.stderr.on('data', (data) => {
        const errorOutput = data.toString();
        console.error(`PM2 stderr: ${errorOutput}`); // 调试信息：PM2 的错误输出
        logMessage(`PM2 stderr: ${errorOutput}`); // 记录 PM2 的错误输出
    });

    restart.on('close', (code) => {
        const closeMessage = `pm2 restart process exited with code ${code}`;
        console.log(closeMessage); // 调试信息：重启进程结束
        logMessage(closeMessage);
    });
}
