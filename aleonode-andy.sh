Crontab_file="/usr/bin/crontab"
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="[${Green_font_prefix}信息${Font_color_suffix}]"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"
Tip="[${Green_font_prefix}注意${Font_color_suffix}]"
check_root() {
    [[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}

install_git(){
    check_root
    apt-get install git
    git --version
}

install_cargo(){
    check_root
    apt install curl -y
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source "$HOME/.cargo/env"
    cargo --version
    mkdir ~/snarkOs/ && cd ~/snarkOs	
}
install_snarkOS(){
    check_root
    git clone https://github.com/AleoHQ/snarkOS.git --depth 1
    cd snarkOS
    ./build_ubuntu.sh
    cargo install --path .
}
up_node(){
    snarkos account new > ~/snarkOs/aleo.txt
    ./run-prover.sh
}

echo && echo -e " ${Red_font_prefix}Alea挖矿 一键安装脚本${Font_color_suffix} by \033[1;35mAndy\033[0m
此脚本完全免费开源，推特关注 ${Green_font_prefix}@lovechickenroll获取其他脚本${Font_color_suffix}，
欢迎关注，如有收费请勿上当受骗。
 ———————————————————————
 ${Green_font_prefix} 1.安装 git ${Font_color_suffix}
 ${Green_font_prefix} 2.安装 cargo ${Font_color_suffix}
 ${Green_font_prefix} 3.安装 SnarkOS  ${Font_color_suffix}
 ${Green_font_prefix} 4.启动 Aleo 挖矿结点  ${Font_color_suffix}
 ———————————————————————" && echo
read -e -p " 请输入数字 [1-4]:" num
case "$num" in
1)
    install_git
    ;;
2)
    install_cargo
    ;;
3)
    install_snarkOS
    ;;
4)
    up_node
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
}
