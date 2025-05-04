
Moll wrote:

> The Basis 108 is a computer similar to the Apple ][+ and capable
> of running DOS 3.3.
>
> Does anyone know anything about Basis-specific softswitches and 
> functionality such as paging for >64K RAM, support for 80 columns,
> etc.? I have the ROM and would like to emulate the machine.

Hey, Moll

I dug out my box of Basis manuals, and I was able to find the following
softswitches (there are a about a gagillion of them):

-----------------------------------
Character Generator:

A unique feature of the Basis 108 character generator is its
ability too display five character sets at one time, which are
softswitch selectable. For example:

When SW3 is "ON" a character set with 128 normal characters are
displayed. When switch 3 is "OFF", switches 1 and 2 permit
selection of any one of four character sets in the CG EPROM.
Thus, character sets for any language can be made available,
and selected for display from the keyboard. See tables below:

                                        SW0 SW1 SW2 SW3
Set 0 Standard Apple II 64 characters    0   0   0   0
Set 1 Standard ASCII   128 characters    0   1   0   x
Set 2 German           128 characters    0   0   1   x
Set 3 Optional         128 characters    0   1   1   x
Set 4 Full Set         128 characters    1   0   0   x

Switch "0" ($C006 = inverse, $C007 = blinking) provides inverse
or blinking characters for character sets 2, 3, 4.

-------------------------------------
Printer Interface:

The output data is written to the output addresss:

$C090 - $C097

...which automatically generates a strobe signal. The printer's
strobe acknowledge can be queried in the highest bit of the
address $C1C1. The standard driver routine is contained in a
256x8 ROM starting at address $C100

-----------------------------------------------

Serial RS-232c: (6551 ACIA)

Data Register    = $C098
Status Register  = $C099
Command Register = $C09A
Mode Register    = $C09B

Standard Driver Routine in ROM at $C100

-------------------------------------------

Cassette Interface:

Read-In = $C060
Output  = $C02x

Driver Routine in (Optional) 40-column version of the
Monitor ROM. (Special order only)

------------------------------------------

Speaker:

single chirp = $C03x

Program can be used to generate various tones.

-----------------------------------------

        Address         Function        R/W

80 Character RAM:

        $C00A           80 CHR OFF      W
        $C00B           80 CHR ON       W
        $C00C           Aux. 80 CHR OFF W
        $C00D           Aux. 80 CHR ON  W

Character Generator:

SW 3    $C000           Standard        W
        $C001           Basic Exp. ON   W
SW 2    $C002           CHR set 0 or 2  W
        $C003           CHR set 1 or 3  W
SW !    $C004           CHR set 0 or 1  W
        $C005           CHR set 2 or 3  W
SW 0    $C006           Inverse CHR     W
        $C007           Blinking CHR    W

Keyboard:

        $C008           Interrupt OFF   W
        $C009           Interrupt ON    W

Bank 0 / Bank 1 Switching:

        Bank 0  Bank 1  Address Space

        $C060   $C061   $0000 - $1FFF
        $C062   $C063   $2000 - $3FFF
        $C064   $C065   $4000 - $5FFF
        $C066   $C067   $6000 - $7FFF
        $C068   $C069   $8000 - $9FFF
        $C06A   $C06B   $A000 - $BFFF
        $C06C   $C06D   $D000 - $DFFF
        $C06E   $C06F   $E000 - $FFFF
-----------------------------------------

I/O Address Space:

$CFFF                   (Switch OFF Addr.
        Expan. ROM       For AUX ROM)
        on 
        Auxillary Cards
$C800
        S7 ROM
$C700
        S6 ROM
$C600
        S5 ROM
$C500
        S4 ROM
$C400
        S3 ROM
$C300
        S2 ROM
$C200                   (Z80 ON/OFF Switch)
        Parallel/Serial
        ROM
$C100   
        S7 I/O
$C0F0
        S6 I/O
$C0E0
        S5 I/O
$C0D0
        S4 I/O
$C0C0
        S3 I/O
$C0B0
        S2 I/O
$C0A0
        Built In I/O
$C000

--------------------------------------

There you go. There are more but these were in the System Overview Manual,
and I'm assuming they are the most commonly used switches. Let me know if
there is something more specific that you're looking for.

Ernest



