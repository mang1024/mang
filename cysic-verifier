#!/bin/bash

msgs_en=(
    "Choose language:"
    "Enter your choice: "
    "Invalid choice. Please try again."
    "One-click Start Cysic Verifier"
    "Install Node.js and PM2"
    "Download and configure Cysic Verifier"
    "Set reward address"
    "Start Verifier for the first time"
    "Manage Verifier with PM2"
    "Exit"
    "Change Language"
    "Enter reward address: "
    "Cysic Verifier configuration completed."
    "Verifier started. Press any key to return to the main menu..."
    "Invalid address format. Please enter a valid Ethereum address (0x followed by 40 hexadecimal characters)."
    "Failed to update reward address. Please check the config.yaml file manually."
    "PM2 configuration completed. The verifier will start automatically after system reboot."
    "Verifier is running. Press any key to stop and return to the main menu."
    "Verifier stopped."
    "View PM2 Verifier logs"
    "Stop PM2 Verifier"
    "Uninstall Cysic Verifier"
    "Viewing PM2 Verifier logs. Press Ctrl+C to exit."
    "PM2 Verifier stopped."
    "Uninstalling Cysic Verifier..."
    "Cysic Verifier has been uninstalled."
    "Configure Swap Memory"
    "Swap memory configured successfully."
    "Synchronizing block information（Only applicable for first-time node users）"
)

msgs_zh=(
    "选择语言："
    "请输入您的选择： "
    "无效的选择。请重试。"
    "一键启动Cysic Verifier"
    "安装 Node.js 和 PM2"
    "下载并配置 Cysic 验证器"
    "设置奖励地址"
    "首次启动验证器"
    "使用 PM2 管理验证器"
    "退出"
    "更改语言"
    "输入奖励地址： "
    "Cysic 验证器配置完成。"
    "验证器已启动。按任意键返回主菜单..."
    "地址格式无效。请输入有效的以太坊地址（0x 后跟 40 个十六进制字符）。"
    "更新奖励地址失败。请手动检查 config.yaml 文件。"
    "PM2 配置完成。系统重启后验证器将自动启动。"
    "验证器正在运行。按任意键停止并返回主菜单。"
    "验证器已停止。"
    "查看 PM2 验证器日志"
    "停止 PM2 验证器"
    "卸载 Cysic 验证器"
    "正在查看 PM2 验证器日志。按 Ctrl+C 退出。"
    "PM2 验证器已停止。"
    "正在卸载 Cysic 验证器..."
    "Cysic 验证器已卸载。"
    "配置 Swap 内存"
    "Swap 内存配置成功。"
    "同步区块信息（仅适用首次运行节点用户）"
)
msgs_ko=(
    "언어 선택:"
    "선택을 입력하세요: "
    "잘못된 선택입니다. 다시 시도해주세요."
    "원클릭 Cysic Verifier 시작"
    "Node.js 및 PM2 설치"
    "Cysic 검증자 다운로드 및 구성"
    "보상 주소 설정"
    "검증자 처음 시작"
    "PM2로 검증자 관리"
    "종료"
    "언어 변경"
    "보상 주소 입력: "
    "Cysic 검증자 구성이 완료되었습니다."
    "검증자가 시작되었습니다. 아무 키나 눌러 메인 메뉴로 돌아가세요..."
    "잘못된 주소 형식입니다. 유효한 이더리움 주소를 입력하세요 (0x 다음에 40개의 16진수 문자)."
    "보상 주소 업데이트에 실패했습니다. config.yaml 파일을 수동으로 확인해주세요."
    "PM2 구성이 완료되었습니다. 시스템 재부팅 후 검증자가 자동으로 시작됩니다."
    "검증자가 실행 중입니다. 아무 키나 눌러 중지하고 메인 메뉴로 돌아가세요."
    "검증자가 중지되었습니다."
    "PM2 검증자 로그 보기"
    "PM2 검증자 중지"
    "Cysic 검증자 제거"
    "PM2 검증자 로그를 보고 있습니다. 종료하려면 Ctrl+C를 누르세요."
    "PM2 검증자가 중지되었습니다."
    "Cysic 검증자를 제거하는 중..."
    "Cysic 검증자가 제거되었습니다."
    "스왑 메모리 구성"
    "스왑 메모리가 성공적으로 구성되었습니다."
    "블록 정보 동기화（노드 최초 실행 사용자에게만 적용）"

)

LANG_OPTIONS=("English" "中文" "한국어")

LANGUAGE=2
msgs=("${msgs_zh[@]}")

