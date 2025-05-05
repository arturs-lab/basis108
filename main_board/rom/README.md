Labels like 'd4' indicate location of the chip on Basis108 main board.

d4 - Starlight software d000-efff - this memory area is used for Basic ROM in original Apple

d5 - BASIC ROM - lower half of this EPROM is visible in Apple mode at $F000-$FFF. There is more code in the upper half of this EPROM. It seems to be similar to the lowewr half. Perhaps these are two copies of the same data but they got corrupted and now look slightly different. Or similar but different code that is bank-switched. The two halves can be compared using something like ```diff -W 40 --side-by-side -a <(xxd -ps -c 8 d5_label_2024.bin) <(dd if=d5.bin bs=1 skip=4096 | xxd -ps -c 8) | less```

g14 - printer driver According to the manual only 256 bytes of this chip is being used in address space of $C100-$C1FF (Apple addressing, $E100 in CP/M). But there is more code within this chip. Perhaps some trickery is done to use other parts of it to bank-switch code. Data visible to computer start at this location in EPROM: 0040: 00 20 62 C1 90

h4 - Character generator

c14_kbd_rom_AL.bin - translates data from keyboard to apple. 1:1 mapping so for a while I just had wires in the socket as seen in old photos. To replace them with an EEPROM, I wrote quick program outputting values to a file in a loop and repeated that several times. Since I ended up with a file only half as long as EEPROM size, I loaded that file twice in Xgecu software to fill EEPROM.

c14_kbord_orig.bin - original translation rom for c14. This one has some exceptions in mappings and only partial mappings.

fdc - floppy drive controller ROM in floppy controller directory

kbd_rom.bin - keyboard firmware pulled from original keyboard. I believe it had a 6800 CPU or something like HD6303. Code would have to be analyzed to determine whch is more likely. I'm leaning towards 6800 because at some point I wrote disassembler for it probably hoping to reverse-engineer the keyboard. Some day...

Some of the MD5 sums for the bin files differ for the same file across its versions. It is possible that the EPROM chips are losing their data and getting corrupted. Or they were read incorrectly in the past using the primitive methods I had available at the time. For this reason I am keeping multiple versions of these files in case another version needs to be tried once corruption is detected.

Files mentioning 2025 were dumped in 2025 by pulling chips and reading them with Xgecu TL866II-Plus programmer.
Files mentioning 2024 I believe were dumped the same way as 2025. Yet, the MD5 sums for some of them differ from 2025 versions.
Files just indicating location (e.g. g14.bin) were created from original *.hex files which were created back in the 90s. The hex file was read into Xgecu software and re-saved as bin. 
Files with extension of .hex and .asc were the first dump of ROMS I have. It is possible that they were originally created by reading original EPROMs using home made EPROM interface connected to ZX Spectrum clone and later transferred to CP/M. Then transferred to PC as disk image and extracted from it. A lot could have gotten corrupted in-between.
Files in directory 1995 are, I believe, dumps of ZX Spectrum tape binary files. They contain 19 byte header in ZX Spectrum format followed by contents of EPROM.

Simple way to compare two bin files:
diff -W 40 --side-by-side -a <(xxd -ps -c 8 d5_label_2024.bin) <(xxd -ps -c 8 d5_label_2025.bin) | less

1576a94d6cb334dd126cb1c27f19e0f2  c14_kbd_rom_AL.bin
dd5eed3d100baf9d3edb9eb0ba70071f  c14_kbord_orig.bin
54eeec8ae5980d63f1eb5b0c484399d6  d4.bin
98ab68f29770cf18be918f73b6e5ad8c  d4_starlight_2024.bin
98ab68f29770cf18be918f73b6e5ad8c  d4_starlight_2025.bin
bcaa84a76a547e1f8acba9525073f068  d5.bin
cfe2c4aa8eed8fe9955d166b73957061  d5_label_2024.bin
45e97c54fc85d5095fced5f40a284ec6  d5_label_2025.bin
9691479205a352a6179de522be4298ed  g14.bin
efe58797f3d49fb3b34048ff378cb270  g14_printer_2024.bin
9691479205a352a6179de522be4298ed  g14_printer_2025.bin
81601b9abea937adbe3f89ef6c5e1553  h4.bin
81601b9abea937adbe3f89ef6c5e1553  h4_chargen_2024.bin
81601b9abea937adbe3f89ef6c5e1553  h4_chargen_2025.bin

5e2a969ad1d5575d9e169bdedf32ebbf  /floppy_controller/rom/fdc.bin
7e06c18cf58ac32b30155759817559a8  /keyboard/rom/kbd.bin

MD5 sums after stripping off first 19 bytes of file in 1995 dir:
81601b9abea937adbe3f89ef6c5e1553  1995/rom_cgen.bin
dd5eed3d100baf9d3edb9eb0ba70071f  1995/romkbd1.bin - this is keyboard mapping rom on main board
7e06c18cf58ac32b30155759817559a8  1995/romkbd.bin  - this is Keyboard firmware ROM on keyboard board itself
cfe2c4aa8eed8fe9955d166b73957061  1995/romlabel.bin
efe58797f3d49fb3b34048ff378cb270  1995/romprntr.bin
98ab68f29770cf18be918f73b6e5ad8c  1995/romstar.bin
