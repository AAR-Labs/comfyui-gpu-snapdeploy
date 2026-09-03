#!/bin/sh
# Fetch SDXL base weights in the background — the UI must be healthy immediately;
# large downloads never block startup.
if [ "$DOWNLOAD_SDXL" = "true" ] && [ ! -f /app/models/checkpoints/sd_xl_base_1.0.safetensors ]; then
  (
    echo "[snapdeploy] background-downloading SDXL base (~6.9 GB)…"
    wget -q -O /app/models/checkpoints/sd_xl_base_1.0.safetensors \
      "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors" \
      && echo "[snapdeploy] SDXL ready" \
      || echo "[snapdeploy] SDXL download failed — add checkpoints via the ComfyUI Manager or a volume"
  ) &
fi
exec python3 /app/main.py --listen 0.0.0.0 --port 8188
