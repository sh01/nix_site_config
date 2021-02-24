#!/bin/sh


#PATH=$PATH:${pkgs.utillinux}/bin:${pkgs.e2fsprogs}/bin
img=$1
if [ ! -e "$img" ]; then
    echo "Nonexistent path: $img"
    exit -1
fi

mdir=$(mktemp -d)
echo "Mount dir: $mdir"
idev=$(losetup -o 1048576 --show -f $img) || exit -1
echo "Dev: $idev"
echo "Stripping files ..."
mount $idev $mdir && rm -rf $mdir/nix && umount $mdir
rmdir $mdir || exit -1

echo "Resizing FS..."
e2fsck -f $idev || exit -1
resize2fs -p $idev 120M || exit -1
losetup -d $idev

echo "Rewriting partition table."
echo """
label: dos
label-id: 0x28941e83
device: nixos.img
unit: sectors

nixos.img1 : start=        2048, size=     245760, type=83
""" | sfdisk $img || exit -1

echo "Truncating image file."
truncate -s 128M $img || exit -1
