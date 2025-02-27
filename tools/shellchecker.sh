#!/usr/bin/env bash
#
#  Part of https://github.com/emkey1/AOK-Filesystem-Tools
#
#  License: MIT
#
#  Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#
#  Runs shellcheck on all included scripts
#
version="1.1.3"

#  shellcheck disable=SC1007
CURRENT_D=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
fs_build_d="$(dirname "${CURRENT_D}")"
prog_name=$(basename "$0")

echo "$prog_name, version $version"
echo


#
#  Ensure this is run in the intended location in case this was launched from
#  somewhere else.
#
cd "${fs_build_d}" || exit 1


checkables=(
    tools/shellchecker.sh      # obviously self-check :)

    AOK_VARS
    BUILD_ENV
    aok_setup_fs
    build_fs
    compress_image

    tools/do_chroot.sh



    # Files/bash_profile  # 100s of issues...
    Files/profile
    Files/profile.aok-complete
    Files/profile.fbat

    # Do this out of order, since it is a key file
    Files/sbin/post_boot.sh

    Files/bin/aok
    Files/bin/aok_groups
    Files/bin/apt
    Files/bin/disable_sshd
    Files/bin/disable_vnc
    Files/bin/do_fix_services
    Files/bin/elock
    Files/bin/enable_sshd
    Files/bin/enable_vnc
    Files/bin/fix_services
    Files/bin/iCloud
    Files/bin/installed
    Files/bin/ipad_tmux
    Files/bin/iphone_tmux
    Files/bin/pbcopy
    Files/bin/showip
    Files/bin/toggle_multicore
    Files/bin/update
    Files/bin/update_motd
    Files/bin/version
    Files/bin/vnc_start
    Files/bin/what_owns

    Files/cron/15min/dmesg_save

)

do_shellcheck="$(command -v shellcheck)"
do_checkbashisms="$(command -v checkbashisms)"

if [[ "${do_shellcheck}" = "" ]] && [[ "${do_checkbashisms}" = "" ]]; then
    echo "ERROR: neither shellcheck nor checkbashisms found, can not proceed!"
    exit 1
fi

printf "Using: "
if [[ -n "${do_shellcheck}" ]]; then
    printf "%s " "shellcheck"
fi
if [[ -n "${do_checkbashisms}" ]]; then
    printf "%s " "checkbashisms"
    #  shellcheck disable=SC2154
    if [[ "$build_env" -eq 1 ]]; then
        if checkbashisms --version | grep -q 2.21; then
            echo
            echo "WARNING: this version of checkbashisms runs extreamly slowly on iSH!"
            echo "         close to a minute/script"
        fi
    fi
fi
printf "\n\n"

for script in "${checkables[@]}"; do
    #  abort as soon as one lists issues
    echo "Checking: ${script}"
    if [[ "${do_shellcheck}" != "" ]]; then
        shellcheck -x -a -o all -e SC2250,SC2312 "${script}"  || exit 1
    fi
    if [[ "${do_checkbashisms}" != "" ]]; then
        checkbashisms -n -e -x "${script}"  || exit 1
    fi
done
