################## Bao Hypervisor Demo Guide
sudo apt install build-essential bison flex git libssl-dev ninja-build \
    u-boot-tools pandoc libslirp-dev pkg-config libglib2.0-dev libpixman-1-dev \
    gettext-base curl xterm cmake python3-pip xilinx-bootgen

pip3 install pykwalify packaging pyelftools

##### Toolchain
export CROSS_COMPILE=/home/canal/FZ3/aarch64/arm-gnu-toolchain-14.3.rel1-x86_64-aarch64-none-elf/bin/aarch64-none-elf-
git clone https://github.com/bao-project/bao-demos
cd bao-demos

export PLATFORM=zcu102
export DEMO=linux+freertos

export ARCH=aarch64

export BAO_DEMOS=$(realpath .)
export BAO_DEMOS_WRKDIR=$BAO_DEMOS/wrkdir
export BAO_DEMOS_WRKDIR_SRC=$BAO_DEMOS_WRKDIR/srcs
export BAO_DEMOS_WRKDIR_BIN=$BAO_DEMOS_WRKDIR/bin
export BAO_DEMOS_WRKDIR_PLAT=$BAO_DEMOS_WRKDIR/imgs/$PLATFORM
export BAO_DEMOS_WRKDIR_IMGS=$BAO_DEMOS_WRKDIR_PLAT/$DEMO
mkdir -p $BAO_DEMOS_WRKDIR
mkdir -p $BAO_DEMOS_WRKDIR_SRC
mkdir -p $BAO_DEMOS_WRKDIR_BIN
mkdir -p $BAO_DEMOS_WRKDIR_IMGS

############## Build guests

export FREERTOS_PARAMS="STD_ADDR_SPACE=y"

################################### FreeRTOS
export BAO_DEMOS_FREERTOS=$BAO_DEMOS_WRKDIR_SRC/freertos

git clone --recursive --shallow-submodules\
    https://github.com/bao-project/freertos-over-bao.git\
    $BAO_DEMOS_FREERTOS --branch demo
make -C $BAO_DEMOS_FREERTOS PLATFORM=$PLATFORM $FREERTOS_PARAMS

cp $BAO_DEMOS_FREERTOS/build/$PLATFORM/freertos.bin $BAO_DEMOS_WRKDIR_IMGS
################################### Linux
export BAO_DEMOS_LINUX=$BAO_DEMOS/guests/linux

export BAO_DEMOS_LINUX_REPO=https://source.codeaurora.org/external/imx/linux-imx
export BAO_DEMOS_LINUX_VERSION=rel_imx_5.4.24_2.1.0

export BAO_DEMOS_LINUX_REPO=https://github.com/torvalds/linux.git
export BAO_DEMOS_LINUX_VERSION=v6.1

export BAO_DEMOS_LINUX_SRC=$BAO_DEMOS_WRKDIR_SRC/linux-$BAO_DEMOS_LINUX_VERSION

git clone $BAO_DEMOS_LINUX_REPO $BAO_DEMOS_LINUX_SRC\
    --depth 1 --branch $BAO_DEMOS_LINUX_VERSION
