# SPDX-License-Identifier: MIT OR Apache-2.0
# SPDX-FileCopyrightText: Copyright 2026 PhysicsIsAwesome

image_unsealed := env("IMAGE_UNSEALED", "localhost/arch-bootc-unsealed:latest")
image_sealed := env("IMAGE_SEALED", "localhost/arch-bootc-sealed:latest")
image_base := env("IMAGE_BASE", "ghcr.io/bootcrew/arch-bootc:latest")

pull image: 
    podman pull {{image}}

build image_base image_unsealed:
    podman build -t {{image_unsealed}} --no-cache --skip-unused-stages=false -v $(pwd):/run/src --build-arg base={{image_base}} --secret=id=secureboot_key,env=DB_KEY --secret=id=secureboot_cert,env=DB_CRT .

seal image_unsealed image_sealed:
    podman build -t {{image_sealed}} --no-cache --build-arg base={{image_unsealed}} --secret=id=secureboot_key,env=DB_KEY --secret=id=secureboot_cert,env=DB_CRT -f Containerfile.uki

push image image_remote:
    podman push {{image}} {{image_remote}}
