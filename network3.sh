#!/bin/bash

# 检查并停止原先的服务
cd ~/ubuntu-node 2>/dev/null || { echo "目录 ~/ubuntu-node 不存在，跳过停止服务步骤"; SKIP_STOP=true; }

if [ -z "$SKIP_STOP" ]; then
  # 检查 manager.sh 是否存在
  if [ -f manager.sh ]; then
    # 检查服务是否在运行
    if sudo bash manager.sh status | grep -q "running"; then
      sudo bash manager.sh down
      if [ $? -ne 0 ]; then
        echo "停止服务失败，退出脚本"
        exit 1
      else
        echo "已停止服务，等待3秒 自动跳转"
        sleep 3
      fi
    else
      echo "服务未运行，无需停止"
    fi
  else
    echo "manager.sh 脚本不存在，跳过停止服务"
  fi
fi

# 删除目录
cd ~ || { echo "无法切换到主目录，退出脚本"; exit 1; }
sudo rm -rf ~/ubuntu-node*
if [ $? -ne 0 ]; then
  echo "删除 ~/ubuntu-node* 目录失败，退出脚本"
  exit 1
else
  echo "已删除 ~/ubuntu-node* 目录，等待3秒 自动跳转"
  sleep 3
fi

sudo rm -rf ~/network*
if [ $? -ne 0 ]; then
  echo "删除 ~/network* 目录失败，退出脚本"
  exit 1
else
  echo "已删除 ~/network* 目录，等待3秒 自动跳转"
  sleep 3
fi

echo "所有操作完成"

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
