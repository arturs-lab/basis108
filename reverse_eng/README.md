# Disassembly of code
Reverse engineering code from Basis 108 ROMs and CPM floppies to understand CPM boot process

Boot sectors from CP/M disk tracks 0 - 2 get loaded into memory starting at $800, then code gets executed starting from $801

# Notes

6502 reset/NMI vectors
$fffa faaa	; NMI
$fffc	fa62	; reset
$fffe	fa40	; IRQ/BRK

manual page 56
3f0,3f1	break handler
3f2,3f2	warm start ( monitor Q uses this vector)
3f3		einshalt byte
3f5,6,7	jump command for fpbasic subroutine. normally 4c 58 ff
3f8,9,a	jump command for USER (U) call
3fb,c,d	jump to NMI handler
3fe,f		INT handler vector
4f9	0=40 char !=0 = 80 char

memory banks page 58
	Bank 0		Bank 1
	active 		aactive 		Adress space
	$C060w 		$C061w		$0000 $1FFF
	$C062w 		$C063w		$2000 $3FFF
	$C064w 		$C065w		$4000 $5FFF
	$C066w 		$C067w		$6000 $7FFF
	$C068w 		$C069w		$8000 S9FFF
	$C06Aw 		$C06Bw		$A000 $BFFF
	$C06Cw 		$C06Dw		$D000 $DFFF
	$CO6Ew 		$CO6Fw		$E000 $FFFF

The static RAM for the 80 column display
$C00Dw Additional RAM switched on, normal RAM switched off
$C00Cw Additional RAM switched off, Normal RAM switched on

io ports page 97

z80 part page 99
Mapping of Z80 address space to 6502 address space
	Z-80 Adresses	6502 Adresses
	$0000-$0FFF	$1000-$1FFF
	$1000-$1FFF	$2000-$2FFF
	...	
	$A000-$AFFF	$B000-$BFFF
	$B000-$BFFF	$DO0O0-$DFFF
	$C000-$CFFF	$E000O-$EFFF
	$D000-$DFFF	$FO0OO-$FFFF
	$E000-$EFFF	$C000-$CFFF
	$F000-$FFFF	$0000-$0FFF


