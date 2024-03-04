#!/usr/bin/env bash

 #
 # Script For Building Android Kernel
 #

##----------------------------------------------------------##
# Specify Kernel Directory
export KERNEL_DIR="$(pwd)"

##----------------------------------------------------------##

git submodule update --init --recursive

# Device Name and Model
MODEL=Xiaomi
DEVICE=chime

# Kernel Defconfig
export DEFCONFIG=bengal-perf_defconfig

# Files
export IMAGE=$(pwd)/out/arch/arm64/boot/Image
#export DTBO=$(pwd)/out/arch/arm64/boot/dtbo.img
#DTB=$(pwd)/out/arch/arm64/boot/dts/mediatek

# Date and Time
export DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%T")
export TANGGAL=$(date +"%F%S")

# Specify Final Zip Name
export ZIPNAME="SUPER.KERNEL.CHIME-(cosmic-clang)-$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M").zip"

##----------------------------------------------------------##
# Specify compiler.

COMPILER=cosmic-clang

##----------------------------------------------------------##
# Specify Linker
LINKER=ld.lld

##----------------------------------------------------------##

##----------------------------------------------------------##
# Clone ToolChain
function cloneTC() {

    if [ $COMPILER = "cosmic-clang" ];
    then
    git clone --depth=1 https://gitlab.com/GhostMaster69-dev/cosmic-clang.git -b master cosmic-clang
    PATH="${KERNEL_DIR}/cosmic-clang/bin:$PATH"
    
	fi
	
    # Clone AnyKernel
    # git clone --depth=1 https://github.com/missgoin/AnyKernel3.git

	}


##------------------------------------------------------##
# Export Variables
function exports() {

        if [ -d ${KERNEL_DIR}/cosmic ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/cosmic/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')        
        
        elif [ -d ${KERNEL_DIR}/cosmic-clang ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/cosmic-clang/bin/clang --version | head -n 1 | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')       
                
        elif [ -d ${KERNEL_DIR}/aosp-clang ];
            then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/aosp-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
        fi
        
        # Export ARCH and SUBARCH
        export ARCH=arm64
        export SUBARCH=arm64
        
        # Export Local Version
        # export LOCALVERSION="-${VERSION}"
        
        # KBUILD HOST and USER
        export KBUILD_BUILD_HOST=Pancali
        export KBUILD_BUILD_USER="unknown"
        
	    export PROCS=$(nproc --all)
	    export DISTRO=$(source /etc/os-release && echo "${NAME}")
	    
	    # Server caching for speed up compile
	    # export LC_ALL=C && export USE_CCACHE=1
	    # ccache -M 100G
	
	}
        

##----------------------------------------------------------##
# Compilation
function compile() {
START=$(date +"%s")
		
	# Compile
	make O=out ARCH=arm64 ${DEFCONFIG}	

	if [ -d ${KERNEL_DIR}/cosmic-clang ];
	   then
	       make -j$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=clang \
	       CROSS_COMPILE=aarch64-linux-gnu- \
	       CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
	       LD=${LINKER} \
	       #LLVM=1 \
	       #LLVM_IAS=1 \
	       AR=llvm-ar \
	       #AS=llvm-as \
	       NM=llvm-nm \
	       OBJCOPY=llvm-objcopy \
	       OBJDUMP=llvm-objdump \
	       STRIP=llvm-strip \
	       #READELF=llvm-readelf \
	       #OBJSIZE=llvm-size \
	       V=$VERBOSE 2>&1 | tee error.log
	       
	fi
}

##----------------------------------------------------------------##
function zipping() {
	# Copy Files To AnyKernel3 Zip
	cp $IMAGE AnyKernel3
	# cp $DTBO AnyKernel3
	# find $DTB -name "*.dtb" -exec cat {} + > AnyKernel3/dtb
	
	# Zipping and Push Kernel
	cd AnyKernel3 || exit 1
        zip -r9 ${ZIPNAME} *
        MD5CHECK=$(md5sum "$ZIPNAME" | cut -d' ' -f1)
        echo "Zip: $ZIPNAME"
        # curl -T $ZIPNAME temp.sh; echo
        curl -T $ZIPNAME https://oshi.at
        # curl --upload-file $ZIPNAME https://free.keep.sh
    cd ..
    
}

##----------------------------------------------------------##

cloneTC
exports
compile
zipping

##----------------*****-----------------------------##