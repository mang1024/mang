#!/bin/bash

# 更新软件包列表并安装 Node.js 和 npm
echo "正在更新软件包列表并安装 Node.js 和 npm..."
sudo apt update
sudo apt install -y nodejs npm

# 全局安装 PM2
echo "正在全局安装 PM2..."
sudo npm install -g pm2

# 验证安装是否成功
echo "验证安装是否成功..."
node --version
npm --version
pm2 --version

# 删除之前的配置信息
echo "正在删除之前的配置信息..."
rm -rf ~/cysic-verifier
rm -rf ~/.cysic
cd ~

# 提示用户输入奖励地址
read -p "请输入你的实际奖励地址: " reward_address

# 下载并配置验证器
echo "正在下载并配置验证器..."
curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh
bash ~/setup_linux.sh "$reward_address"

# 确保 start.sh 可执行并使用 PM2 启动验证器
echo "确保 start.sh 可执行并使用 PM2 启动验证器..."
chmod +x ~/cysic-verifier/start.sh
pm2 start ~/cysic-verifier/start.sh --name cysic-verifier

# 设置 PM2 在系统重启后自动启动
echo "设置 PM2 在系统重启后自动启动..."
pm2 startup
pm2 save

echo "Cysic Verifier 安装和配置完成！"