change_language() {
    echo "${msgs[0]}"
    for i in "${!LANG_OPTIONS[@]}"; do
        echo "$((i+1))) ${LANG_OPTIONS[$i]}"
    done
    read -p "${msgs[1]}" lang_choice
    if [[ $lang_choice -ge 1 && $lang_choice -le 3 ]]; then
        LANGUAGE=$lang_choice
        case $LANGUAGE in
            1) msgs=("${msgs_en[@]}") ;;
            2) msgs=("${msgs_zh[@]}") ;;
            3) msgs=("${msgs_ko[@]}") ;;
        esac
    else
        echo "${msgs[2]}"
    fi
}

show_menu() {
    echo "----------------------------------------"
    echo "${msgs[3]}"
    case $LANGUAGE in
        1)  # English
            echo "Free sharing----------作者: mang"
            echo "If you have any questions, please contact us on Discord"
            echo "----------------------------------------"
            echo "1. Change Language"
            echo "2. Download, Install and Configure Environment"
            echo "3. Set Reward Address"
            echo "4. Temporarily Start Verifier (If this is your first run, please do not use this command)"
            echo "5. Start Verifier"
            echo "6. View Block Information"
            echo "7. Stop Verifier"
            echo "8. Uninstall Verifier"
            echo "9. Exit"
            echo "10. Extend Memory (Run this command if killed due to insufficient memory)"
            echo "11. ${msgs[28]}"  
            ;;
        2)  # 中文
            echo "免费分享----------作者: mang"
            echo "如果有任何问题，请在Discord 联系"
            echo "----------------------------------------"
            echo "1. 选择语言"
            echo "2. 下载安装配置环境"
            echo "3. 设置奖励地址"
            echo "4. 临时启动验证器（如果首次运行，请不要使用此命令）"
            echo "5. 启动验证器"
            echo "6. 查看区块信息"
            echo "7. 停止运行验证器"
            echo "8. 卸载验证器"
            echo "9. 退出"
            echo "10. 扩展内存（如果因内存不足，killed）运行此命令"
            echo "11. ${msgs[28]}"  # 同步区块信息（仅适用首次运行节点用户）
            ;;
        3)  # 한국어
            echo "무료 공유----------作者: mang"
            echo "문의 사항이 있으시면 Discord로 연락해 주세요"
            echo "----------------------------------------"
            echo "1. 언어 선택"
            echo "2. 환경 다운로드, 설치 및 구성"
            echo "3. 보상 주소 설정"
            echo "4. Verifier 임시 시작 (처음 실행하는 경우 이 명령어를 사용하지 마세요)"
            echo "5. Verifier 시작"
            echo "6. 블록 정보 보기"
            echo "7. Verifier 중지"
            echo "8. Verifier 제거"
            echo "9. 종료"
            echo "10. 메모리 확장 (메모리 부족으로 종료된 경우 이 명령어를 실행하세요)"
            echo "11. ${msgs[28]}"  
            ;;
    esac
    echo "----------------------------------------"
    echo "${msgs[9]} / : 9 or Ctrl+C"
    echo "----------------------------------------"
}

configure_swap() {
    sudo -i <<EOF
swapoff /swapfile.img
rm /swapfile.img
fallocate -l 6G /swapfile.img
chmod 600 /swapfile.img
mkswap /swapfile.img
swapon /swapfile.img
echo '/swapfile.img swap swap defaults 0 0' >> /etc/fstab
exit
EOF
    echo "${msgs[27]}"  
}

install_and_configure_verifier() {
    echo "Installing Node.js and PM2..."
    if ! curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -; then
        echo "Failed to add NodeSource repository. Trying alternative method..."
        sudo apt update
        if ! curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -; then
            echo "Failed to add NodeSource repository for Node.js 16.x. Exiting."
            return 1
        fi
    fi

    if ! sudo apt-get install -y nodejs; then
        echo "Failed to install Node.js. Exiting."
        return 1
    fi

    node -v
    npm -v

    if ! sudo npm install pm2 -g; then
        echo "Failed to install PM2 using npm. Trying alternative method..."
        if ! sudo apt install -y npm && sudo npm install pm2 -g; then
            echo "Failed to install PM2. Exiting."
            return 1
        fi
    fi

    pm2 -v

    echo "Configuring Cysic Verifier..."
    rm -rf ~/cysic-verifier
    cd ~
    mkdir cysic-verifier
    curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/verifier_linux > ~/cysic-verifier/verifier
    curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/libzkp.so > ~/cysic-verifier/libzkp.so
    chmod +x ~/cysic-verifier/verifier
    
    cat << EOF > ~/cysic-verifier/config.yaml
chain:
  endpoint: "testnet-node-1.prover.xyz:9090"
  chain_id: "cysicmint_9000-1"
  gas_coin: "cysic"
  gas_price: 10
claim_reward_address: "0x696969"

server:
  cysic_endpoint: "https://api-testnet.prover.xyz"
EOF

    echo "${msgs[12]}"  # Cysic Verifier configuration completed.
    echo "Please remember to modify the claim_reward_address in ~/cysic-verifier/config.yaml"
}

