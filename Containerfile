ARG base=ghcr.io/bootcrew/arch-bootc:latest

FROM $base as systemdboot
COPY --chown=root:root --chmod=600 secureboot-auth/* /usr/lib/bootc/install/secureboot-keys/mysecboot/
COPY --chown=root:root --chmod=644 config/bootc-prepare-root.conf /usr/lib/ostree/prepare-root.conf
COPY --chown=root:root --chmod=644 config/firstboot.conf /etc/systemd/system/systemd-firstboot.service.d/firstboot.conf
RUN mkdir -p /var/roothome
RUN --mount=type=tmpfs,dst=/tmp --mount=type=cache,dst=/var/tmp --mount=type=cache,dst=/usr/lib/sysimage/cache/pacman \
    pacman -Rsn --noconfirm linux && rm -rf $(find /usr/lib/modules/* -maxdepth 1 -type d | grep -E "arch")
RUN --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/usr/lib/sysimage/cache/pacman pacman -Sy sbsigntools systemd-ukify kmod mokutil linux-hardened podman git --needed --noconfirm
RUN --network=none \
    --mount=type=secret,id=secureboot_key \
    --mount=type=secret,id=secureboot_cert \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/var/tmp \
    sh -euxo pipefail -c '\
        dracut --force "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E ".img" | tail -n 1)/initramfs.img"; \
        sdboot="usr/lib/systemd/boot/efi/systemd-bootx64.efi"; \
        sbsign \
            --key /run/secrets/secureboot_key \
            --cert /run/secrets/secureboot_cert \
            --output "/${sdboot}" \
            "/${sdboot}"; \
        rm -vf /var/lib/systemd/random-seed'

RUN rm -rf /boot /var/cache /tmp /var/tmp && \
    mkdir -p /boot /var/cache /tmp /var/tmp

RUN bootc container lint

ARG CHUNKAH_CONFIG_STR

FROM quay.io/coreos/chunkah AS chunkah
ARG CHUNKAH_CONFIG_STR
RUN --mount=from=systemdboot,src=/,target=/chunkah,ro \
    --mount=type=bind,target=/run/src,rw \
        chunkah build --label ostree.bootable=1 --label containers.bootc=1 --compressed --max-layers 248 > /run/src/out.ociarchive

FROM oci-archive:out.ociarchive
