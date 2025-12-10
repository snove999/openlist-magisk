# shellcheck shell=ash
# uninstall.sh for OpenList Magisk/KSU Module (All-in-One)

#==== 侦探：Magisk or KernelSU ====
if [ -n "$MAGISK_VER" ]; then
    MODROOT="$MODPATH"
elif [ -n "$KSU" ] || [ -n "$KERNELSU" ]; then
    MODROOT="$MODULEROOT"
else
    MODROOT="$MODPATH"
fi
#==== 侦探结束 ====

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 停止所有服务
stop_all_services() {
    log "正在停止所有服务..."
    
    # OpenList
    if pgrep -f "openlist" >/dev/null 2>&1; then
        log "停止 OpenList..."
        pkill -f "openlist"
    fi
    
    # Aria2
    if pgrep -f "aria2c" >/dev/null 2>&1; then
        log "停止 Aria2..."
        pkill -f "aria2c"
    fi
    
    # Qbittorrent
    if pgrep -f "qbittorrent-nox" >/dev/null 2>&1; then
        log "停止 Qbittorrent..."
        pkill -f "qbittorrent-nox"
    fi
    
    # Frpc
    if pgrep -f "frpc" >/dev/null 2>&1; then
        log "停止 Frpc..."
        pkill -f "frpc"
    fi
    
    sleep 2
    
    # 强制终止残留进程
    local services="openlist aria2c qbittorrent-nox frpc"
    for svc in $services; do
        if pgrep -f "$svc" >/dev/null 2>&1; then
            log "强制终止 $svc..."
            pkill -9 -f "$svc"
        fi
    done
    
    log "所有服务已停止"
}

# 清理二进制文件
clean_binaries() {
    log "清理二进制文件..."
    local found=0
    
    # OpenList 二进制路径
    local openlist_paths="/data/adb/openlist/bin/openlist $MODROOT/bin/openlist $MODROOT/system/bin/openlist"
    for path in $openlist_paths; do
        if [ -f "$path" ]; then
            log "删除: $path"
            rm -f "$path"
            found=1
        fi
    done
    
    # 模块 bin 目录（包含 aria2c, qbittorrent-nox, frpc, rclone）
    if [ -d "$MODROOT/bin" ]; then
        log "删除模块 bin 目录: $MODROOT/bin"
        rm -rf "$MODROOT/bin"
        found=1
    fi
    
    # 模块 web 目录（包含 ariang, vuetorrent）
    if [ -d "$MODROOT/web" ]; then
        log "删除模块 web 目录: $MODROOT/web"
        rm -rf "$MODROOT/web"
        found=1
    fi
    
    if [ $found -eq 0 ]; then
        log "未找到需要清理的二进制文件"
    else
        log "二进制文件清理完成"
    fi
}

# 自动清理数据目录
clean_data() {
    log "开始清理数据目录..."
    local found=0
    
    # 所有可能的数据目录
    local data_dirs="/data/adb/openlist /sdcard/Android/openlist"
    
    for dir in $data_dirs; do
        if [ -d "$dir" ]; then
            log "删除数据目录: $dir"
            rm -rf "$dir"
            found=1
        fi
    done
    
    if [ $found -eq 1 ]; then
        log "数据目录清理完成"
    else
        log "未找到数据目录"
    fi
}

# 主卸载流程
main() {
    log "=========================================="
    log "开始卸载 OpenList All-in-One 模块"
    log "=========================================="
    
    stop_all_services
    clean_binaries
    clean_data
    
    log "=========================================="
    log "卸载完成，请重启设备"
    log "=========================================="
}

main