cd $BAO_DEMOS_LINUX_SRC
git apply $BAO_DEMOS_LINUX/patches/$BAO_DEMOS_LINUX_VERSION/*.patch

export BAO_DEMOS_LINUX_CFG_FRAG=$(ls $BAO_DEMOS_LINUX/configs/base.config\
    $BAO_DEMOS_LINUX/configs/$ARCH.config\
    $BAO_DEMOS_LINUX/configs/$PLATFORM.config 2> /dev/null)
    
export BAO_DEMOS_BUILDROOT=$BAO_DEMOS_WRKDIR_SRC/\
buildroot-$ARCH-$BAO_DEMOS_LINUX_VERSION
export BAO_DEMOS_BUILDROOT_DEFCFG=$BAO_DEMOS_LINUX/buildroot/$ARCH.config
export LINUX_OVERRIDE_SRCDIR=$BAO_DEMOS_LINUX_SRC

git clone https://github.com/buildroot/buildroot.git $BAO_DEMOS_BUILDROOT\
    --depth 1 --branch 2022.11
cd $BAO_DEMOS_BUILDROOT

make defconfig BR2_DEFCONFIG=$BAO_DEMOS_BUILDROOT_DEFCFG
make linux-reconfigure all
mv $BAO_DEMOS_BUILDROOT/output/images/Image\
    $BAO_DEMOS_BUILDROOT/output/images/Image-$PLATFORM
    
export BAO_DEMO_LINUX_VM=linux

dtc $BAO_DEMOS/demos/$DEMO/devicetrees/$PLATFORM/$BAO_DEMO_LINUX_VM.dts >\
    $BAO_DEMOS_WRKDIR_IMGS/$BAO_DEMO_LINUX_VM.dtb
    
make -C $BAO_DEMOS_LINUX/lloader\
    ARCH=$ARCH\
    IMAGE=$BAO_DEMOS_BUILDROOT/output/images/Image-$PLATFORM\
    DTB=$BAO_DEMOS_WRKDIR_IMGS/$BAO_DEMO_LINUX_VM.dtb\
    TARGET=$BAO_DEMOS_WRKDIR_IMGS/$BAO_DEMO_LINUX_VM
    
##################################### build bao
export BAO_DEMOS_BAO=$BAO_DEMOS_WRKDIR_SRC/bao
git clone https://github.com/bao-project/bao-hypervisor $BAO_DEMOS_BAO\
    --branch demo

mkdir -p $BAO_DEMOS_WRKDIR_IMGS/config
cp -L $BAO_DEMOS/demos/$DEMO/configs/$PLATFORM.c\
    $BAO_DEMOS_WRKDIR_IMGS/config/$DEMO.c

make -C $BAO_DEMOS_BAO\
    PLATFORM=$PLATFORM\
    CONFIG_REPO=$BAO_DEMOS_WRKDIR_IMGS/config\
    CONFIG=$DEMO\
    CPPFLAGS=-DBAO_DEMOS_WRKDIR_IMGS=$BAO_DEMOS_WRKDIR_IMGS

cp $BAO_DEMOS_BAO/bin/$PLATFORM/$DEMO/bao.bin\
    $BAO_DEMOS_WRKDIR_IMGS
    
# #################################### Firmeware ZCU10X
# git clone https://github.com/Xilinx/soc-prebuilt-firmware.git --depth 1 \
#    --branch xilinx_v2023.1 $BAO_DEMOS_WRKDIR_SRC/zcu-firmware
# cd $BAO_DEMOS_WRKDIR_SRC/zcu-firmware/$PLATFORM-zynqmp && 
#    bootgen -arch zynqmp -image bootgen.bif -w -o $BAO_DEMOS_WRKDIR_PLAT/BOOT.BIN
# #OR OR OR ##    
# # sudo git clone https://github.com/Xilinx/soc-prebuilt-firmware.git --depth 1     --branch xlnx_rel_v2023.1 $BAO_DEMOS_WRKDIR_SRC/zcu-firmware    
# # cd $BAO_DEMOS_WRKDIR_SRC/zcu-firmware/$PLATFORM-zynqmp && 
# #    bootgen -arch zynqmp -image bootgen.bif -w -o $BAO_DEMOS_WRKDIR_PLAT/BOOT.BIN
   
# mkimage -n bao_uboot -A arm64 -O linux -C none -T kernel -a 0x200000\
#    -e 0x200000 -d $BAO_DEMOS_WRKDIR_IMGS/bao.bin $BAO_DEMOS_WRKDIR_IMGS/bao.img
# ##################################### sdcard
# # umount /dev/mmcblk0*

# # sudo fdisk /dev/mmcblk0

# # Then run the commands:
# #     Press d until there are no more partitions (if it asks you for the partition, press return for the default)
# #     Press w write changes and exit

# # sudo fdisk /dev/mmcblk0
# # Then run the commands:
# #     o to create a new empty DOS partition table
# #     n to create a new partition. Select the following options:
# #         p to make it a primary partition
# #         the automatically assigned partition number by pressing return
# #         16384 (this gap is needed for some of the selected boards)
# #         the max default size by pressing return
# #         if it asks you to remove the file system signature press y
# #     a to make the partition bootable
# #     t to set the partition type:
# #         type c for W95 FAT32 (LBA)
# #     w to write changes and exit

# # sudo mkfs.fat /dev/mmcblk0p1 -n boot

# #VER NOME DO CARTAO
# export BAO_DEMOS_SDCARD_DEV=/dev/sda
# export BAO_DEMOS_SDCARD=/media/$USER/boot
    
# sudo cp $BAO_DEMOS_WRKDIR_PLAT/BOOT.BIN $BAO_DEMOS_SDCARD
# # sudo cp /home/canal/FZ3/bao-demos/wrkdir/srcs/zcu-firmware/zcu102-zynqmp/BOOT.BIN $BAO_DEMOS_SDCARD

# sudo cp $BAO_DEMOS_WRKDIR_IMGS/bao.img $BAO_DEMOS_SDCARD
# # sudo cp /home/canal/FZ3/bao-demos/wrkdir/imgs/zcu102/linux+freertos/bao.img $BAO_DEMOS_SDCARD


# umount $BAO_DEMOS_SDCARD

# ######SET UP
# # screen /dev/ttyUSB1 115200
# #OR OR OR OR
# #VER NOME DO CARTAO
# # sudo minicom -D /dev/ttyUSB0

# # fatload mmc 0 0x200000 bao.img; bootm start 0x200000; bootm loados; bootm go