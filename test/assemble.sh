#!/bin/bash

loongarch32r-linux-gnusf-gcc -T linker.ld -nostdlib `ls $1.{s,S} 2>/dev/null` -o $1.elf
loongarch32r-linux-gnusf-objcopy --strip-all -O binary $1.elf $1.bin
./bin2coe.elf $1.bin > $1.coe
