set -euo pipefail
kver=$(basename $(find /target/usr/lib/modules -maxdepth 1 -mindepth 1 -type d -print0))
cmdline='"lsm=landlock,lockdown,yama,integrity,apparmor,bpf audit=1 audit_backlog_limit=8192 rw rootflags=subvol=@"'
ukify_args="\
            --secureboot-private-key /run/secrets/secureboot_key \
            --secureboot-certificate /run/secrets/secureboot_cert \
            --measure \
            --output /boot/${kver}.efi"
bootc container ukify --rootfs /target --karg "rw rootflags=subvol=root rd.luks.name=7fa68618-91b8-4cf6-8a30-6c662331b0c7=luks-7fa68618-91b8-4cf6-8a30-6c662331b0c7 root=/dev/mapper/luks-7fa68618-91b8-4cf6-8a30-6c662331b0c7" -- ${ukify_args}