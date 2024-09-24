#!/bin/bash

function check_and_set_permissions() {
    echo "检查和设置权限..."
    
    if [ ! -x "$0" ]; then
        chmod +x "$0"
    fi
    
    if [ -d ~/cysic-verifier ]; then
        chmod 755 ~/cysic-verifier
    fi
    
    if [ -f ~/cysic-verifier/verifier ]; then
        chmod 755 ~/cysic-verifier/verifier
    fi
    if [ -f ~/cysic-verifier/libzkp.dylib ]; then
        chmod 644 ~/cysic-verifier/libzkp.dylib
    fi
    
    echo "权限检查和设置完成。"
}

function download_and_configure() {
    echo "开始下载并配置 Cysic Verifier..."
    
    rm -rf ~/cysic-verifier
    cd ~
    mkdir cysic-verifier
    curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/verifier_mac > ~/cysic-verifier/verifier
    curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/libzkp.dylib > ~/cysic-verifier/libzkp.dylib

    cat << EOF > ~/cysic-verifier/config.yaml
# Not Change
chain:
  # Not Change
  endpoint: "testnet-node-1.prover.xyz:9090"
  # Not Change
  chain_id: "cysicmint_9000-1"
  # Not Change
  gas_coin: "cysic"
  # Not Change
  gas_price: 10
  # Modify Here： ! Your Address (EVM) submitted to claim rewards
claim_reward_address: "0x696969696969"

server:
  # don't modify this
  cysic_endpoint: "https://api-testnet.prover.xyz"
EOF

    echo "请输入您的奖励地址（EVM地址）："
    read reward_address
    
    sed -i '' "s/0x696969696969/$reward_address/" ~/cysic-verifier/config.yaml
    
    echo "配置完成。您的奖励地址已更新为：$reward_address"
    echo "配置文件内容如下："
    cat ~/cysic-verifier/config.yaml
    
    # 设置下载的文件权限
    chmod 755 ~/cysic-verifier/verifier
    chmod 644 ~/cysic-verifier/libzkp.dylib
}

function start_verifier() {
    echo "正在启动 Cysic Verifier..."
    cd ~/cysic-verifier/
    DYLD_LIBRARY_PATH=".:~/miniconda3/lib:$DYLD_LIBRARY_PATH" CHAIN_ID=534352 ./verifier
}

# 在脚本开始时检查和设置权限
check_and_set_permissions

while true; do
    echo
    echo "Cysic Verifier 控制面板"
    echo "1. 下载并配置 Cysic Verifier"
    echo "2. 启动 Cysic Verifier"
    echo "3. 退出"
    echo
    read -p "请选择操作 (1-3): " choice

    case $choice in
        1)
            download_and_configure
            ;;
        2)
            start_verifier
            ;;
        3)
            echo "感谢使用，再见！"
            exit 0
            ;;
        *)
            echo "无效的选择，请重新输入。"
            ;;
    esac

    echo
    read -p "按回车键继续..."
done
