#!/bin/bash
if [[ $EUID -ne 0 ]]
then
    clear
    echo "错误：本脚本需要 root 权限执行。" 1>&2
    exit 1
fi

welcome() {
  echo ""
  echo "安装即将开始"
  echo "如果您想取消安装，"
  echo "请在 3 秒钟内按 Ctrl+C 终止此脚本。"
  echo ""
  sleep 3
}

docker_check() {
  echo "正在检查 Docker 安装情况 . . ."
  if command -v docker >> /dev/null 2>&1;
  then
    echo "Docker 已存在, 安装过程继续 . . ."
  else
    echo "Docker 未安装在此系统上"
    echo "终端执行 curl -sSL https://get.daocloud.io/docker | sh"
    echo "安装后重新运行此脚本。"
    exit 1
  fi
}

access_check() {
  echo "测试 Docker 环境 . . ."
  if [ -w /var/run/docker.sock ]
  then
    echo "该用户可以使用 Docker , 安装过程继续 . . ."
  else
    echo "该用户无权访问 Docker"
    echo "在终端执行 usermod -aG docker your-user 后重新运行脚本"
    exit 1
  fi
}

build_aria2() {
  printf "请输入Aria2 RPC 密钥："
  read -r rpc_secret <&1
  echo "正在拉取 Aria2-Pro 镜像 . . ."
  docker rm -f aria2-pro > /dev/null 2>&1
  docker pull p3terx/aria2-pro
}

start_aria2() {
  echo "正在启动 Aria2-Pro . . ."
  sleep 3
  docker run -d --name=aria2-pro --restart unless-stopped --log-opt max-size=1m -e PUID=$UID -e PGID=$GID -p 6800:6800 -e RPC_SECRET="$rpc_secret" -e LISTEN_PORT=6888 -p 6888:6888 -p 6888:6888/udp -v $PWD/aria2/config:/config -v $PWD/aria2/downloads:/downloads p3terx/aria2-pro <&1
  echo ""
  echo "已启动"
  echo ""
  shon_online
}

start_installation() {
  welcome
  docker_check
  access_check
  build_aria2
  start_aria2
}

clean_aria2(){
  echo "正在删除 Aria2-Pro 镜像 . . ."
  docker rm -f aria2-pro
  docker rmi p3terx/aria2-pro:latest
  rm -rf $PWD/aria2
  echo ""
  echo "已删除"
  echo ""
  shon_online
}

stop_pager(){
  echo "正在停止 Aria2-Pro . . ."
  docker stop aria2-pro
  echo ""
  echo "已停止"
  echo ""
  shon_online
}

start_pager(){
  echo "正在启动 Aria2-Pro . . ."
  docker start aria2-pro
  echo ""
  echo "已启动"
  echo ""
  shon_online
}

restart_pager(){
  echo "正在重新启动 Aria2-Pro . . ."
  docker restart aria2-pro
  echo ""
  echo "已重启"
  echo ""
  shon_online
}

reinstall_pager(){
  build_aria2
  start_aria2
}

build_ariang() {
  echo "正在拉取 AriaNG 镜像 . . ."
  docker pull p3terx/ariang
}

start_ariang() {
  echo "正在启动 AriaNG . . ."
  sleep 3
  docker run -d --name ariang --log-opt max-size=1m --restart unless-stopped -p 6880:6880 p3terx/ariang
  echo ""
  echo "已启动"
  echo ""
  echo " http://IP:6880 访问 "
  echo ""
  shon_online
}

ariang_installtion(){
  build_ariang
  start_ariang
}

clean_ariang(){
  echo "正在卸载 AriaNG. . ."
  docker rm -f ariang
  docker rmi p3terx/ariang:latest
  echo ""
  echo "卸载完成"
  echo ""
  shon_online
}

shon_online(){
echo ""
echo " Aria2-Pro for Docker by 0x01x0 "
echo ""
echo "请选择您需要进行的操作:"
echo ""
echo "  1) 安装 Aria2-Pro"
echo "  2) 卸载 Aria2-Pro"
echo "------------------------"
echo "  3）安装 AriaNG"
echo "  4）卸载 AriaNG"
echo "------------------------"
echo "  5) 停止 Aria2-Pro"
echo "  6) 启动 Aria2-Pro"
echo "------------------------"
echo "  7) 重新启动 Aria2-Pro"
echo "  8) 重新安装 Aria2-Pro"
echo "------------------------"
echo "  9) 退出"
echo ""
echo -n "请输入编号: "
read N
case $N in
  1)
  start_installation
  ;;
  2)
  clean_aria2
  ;;
  3)
  ariang_installtion
  ;;
  4)
  clean_ariang
  ;;
  5)
  stop_pager
  ;;
  6)
  start_pager
  ;;
  7)
  restart_pager
  ;;
  8)
  reinstall_pager
  ;;
  9)
  exit
  ;;
  *)
  echo "Wrong input!"
  sleep 5s
  shon_online
  ;;
esac
}

shon_online
