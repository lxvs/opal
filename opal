#!/bin/bash

showVersion () {
cat <<EOF

    OPAL Script v0.1.0
    2021-10-25
    https://github.com/lxvs/opal

EOF
}

mainUsage () {
cat <<EOF

    opal -h | --help
    opal -V | --version
    opal setup <device>
    opal setpwd <device> <sidpassword> <admin1pwd>
    opal revert <device> <PSID>

EOF
}

ValidateSedutil () {
    type "$sedu" 1>/dev/null 2>&1 && return
    >&2 printf "%s\n" "ERROR: Could not find $sedu."
    return 1
}

setupOp () {
    local dev
    local pba="./UEFI64.img"

    if test $# -ne 1
    then
        >&2 printf "%s\n" "ERROR: setup operation takes 1 arguments."
        >&2 mainUsage
        return 1
    fi

    dev="$1"

    ValidateSedutil || return

    if test ! -e "$pba"
    then
        >&2 printf "%s\n" "ERROR: Could not find file $pba"
        return 1
    fi

    "$sedu" --initialsetup debug "$dev"
    "$sedu" --enablelockingrange 0 debug "$dev"
    "$sedu" --setlockingrange 0 lk debug "$dev"
    "$sedu" --setmbrdone off debug "$dev"
    "$sedu" --loadpbaimage debug "$pba" "$dev"
}

setpwdOp () {
    local dev
    local sid
    local adm

    if test $# -ne 3
    then
        >&2 printf "%s\n" "ERROR: setpwd operation takes 3 arguments."
        >&2 mainUsage
        return 1
    fi

    dev="$1"
    sid="$2"
    adm="$3"

    "$sedu" --setsidpassword debug "$sid" "$dev"
    "$sedu" --setadmin1pwd debug "$adm" "$dev"
}

revertOp () {
    local dev
    local psid

    if test $# -ne 2
    then
        >&2 printf "%s\n" "ERROR: revert operation takes 2 arguments."
        >&2 mainUsage
        return 1
    fi

    dev="$1"
    psid="$2"

    "$sedu" --yesIreallywanttoERASEALLmydatausingthePSID "$psid" "$dev"
}

main () {
    local arg
    local sedu="sedutil-cli"
    while test $# -ge 1
    do
        arg="$1"
        shift
        case "$arg" in
        -h|--help)
            mainUsage
            ;;
        -V|--version)
            showVersion
            ;;
        setpwd|setup|revert)
            ${arg}Op "$@"
            break
            ;;
        *)
            printf "%s\n" "Invalid argument: $arg"
            break
            ;;
        esac
    done
}

main "$@"
