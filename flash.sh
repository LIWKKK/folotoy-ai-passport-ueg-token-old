#!/usr/bin/env bash
# UEG 数字生命卡 · 烧写脚本
# 用法: ./flash.sh <串口设备> [full|app]
#   full (默认) = 整包镜像,从 0x0 烧写(会清空 NVS 里已保存的配置)
#   app         = 仅应用,从 0x10000 烧写(保留引导、分区表与配置)
set -euo pipefail

PORT="${1:-}"
MODE="${2:-full}"

if [ -z "$PORT" ]; then
    echo "用法: $0 <串口设备> [full|app]" >&2
    echo "例如: $0 /dev/ttyACM0" >&2
    exit 1
fi
if [ ! -e "$PORT" ]; then
    echo "找不到串口: $PORT" >&2
    echo "提示: Linux 上可能需要把当前用户加入 dialout 组,或改用 sudo。" >&2
    exit 1
fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

FLASH_ARGS=(--chip esp32c3 --baud 921600
            --flash_mode dio --flash_freq 80m --flash_size 8MB)

case "$MODE" in
    full)
        IMAGE="FoloToy-AI-Passport-full.bin"
        OFFSET="0x0"
        cat <<'WARN'
⚠️  整包烧写会覆盖 NVS 分区,设备里已保存的 Wi-Fi 与平台 Key 将被清空,
    开机后需要重新配网。若想保留配置,请改用:  ./flash.sh <串口> app

WARN
        ;;
    app)
        IMAGE="FoloToy-AI-Passport-app-only.bin"
        OFFSET="0x10000"
        ;;
    *)
        echo "未知模式: $MODE(应为 full 或 app)" >&2
        exit 1
        ;;
esac

echo "== 校验 SHA256 =="
if command -v sha256sum >/dev/null 2>&1; then
    grep -E "  ${IMAGE}\$" SHA256SUMS.txt | sha256sum -c -
else
    echo "跳过(未找到 sha256sum)"
fi

echo
echo "== 烧写 $IMAGE → $OFFSET @ $PORT =="
if command -v esptool.py >/dev/null 2>&1; then
    ESPTOOL=(esptool.py)
elif python3 -c "import esptool" 2>/dev/null; then
    ESPTOOL=(python3 -m esptool)
else
    echo "未找到 esptool。请先安装: pip install esptool" >&2
    exit 1
fi

"${ESPTOOL[@]}" "${FLASH_ARGS[@]}" --port "$PORT" write-flash "$OFFSET" "$IMAGE"
echo
echo "✅ 烧写完成。设备已自动重启。"
