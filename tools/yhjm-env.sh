#!/usr/bin/env bash
# Shared Ubuntu/Linux helpers for setup / build / flash.
# shellcheck disable=SC2034

YHJM_TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YHJM_ROOT="$(cd "${YHJM_TOOLS_DIR}/.." && pwd)"
YHJM_FIRMWARE="${YHJM_ROOT}/firmware"
YHJM_SDK_PYTHON="${YHJM_ROOT}/sdk/python"
YHJM_TOOLCHAIN="${YHJM_TOOLS_DIR}/toolchain"

yhjm_import_env() {
    if [[ -f "${YHJM_TOOLS_DIR}/env.sh" ]]; then
        # shellcheck source=/dev/null
        . "${YHJM_TOOLS_DIR}/env.sh"
    fi
}

yhjm_first_existing() {
    local p
    for p in "$@"; do
        [[ -z "${p}" ]] && continue
        if [[ -e "${p}" ]]; then
            printf '%s\n' "${p}"
            return 0
        fi
        # shellcheck disable=SC2086
        local hits
        hits="$(compgen -G "${p}" 2>/dev/null | sort -V | tail -n 1 || true)"
        if [[ -n "${hits}" && -e "${hits}" ]]; then
            printf '%s\n' "${hits}"
            return 0
        fi
    done
    return 1
}

yhjm_find_cmake() {
    if command -v cmake >/dev/null 2>&1; then
        command -v cmake
        return 0
    fi
    yhjm_first_existing "${YHJM_TOOLCHAIN}/cmake/bin/cmake"
}

yhjm_find_ninja() {
    if command -v ninja >/dev/null 2>&1; then
        command -v ninja
        return 0
    fi
    yhjm_first_existing "${YHJM_TOOLCHAIN}/ninja/ninja"
}

yhjm_find_arm_gcc() {
    if [[ -n "${ARM_NONE_EABI_TOOLCHAIN_PATH:-}" ]]; then
        if [[ -x "${ARM_NONE_EABI_TOOLCHAIN_PATH}/arm-none-eabi-gcc" ]]; then
            printf '%s\n' "${ARM_NONE_EABI_TOOLCHAIN_PATH}/arm-none-eabi-gcc"
            return 0
        fi
    fi
    if command -v arm-none-eabi-gcc >/dev/null 2>&1; then
        command -v arm-none-eabi-gcc
        return 0
    fi
    yhjm_first_existing \
        "${YHJM_TOOLCHAIN}/arm-gnu/bin/arm-none-eabi-gcc" \
        "${YHJM_TOOLCHAIN}/arm-gnu/*/bin/arm-none-eabi-gcc"
}

yhjm_openocd_scripts_dir() {
    local home="$1"
    local d
    for d in \
        "${home}/share/openocd/scripts" \
        "${home}/openocd/scripts" \
        "${home}/scripts" \
        /usr/share/openocd/scripts
    do
        if [[ -d "${d}/target" ]]; then
            printf '%s\n' "${d}"
            return 0
        fi
    done
    return 1
}

yhjm_openocd_has_gd32() {
    local scripts_dir="${1:-}"
    [[ -n "${scripts_dir}" && -f "${scripts_dir}/target/gd32f30x.cfg" ]]
}

yhjm_find_openocd() {
    local env_exe="${YHJM_OPENOCD_EXE:-}"
    local env_scripts="${YHJM_OPENOCD_SCRIPTS:-}"
    local exe="" scripts="" home="" portable=""

    YHJM_OPENOCD_EXE=""
    YHJM_OPENOCD_SCRIPTS=""
    YHJM_OPENOCD_HAS_GD32=0

    if [[ -n "${env_exe}" && -x "${env_exe}" ]]; then
        exe="${env_exe}"
        scripts="${env_scripts}"
        home="$(cd "$(dirname "${exe}")/.." && pwd)"
        if [[ -z "${scripts}" ]]; then
            scripts="$(yhjm_openocd_scripts_dir "${home}" || true)"
        fi
    else
        portable="$(yhjm_first_existing \
            "${YHJM_TOOLCHAIN}/openocd/bin/openocd" \
            "${YHJM_TOOLCHAIN}/openocd/*/bin/openocd" || true)"
        if [[ -n "${portable}" ]]; then
            exe="${portable}"
            home="$(cd "$(dirname "${exe}")/.." && pwd)"
            scripts="$(yhjm_openocd_scripts_dir "${home}" || true)"
        elif command -v openocd >/dev/null 2>&1; then
            exe="$(command -v openocd)"
            home="$(cd "$(dirname "${exe}")/.." && pwd)"
            scripts="$(yhjm_openocd_scripts_dir "${home}" || true)"
        else
            return 1
        fi
    fi

    YHJM_OPENOCD_EXE="${exe}"
    YHJM_OPENOCD_SCRIPTS="${scripts}"
    if yhjm_openocd_has_gd32 "${scripts}"; then
        YHJM_OPENOCD_HAS_GD32=1
    else
        YHJM_OPENOCD_HAS_GD32=0
    fi
    return 0
}

yhjm_find_python() {
    local cmd
    for cmd in python3 python; do
        if command -v "${cmd}" >/dev/null 2>&1; then
            if "${cmd}" -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)" 2>/dev/null; then
                command -v "${cmd}"
                return 0
            fi
        fi
    done
    return 1
}
