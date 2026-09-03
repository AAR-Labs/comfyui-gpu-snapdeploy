# ComfyUI + SDXL on SnapDeploy — Dedicated GPU

[ComfyUI](https://github.com/comfyanonymous/ComfyUI) — the node-based Stable
Diffusion interface — running on your own dedicated NVIDIA GPU. SDXL base
weights download automatically in the background on first start (~6.9 GB).

- UI on port **8188**, available seconds after deploy.
- 24 GB VRAM (Dedicated A10G) runs SDXL text-to-image comfortably, with headroom
  for refiners, LoRAs, and upscalers. Flux-schnell (fp8) also fits.
- Set `DOWNLOAD_SDXL=false` to start clean and bring your own checkpoints.

Deployed via [SnapDeploy Dedicated GPU](https://snapdeploy.dev/gpu-hosting) —
your own GPU, flat monthly price, no per-second billing while you iterate.
