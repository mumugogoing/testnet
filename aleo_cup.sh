#!/bin/bash
# 关注作者twitter:   https://twitter.com/lovechickenroll
# 只精撸

Workspace=/root/aleo-prover
ScreenName=aleo
KeyFile="/root/aleo_key.txt"

is_root() {
	[[ $EUID != 0 ]] && echo -e "当前非root用户" && exit 1
}

has_screen(){
	Name=`screen -ls | grep ${ScreenName}`
	if [ -z "${Name}" ]
	then
		return 1
	else
		echo "screen 运行中：${Name}"
		return 0
	fi
}

has_private_key(){
	PrivateKey=$(cat ${KeyFile} | grep "Private key" | awk '{print $3}')	
	if [ -z "${PrivateKey}" ]
	then
		echo "密钥不存在！"
		return 1
	else
		echo "密钥可正常读取"
		return 0
	fi
}

generate_key(){
	cd ${Workspace}
	echo "开始生成账户密钥"
	./target/release/aleo-prover --new-address > ${KeyFile}

	has_private_key || exit 1

}


go_into_screen(){
	screen -D -r ${ScreenName}

}

kill_screen(){
	Name=`screen -ls | grep ${ScreenName}`
        if [ -z "${Name}" ]
        then
		echo "没有运行中的screen"
		exit 0
        else
		ScreenPid=${Name%.*}
		echo "强制关闭screen: ${Name}"
		kill ${ScreenPid}
		echo "强制关闭完成"
        fi
}

install_snarkos(){
	is_root

	mkdir ${Workspace}
        cd ${Workspace}

	sudo apt update
	sudo apt install git

	apt-get update
	apt-get install -y \
	    build-essential \
	    curl \
	    clang \
	    gcc \
	    libssl-dev \
	    llvm \
	    make \
	    pkg-config \
	    tmux \
	    xz-utils



	echo "开始安装rust"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  -s -- -y
	source $HOME/.cargo/env
	echo "rust安装成功!"

        echo "打开防火墙4133、4140和3033端口"
        sudo ufw allow 4133
        sudo ufw allow 3033
        sudo ufw allow 4140
        echo "防火墙设置完毕"

        echo "下载并编译HarukaMa/aleo-prover优化后代码"
        git clone https://github.com/HarukaMa/aleo-prover.git --depth 1 ${Workspace}
	cargo build --release
        echo "prover编译完成！"


	echo "开始安装screen"
	apt install screen
	echo "screen 安装成功！"

	has_private_key || generate_key


	echo “账户和密钥保存在 ${KeyFile}，请妥善保管，以下是详细信息：”
	cat ${KeyFile}
}

run_client(){
	echo "这次测试不需要跑client..." && exit 1
}

# 运行prover节点
run_prover(){
	source $HOME/.cargo/env

	cd ${Workspace}

	# 判断是否已经有screen存在了
        has_screen && echo "执行脚本命令5进入screen查看" && exit 1
	# 判断是否有密钥
        has_private_key || exit 1

	# 启动一个screen,并在screen中启动prover节点
        screen -dmS ${ScreenName}
	PrivateKey=$(cat ${KeyFile} | grep "Private key" | awk '{print $3}')
        echo "使用密钥${PrivateKey}启动prover节点"
	ThreadNum=`cat /proc/cpuinfo |grep "processor"|wc -l`  
        cmd=$"./target/release/aleo-prover -p ${PrivateKey} -t ${ThreadNum}"
	echo ${cmd}

        screen -x -S ${ScreenName} -p 0 -X stuff "${cmd}"
        screen -x -S ${ScreenName} -p 0 -X stuff $'\n'
        echo "client节点已在screen中启动，可执行脚本命令5 来查看节点运行情况"
	
}



echo && echo -e " 
aleo 一键脚本
twitter:   https://twitter.com/lovechickenroll
只精撸
 ———————————————————————
 1.install aleo
 2.run prover
 3.run client
 4.aleo key
 5.screen
 6.kill screen
 ———————————————————————
 " && echo

read -e -p " 请输入数字 [1-6]:" num
case "$num" in
1)
	install_snarkos
    	;;
2)
    	run_prover
    	;;
3)
    	run_client
    	;;
4)
    	cat ${KeyFile}
    	;;
5)
	go_into_screen
	;;
6)	
	kill_screen
	;;

*)
    echo
    echo -e "请输入正确的数字!"
    ;;
esac
