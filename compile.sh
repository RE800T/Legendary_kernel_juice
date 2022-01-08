#!/bin/bash

# Цвета
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'
# Создание папки
mkdir -p ~/toolchain

echo -e "${green}"
echo "~~~~~~~~~~~~~~~"
echo "Creating folder:"
echo "~~~~~~~~~~~~~~~"
echo -e "${restore}"

echo -e "${green}"
echo "~~~~~~~~~~~~~~~~~~~~~"
echo "Cloning dependencies:"
echo "~~~~~~~~~~~~~~~~~~~~~"
echo -e "${restore}"

# Клонирование proton-clang

git clone --depth=1 https://github.com/silont-project/silont-clang ~/toolchain/clang

# Клонирование GCC 64bit
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 ~/toolchain/gcc

# Клонирование GCC 32bit
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 ~/toolchain/gcc32

echo -e "${green}"
echo "~~~~"
echo "Done:"
echo "~~~~"
echo -e "${restore}"

KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PATH="${HOME}/toolchain/clang/bin:${HOME}/toolchain/gcc/bin:${HOME}/toolchain/gcc32/bin:${PATH}"
export KBUILD_COMPILER_STRING="$(${HOME}/toolchain/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export KBUILD_BUILD_USER=Evgeny
export KBUILD_BUILD_HOST=Sezam4ik

make O=out ARCH=arm64 vendor/lime-perf_defconfig

# Время начала сборки ядра
DATE_START=$(date +"%s")

# Compile plox
compile() {
	   make -j$(nproc) O=out \
                    ARCH=arm64 \
                    CC=clang \
                    OBJCOPY=llvm-objcopy \
                    OBJDUMP=llvm-objdump \
		    CROSS_COMPILE=aarch64-linux-android- \
                    CROSS_COMPILE_ARM32=arm-linux-androideabi- \
                    CLANG_TRIPLE=aarch64-linux-gnu-
		    LD="ccache ld.lld" \
		    AR=llvm-ar \
                    NM=llvm-nm \
                    OBJCOPY=llvm-objcopy \
                    OBJDUMP=llvm-objdump \
                    STRIP=llvm-strip $1 $2 $3
}

compile 
# Время окончания сборки ядра
DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))

echo -e "${green}"
echo "----------------------------------------------"
echo "Build Completed in: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo "----------------------------------------------"
echo -e "${restore}"

