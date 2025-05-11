I could not capture any pulses on READY or INDEX lines. The drive does have an index sensor but apparently it's been disabled.

On DATA line, 3 types of pulses during data transfer:
all pulses 1us wide
4us apart
7.5us apart
11.5us apart - this may be some sort of separator

Index pulses are present on index photodiode, but not on pin 8 of cable which is constantly low. They do appear on pin 8 once it gets pulled up to 5V through a 1K resistor. This suggests that the controller does not use index pulses.


