#!/bin/bash

#init submodules
git submodule init && git submodule update

#main variables
export MODEL=$1
export ARCH=arm64
export RDIR="$(pwd)"
export KBUILD_BUILD_USER="@kret2poor"

# Device configuration
declare -A DEVICES=(
    [beyond2lte]="exynos9820-beyond2lte_defconfig"
    [beyond1lte]="exynos9820-beyond1lte_defconfig"
    [beyond0lte]="exynos9820-beyond0lte_defconfig"
    [beyondx]="exynos9820-beyondx_defconfig"

    [d1]="exynos9820-d1_defconfig"
    [d1x]="exynos9820-d1x_defconfig"
    [d2s]="exynos9820-d2s_defconfig"
    [d2x]="exynos9820-d2x_defconfig"
    [f62]="exynos9820-f62_defconfig"       
)

# Set device-specific variables
if [[ -v DEVICES[$MODEL] ]]; then
    read KERNEL_DEFCONFIG <<< "${DEVICES[$MODEL]}"
    echo -e "\n[i] Building with ${KERNEL_DEFCONFIG}..\n"
else
    echo -e "\n[!] Unknown device: $MODEL, setting to beyond2lte\n"
    read KERNEL_DEFCONFIG <<< "${DEVICES[beyond2lte]}"
fi

#dev
if [ -z "$BUILD_KERNEL_VERSION" ]; then
    export BUILD_KERNEL_VERSION="dev"
fi

#setting up localversion
echo -e "CONFIG_LOCALVERSION_AUTO=n\nCONFIG_LOCALVERSION=\"-kret-${BUILD_KERNEL_VERSION}-openela\"\n" > "${RDIR}/arch/arm64/configs/version.config"

#install requirements
sudo apt install libarchive-tools zstd -y

#init neutron-clang
if [ ! -d "${HOME}/toolchains/neutron-clang" ]; then
    echo -e "\n[INFO] Cloning Neutron-Clang Toolchain\n"
    mkdir -p "${HOME}/toolchains/neutron-clang"
    cd "${HOME}/toolchains/neutron-clang"
    curl -LO "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman" && chmod +x antman
    bash antman -S && bash antman --patch=glibc
    cd "${RDIR}"
fi

#init arm gnu toolchain
if [ ! -d "${HOME}/toolchains/gcc" ]; then
    echo -e "\n[INFO] Cloning ARM GNU Toolchain\n"
    mkdir -p "${HOME}/toolchains/gcc"
    cd "${HOME}/toolchains/gcc"
    curl -LO "https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz"
    tar -xf arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz
    cd "${RDIR}"
fi

#export toolchain paths
export BUILD_CROSS_COMPILE="${HOME}/toolchains/gcc/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-"
expo
