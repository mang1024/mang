#!/bin/bash

# 尝试切换目录并停止服务
cd ~/ubuntu-node
sudo bash manager.sh down
echo "尝试停止服务"

# 删除目录
cd ~
sudo rm -rf ~/ubuntu-node*
echo "尝试删除 ~/ubuntu-node* 目录"

sudo rm -rf ~/network*
echo "尝试删除 ~/network* 目录"

# 下载并解压 ubuntu-node-v2.1.0
wget https://network3.io/ubuntu-node-v2.1.0.tar
tar -xf ubuntu-node-v2.1.0.tar
echo "下载并解压 ubuntu-node-v2.1.0"

# 切换到目录并运行 manager.sh up
cd ubuntu-node
sudo bash manager.sh up
echo "运行 manager.sh up"

# 返回上级目录并再次下载和解压
cd ..
wget https://network3.io/ubuntu-node-v2.1.0.tar
tar -xf ubuntu-node-v2.1.0.tar
echo "再次下载并解压 ubuntu-node-v2.1.0"

# 切换到目录并运行 manager.sh key
cd ubuntu-node
sudo bash manager.sh key
echo "运行 manager.sh key"

# 给 manager.sh 赋予执行权限
sudo chmod +x manager.sh
echo "赋予 manager.sh 执行权限"

echo "成功执行，请复制 key 绑定你的账号"
