FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 python3.11-venv python3-pip git wget ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && ln -sf /usr/bin/python3.11 /usr/bin/python

WORKDIR /app
# Pinned release + pinned torch line (NOT master + floating torch — that combination
# shipped an import-time incompatibility: comfy-kitchen's custom_op schemas need a
# newer torch than the old cu121 resolution provided; 2.6/cu124 also failed the
# import smoke test — comfy-kitchen needs the >=2.7 rewritten infer_schema).
RUN git clone --branch v0.34.0 --depth 1 https://github.com/comfyanonymous/ComfyUI.git .
RUN pip install --no-cache-dir torch==2.9.0 torchvision==0.24.0 torchaudio==2.9.0 \
        --index-url https://download.pytorch.org/whl/cu126 \
    && pip install --no-cache-dir -r requirements.txt

# kornia's @torch.jit.script decorators segfault the TorchScript compiler under
# torch 2.9 at import time (kornia/geometry/epipolar/essential.py:90, hit when
# ComfyUI loads its post-processing nodes). ComfyUI runs eager + pytorch attention
# and never needs TorchScript, so disable the JIT: scripted functions become plain
# Python passthroughs with identical results.
ENV PYTORCH_JIT=0

# Build-time import smoke test: if the torch/comfy-kitchen pairing is incompatible,
# FAIL THE BUILD with the real traceback — never ship an image that crash-loops.
# kornia included: it is imported at server start (not by comfy.utils), which is
# exactly where the jit.script segfault slipped past the original test.
RUN python3 -c "import comfy.utils; import kornia; print('comfy + kornia import OK')"

# Download Stable Diffusion XL base in the BACKGROUND at startup (~6.9 GB),
# so the UI is healthy immediately. Set DOWNLOAD_SDXL=false to skip.
ENV DOWNLOAD_SDXL=true

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8188
ENTRYPOINT ["/start.sh"]
