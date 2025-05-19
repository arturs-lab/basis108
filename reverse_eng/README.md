# Disassembly of code
Reverse engineering code from Basis 108 ROMs and CPM floppies to understand CPM boot process

Boot sectors from CP/M disk tracks 0 - 2 get loaded into memory starting at $800, then code gets executed starting from $801

## Notes
* 6502 reset/NMI vectors
```
$fffa	faaa	; NMI
$fffc	fa62	; reset
$fffe	fa40	; IRQ/BRK
```
## manual page 56
```
3f0,3f1	BRK handler vector
3f2,3f2	warm start vector ( monitor Q uses this vector)
3f3		einshalt byte
3f5,6,7	jump command for fpbasic subroutine. normally 4c 58 ff
3f8,9,a	jump command for USER (U) call
3fb,c,d	jump to NMI handler
3fe,3ff	INT handler vector
4f9	     0=40 char !=0 = 80 char
```
## memory banks page 58

| Bank 0 active | Bank 1 active | Adress space |
|---------|---------|--------------|
|  $C060w |  $C061w |  $0000 $1FFF |
|  $C062w |  $C063w |  $2000 $3FFF |
|  $C064w |  $C065w |  $4000 $5FFF |
|  $C066w |  $C067w |  $6000 $7FFF |
|  $C068w |  $C069w |  $8000 S9FFF |
|  $C06Aw |  $C06Bw |  $A000 $BFFF |
|  $C06Cw |  $C06Dw |  $D000 $DFFF |
|  $CO6Ew |  $CO6Fw |  $E000 $FFFF |

## The static RAM for the 80 column display
```
$C00Dw Additional RAM switched on, normal RAM switched off
$C00Cw Additional RAM switched off, Normal RAM switched on
```
* io ports page 97

## z80 part page 99
Controlling the Z-80 Section
The Z-80 section is controlled by write commands to the memory space, which normally contains
peripheral ROMs. It is very important to work with write commands to ensure that the 6502 
does not perform two accesses in a row (this would prevent switching back to the 6502).
When the BASIS 108 is turned on, the (RESET) signal turns off the Z-80 section.
The (RESET) signal is synchronized with the internal clock to ensure that a write operation 
cannot be interrupted. The Z-80 immediately enters a wait mode and remains there until 
the Z-80 section is activated.

After receiving a write command in the correct memory area, the Z-80 section is turned on. 
The Z-80 remains in a wait mode until a memory clock with address information for the 
Z-80 section appears. The Z-80 is now released from wait mode and runs without further wait cycles.
Upon receipt of another write command in the same memory area (this time from the Z-80 itself), 
the Z-80 is shut down. The memory addresses for controlling the Z-80 are:
`$C100 - $C1FF`

## Mapping of Z80 address space to 6502 address space
| Z-80 Adresses	| 6502 Adresses |
|---------------|---------------|
|  $0000-$0FFF  |  $1000-$1FFF  |
|  $1000-$1FFF  |  $2000-$2FFF  |
|              ...              |
|  $A000-$AFFF  |  $B000-$BFFF  |
|  $B000-$BFFF  |  $D000-$DFFF  |
|  $C000-$CFFF  |  $E000-$EFFF  |
|  $D000-$DFFF  |  $F000-$FFFF  |
|  $E000-$EFFF  |  $C000-$CFFF  |
|  $F000-$FFFF  |  $0000-$0FFF  |

## Summary of Input/Output Addresses
| Address | Read | Write |
|---|---|---|
| $C000 | Keyboard | Inverse |
| $C001 |  | Flash | 
| $C002 |  | SW1 off | 
| $C003 |  | SW1 on | 
| $C004 |  | SW2 off | 
| $C005 |  | SW2 on | 
| $C006 |  | 2 x 128 characters | 
| $C007 |  | 2 x 64 + 128 characters | 
| $C008 | Keyboard Extensions | Keyboard interrupt off | 
| $C009 |  | Keyboard interrupt on | 
| $C00A |  | 40 characters/line | 
| $C00B |  | 80 characters/line | 
| $C00C |  | Static RAM off | 
| $C00D |  | Static RAM on | 
| $C00E |  | $C08x active | 
| $C00F |  | $C08x blocked | 
| $C010 | Keyboard Strobe |  | 
| $C020 | Keyboard Output |  | 
| $C030 | Speaker |  | 
| $C04x | Utility Strobe | Utility Strobe | 
| $C050 | Graphics On |  | 
| $C051 | Graphics Off |  | 
| $C032 | Graphical Display |  | 
| $C053 | Mixed Graphics |  | 
| $C054 | Page 1 Active |  | 
| $C055 | Page 2 Active |  | 
| $C056 | LO-RES Graphics |  | 
| $C057 | HI-RES graphcs |  | 
| $C058 | TTL-0 low |  | 
| $C059 | TTL-0 high |  | 
| $C05A | TTL-1 low |  | 
| $C058 | TTL-1 high |  | 
| $C05C | TTL-2 low |  | 
| $C05D | TTL-2 high |  | 
| $C05E | TTL-3 low |  | 
| $C05F | TTL-3 high |  | 
| $C060 | Cassette Input | $0000 - $1FFF Bank 0 | 
| $C061 | TTL Input 1 | $0000 - S1FFF Bank 1 | 
| $C062 | TTL Input 2 | $2000 - S3FFF Bank 0 | 
| $C063 | TTL Input 3 | $2000 - S3FFF Bank 1 | 
| $C064 | Hand Controller 0 | $4000 - S5FFF Bank 0 | 
| $C065 | Hand Controller 1 | $4000 - $5FFF Bank 1 | 
| $C066 | Hand Controller 2 | $6000 - $7FFF Bank 0 | 
| $C067 | Hand Controller 3 | $6000 - $7FFF Bank 1 | 
| $C068 |  | $8000 - $9FFF Bank 0 | 
| $C069 |  | $8000 - $9FFF Bank 1 | 
| $C06A |  | $A000 - $BFFF Bank 0 | 
| $C06B |  | $A000 - $BFFF Bank 1 | 
| $C06C |  | $D000 - $DFFF Bank 0 | 
| $C06D |  | $D000 - $DFFF Bank 1 | 
| $C06E |  | $E000 - $FFFF Bank 0 | 
| $C06F |  | $E000 - $FFFF Bank 1 | 
| $C070 | Hand Controller Strobe |  | 
| $C08x | LC Control |  | 
| $C090 |  | Printer Parallel Output | 
| $C098 | Serial Input | Serial Output | 
| $C099 | Serial Status | Serial RESET | 
| $C09A | Serial Command | Serial Command | 
| $C09B | Serial Control | Serial Control | 
| $C0Ax | Slot 2 DEVICE Select | Slot 2 DEVICE Select | 
| ... |
| $C0Fx | Slot 7 DEVICE Select | Slot 7 DEVICE Select | 
| SC100 |  | Z80 On/Off | 
| SC1C1 | Printer Acknowledge |  | 

