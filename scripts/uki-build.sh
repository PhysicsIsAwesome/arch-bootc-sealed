set -euo pipefail
kver=$(basename $(find /target/usr/lib/modules -maxdepth 1 -mindepth 1 -type d -print0))
cmdline='"lsm=landlock,lockdown,yama,integrity,apparmor,bpf audit=1 audit_backlog_limit=8192 rw rootflags=subvol=@"'
ukify_args="\
            --secureboot-private-key /run/secrets/secureboot_key \
            --secureboot-certificate /run/secrets/secureboot_cert \
            --output /boot/${kver}.efi"
bootc container ukify --rootfs /target --karg "rw rootflags=subvol=@" -- ${ukify_args}