set_reward_address() {
    read -p "${msgs[11]}" reward_address
    if [[ ! "$reward_address" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        echo "${msgs[14]}"
        return
    fi
    
    sed -i "s|claim_reward_address: \"0x.*\"|claim_reward_address: \"$reward_address\"|" ~/cysic-verifier/config.yaml

    if grep -q "claim_reward_address: \"$reward_address\"" ~/cysic-verifier/config.yaml; then
        echo "${msgs[12]}"
    else
        echo "${msgs[15]}"
    fi
}

start_verifier() {
    cd ~/cysic-verifier/
    export LD_LIBRARY_PATH=.:~/miniconda3/lib
    export CHAIN_ID=534352
    chmod +x verifier
    
    echo "${msgs[13]}"  
    
    timeout --foreground --preserve-status 86400 ./verifier &
    verifier_pid=$!
    
    echo "${msgs[17]}"  
    read -n 1 -s -r
    
    kill $verifier_pid 2>/dev/null
    
    sleep 2
    clear
}

manage_verifier_pm2() {
    cat << EOF > ~/cysic-verifier/start.sh
#!/bin/bash
export LD_LIBRARY_PATH=.:~/miniconda3/lib
export CHAIN_ID=534352
cd ~/cysic-verifier
./verifier
EOF

    chmod +x ~/cysic-verifier/start.sh

    pm2 start ~/cysic-verifier/start.sh --name cysic-verifier

    pm2 startup
    pm2 save

    read -n 1 -s -r
    clear
    show_menu
}

view_pm2_logs() {
    echo "${msgs[22]}"
    pm2 logs cysic-verifier
}

stop_pm2_verifier() {
    pm2 stop cysic-verifier
    echo "${msgs[23]}"
}

uninstall_verifier() {
    echo "${msgs[24]}"
    pm2 delete cysic-verifier 2>/dev/null
    rm -rf ~/cysic-verifier
    echo "${msgs[25]}"
}

download_and_replace_file() {
    echo "${msgs[28]}"  # "Synchronizing block information (Only applicable for first-time node users)"
    
    echo "Stopping cysic-verifier..."
    pm2 stop cysic-verifier

    sudo apt update
    sudo apt install -y python3-pip

    pip3 install gdown

    echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
    source ~/.bashrc

    TARGET_DIR="$HOME/cysic-verifier/data"
    FILE_PATH="$TARGET_DIR/cysic-verifier.db"
    DOWNLOAD_URL="https://drive.google.com/uc?id=10IzB5-N8CpR9bUwBA1SXqXsOV40IHtY0"

    mkdir -p "$TARGET_DIR"

    echo "Attempting to download file from Google Drive..."
    echo "Download URL: $DOWNLOAD_URL"
    echo "Target Directory: $TARGET_DIR"
    echo "File Path: $FILE_PATH"

    if gdown "$DOWNLOAD_URL" -O "$FILE_PATH"; then
        echo "Download successful. Setting file permissions..."
        sudo chown "$(whoami):$(whoami)" "$FILE_PATH"

        echo "Download completed. File saved at $FILE_PATH"

        # 重启 cysic-verifier
        echo "Restarting cysic-verifier..."
        pm2 restart cysic-verifier

        echo "Process completed."
    else
        echo "Download failed. Restarting cysic-verifier without changes..."
        pm2 restart cysic-verifier
    fi

    rm -f /tmp/cookie

    cd -
}

while true; do
    show_menu
    read -p "${msgs[1]}" choice
    case $choice in
        1) change_language ;;
        2) install_and_configure_verifier ;;  # 合并后的新函数
        3) set_reward_address ;;
        4) start_verifier ;;
        5) manage_verifier_pm2 ;;
        6) view_pm2_logs ;;
        7) stop_pm2_verifier ;;
        8) uninstall_verifier ;;
        9) exit 0 ;;
        10) configure_swap ;; 
        11) download_and_replace_file ;;
        *) echo "${msgs[2]}" ;;
    esac
    echo
done
