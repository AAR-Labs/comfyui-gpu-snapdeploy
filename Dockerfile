FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 python3.11-venv python3-pip git wget ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && ln -sf /usr/bin/python3.11 /usr/bin/python

WORKDIR /app
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git .
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cu121 \
    && pip install --no-cache-dir -r requirements.txt

# Download Stable Diffusion XL base in the BACKGROUND at startup (~6.9 GB),
# so the UI is healthy immediately. Set DOWNLOAD_SDXL=false to skip.
ENV DOWNLOAD_SDXL=true

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8188
ENTRYPOINT ["/start.sh"]
