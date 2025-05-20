#!/bin/bash

cd ~/data/emulation/basis108/main_board/rom/

for file in d5.bin d5_label_2024.bin d5_label_2025.bin; do
  outfile="${file/.bin/}"
  dd if=../main_board/rom/${file} bs=4096 count=1 | xxd -c 1 -g 1 -o 0xf000 | cut -c -14 > ${outfile}_lo.hex
  dd if=../main_board/rom/${file} bs=4096 count=1 skip=1 | xxd -c 1 -g 1 -o 0xf000 | cut -c -14 > ${outfile}_hi.hex
done

