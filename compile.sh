echo "Cloning dependencies"
git clone --depth=1 https://github.com/kdrag0n/proton-clang ~/toolchain/clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 ~/toolchain/gcc
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 ~/toolchain/gcc32
git clone --depth=1 https://github.com/LegendaryHub/AnyKernel3 ~/toolchain/AnyKernel3
echo "Done"

KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PATH="${HOME}/toolchain/clang/bin:${HOME}/toolchain/gcc/bin:${HOME}/toolchain/gcc32/bin:${PATH}"
export ARCH=arm64
export KBUILD_BUILD_USER=Sezam4ik
export KBUILD_BUILD_HOST=Instance

make O=out ARCH=arm64 vendor/lime-perf_defconfig

# Compile plox
compile() {
    make -j$(nproc) O=out \
                    ARCH=arm64 \
                    CC=clang \
		    ARCH=arm64 \
		    CC="ccache clang" \
		    CXX="ccache. clang++" \
		    AR="ccache llvm-ar" \
		    AS="ccache llvm-as" \
		    NM="ccache llvm-nm" \
		    STRIP="ccache llvm-strip" \
		    OBJCOPY="ccache llvm-objcopy" \
		    OBJDUMP="ccache llvm-objdump"\
		    OBJSIZE="ccache llvm-size" \
		    READELF="ccache llvm-readelf" \
		    HOSTCC="ccache clang" \
		    HOSTCXX="ccache clang++" \
		    HOSTAR="ccache llvm-ar" \
		    HOSTAS="ccache llvm-as" \
		    HOSTNM="ccache llvm-nm" \
		    HOSTLD="ccache ld.lld" \
		    CROSS_COMPILE=aarch64-linux-gnu- \
		    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
		    $@
}


module() {
[ -d "modules" ] && rm -rf modules || mkdir -p modules

compile \
INSTALL_MOD_PATH=../modules \
INSTALL_MOD_STRIP=1 \
modules_install
}

# Zipping
zipping() {
    cd ${HOME}/toolchain/AnyKernel3 || exit 1
    cp ${KERNEL_DIR}/out/arch/arm64/boot/Image .
    rm -rf *.zip
    zip -r9 OEM.zip *
    cd ..
}

compile
module
zipping
