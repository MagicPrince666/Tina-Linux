#!/bin/bash

set -ex
# [ $# -eq 6 ] || {
#     echo "SYNTAX: $0 <file> <bootfs image> <rootfs image> <bootfs size> <rootfs size> <u-boot image>"
#     exit 1
# }

FAT32_BLOCK_SIZE=1024
FAT32_BLOCKS=20480

OUTPUT=d1_mqpro_tfcard_boot.img
BOOTFS=d1_mqpro_tfcard.boot
ROOTFS=out/d1-mq_pro/image/rootfs.fex
BOOTFSSIZE=20480
ROOTFSSIZE=40
UBOOT=out/d1-mq_pro/image/boot0_sdcard.fex

if [ -f $BOOTFS ]; then
  rm -f $BOOTFS
fi

mkfs.fat $BOOTFS -C $BOOTFSSIZE

out/host/bin/mcopy -i $BOOTFS out/d1-mq_pro/image/env.fex ::env.fex
out/host/bin/mcopy -i $BOOTFS out/d1-mq_pro/image/sunxi.dtb ::sunxi.dtb

head=2
sect=63

set $(out/host/bin/ptgen -o $OUTPUT -h $head -s $sect -l 1024 -t c -p ${BOOTFSSIZE}M -t 83 -p ${ROOTFSSIZE}M)

BOOTOFFSET=$FAT32_BLOCKS
ROOTFSOFFSET="$(($ROOTFSSIZE * 1024))"

dd bs=1024 if="$UBOOT" of="$OUTPUT" seek=8 conv=notrunc
dd bs=1 if=out/d1-mq_pro/image/u-boot.fex of="$OUTPUT" seek=$((0x1013C00))
dd bs=1 if=out/d1-mq_pro/image/opensbi.fex of="$OUTPUT" seek=$((0x1004800))
dd bs=1 if=out/d1-mq_pro/image/boot_package.fex of="$OUTPUT" seek=$((0x1004000))

dd bs=1024 if="$BOOTFS" of="$OUTPUT" seek="$BOOTOFFSET" conv=notrunc
dd bs=1024 if="$ROOTFS" of="$OUTPUT" seek="$ROOTFSOFFSET" conv=notrunc

# dd if=out/d1-mq_pro/image/boot0_sdcard.fex of=d1_mqpro_tfcard_boot.img bs=1K seek=8
# dd if=out/d1-mq_pro/image/u-boot.fex of=d1_mqpro_tfcard_boot.img bs=1 seek=$((0x1013C00))
# dd if=out/d1-mq_pro/image/opensbi.fex of=d1_mqpro_tfcard_boot.img bs=1 seek=$((0x1004800))
# dd if=out/d1-mq_pro/image/boot_package.fex of=d1_mqpro_tfcard_boot.img bs=1 seek=$((0x1004000))