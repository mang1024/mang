#!/bin/bash
#停止原先的
cd ubuntu-node
sudo bash manager.sh down
echo "已停止，等待3秒 自动跳转"
sleep 3

#删除目录
cd ..
sudo rm -rf ~/ubuntu-node*
echo "已删除原先的配置，等待3秒，自动跳转"
sleep 3

# 下载并解压 ubuntu-node-v1.0
wget https://network3.io/ubuntu-node-v2.1.0.tar
tar -xf ubuntu-node-v2.1.0.tar

# 切换到目录并运行 manager.sh up
cd ubuntu-node
sudo bash manager.sh up

# 返回上级目录
cd ..
wget https://network3.io/ubuntu-node-v2.1.0.tar
tar -xf ubuntu-node-v2.1.0.tar

# 切换到目录并运行 manager.sh key
cd ubuntu-node
sudo bash manager.sh key

# 给 manager.sh 赋予执行权限
sudo chmod +x manager.sh

echo "成功执行,请复制的key 绑定你的账号"
