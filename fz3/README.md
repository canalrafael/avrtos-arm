Since Github restricts uploading very large files, I am sharing the image files used to build the petalinux on the FZ3 board on a google drive (https://drive.google.com/drive/folders/1zkICoSKZKcHdXimBomP3ZbNWCIoGwqEW?usp=sharing) for anyone interested. Generally, to run it, you need an SD card with two partitions: a FAT32 partition of at least 500MB and an ext4 partition.

You must copy BOOT.BIN and image.ub to the BOOT partition (FAT32) and extract rootfs.tar.gz onto the ext4 partition.
