#!/bin/sh

loongarch32r-linux-gnusf-gcc -T linker.ld -nostdlib $1.s -o $1.elf
loongarch32r-linux-gnusf-objcopy --strip-all -O binary $1.elf $1.bin
./bin2coe.elf $1.bin > $1.coe
