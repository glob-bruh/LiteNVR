#!/bin/bash

######################
# NVR CONTROL SCRIPT #
######################

source /srv/NVR/.cctv_configuration.env
CAMERA_URL="rtsp://${CAMERA_USER}:${CAMERA_PASS}@${CAMERA_IP}:${CAMERA_PORT}/stream1"
FILENAME="${TARGET_DIR}/CAMERA1_%Y-%m-%d_%H-%M-%S.mp4"

run_tape() {
    if timeout 3 touch "$MOUNT_PATH/.cctv_mount_test" 2>/dev/null; then
        rm -f "$MOUNT_PATH/.cctv_mount_test"
        mkdir -p "$TARGET_DIR"
        sleep 3
        exec ffmpeg -y \
            -rtsp_transport tcp \
            -timeout 5000000 \
            -i "$CAMERA_URL" \
            -an \
            -vcodec copy \
            -f segment \
            -strftime 1 \
            -segment_time 1800 \
            -segment_atclocktime 1 \
            -segment_clocktime_offset 30 \
            -segment_format mp4 \
            -reset_timestamps 1 \
            "$FILENAME"
    else 
        echo "NAS un-writable!" >&2
        exit 1
    fi
}

run_clean() {
    if grep -qs "/mnt/cctv_storage" /proc/mounts; then
        find "$TARGET_DIR" -type f -name "*.mp4" -mtime +3 -delete
        echo "$(date): Old footage cleanup completed successfully."
    else
        echo "$(date): Cleanup skipped. NAS share is not mounted."
        exit 1
    fi
}

case "$1" in 
    tape)
        run_tape
        ;;
    clean)
        run_clean
        ;;
    *)
        echo "Help: $0 {tape|clean}" >&2
        exit 1
        ;;
esac
