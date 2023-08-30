#!/bin/bash
function installOpkg {
    clear
    installentware
    if [ $? -eq 0 ]; then
        echo "opkg包管理工具安装完成"
    else
        echo "opkg包管理工具安装失败"
    fi
}
function installDavfs2 {
    clear
    opkg install davfs2
    if [ $? -eq 0 ]; then
        echo "安装davfs2命令执行完成"
    else
        echo "安装davfs2命令执行失败"
    fi
}
function davfs2Config {
    clear
    echo "dav_user        root">>/opt/etc/davfs2/davfs2.conf
    echo "dav_group       root">>/opt/etc/davfs2/davfs2.conf
    chmod 0600 /opt/etc/davfs2/secrets
    clear
    echo "davfs2配置完成"
}
function umountWebdav {
    clear
    rm -f /opt/var/run/mount.davfs/*.pid
    umount -f davfs /storage/roms/
    clear
    echo "取消挂载成功"
}
function mountWebdav {
    clear
    rm -f /opt/var/run/mount.davfs/*.pid
    read -p "请输入webdav的连接[例如https://192.168.1.1/dav] " webdav_url
    if grep -q ${webdav_url} /opt/etc/davfs2/secrets
    then
        echo "已经检测到免密信息"
    else
        read -p "请输入${webdav_url}的账号 " webdav_username
        read -p "请输入${webdav_url}的密码 " webdav_password
        echo "配置免密登录"
        echo "ignore_dav_header 1">>/opt/etc/davfs2/davfs2.conf
        echo "use_locks 0">>/opt/etc/davfs2/davfs2.conf
        echo "${webdav_url} ${webdav_username} ${webdav_password}" >>/opt/etc/davfs2/secrets
        chmod 600 /opt/etc/davfs2/secrets
    fi
    rm -rf mount_webdav.sh
    echo "echo y | mount -t davfs ${webdav_url} /storage/roms" >>/storage/mount_webdav.sh
    chmod 777 mount_webdav.sh
    bash mount_webdav.sh
}
function menu {
    clear
    echo
    echo -e "\t\t\tEMUELEC挂载Webdav\n"
    echo -e "\t1. 安装opkg"
    echo -e "\t2. 安装davfs2"
    echo -e "\t3. 配置davfs2[执行一次就行]"
    echo -e "\t4. 挂载"
    echo -e "\t5. 取消挂载"
    echo -e "\t0. 退出\n\n"
    read -p "请输入序号，选择您要执行的操作: " option
}
while [ 1 ]
    do
    menu
    case $option in
    0)
        break
        ;;
    1)
        installOpkg
        ;;
    2)
        installDavfs2
        ;;
    3)
        davfs2Config
        ;;
    4)
        mountWebdav
        clear
        ls /storage/roms
        echo "如果显示游戏目录则挂载成功"
        ;;
    5)
        umountWebdav
        ;;
    *)
    clear
    echo "请输入正确的序号";;
    esac
    echo -en "选择任意键返回菜单"
    read -n 1 line
done
clear