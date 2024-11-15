# testing
_sequence:
# if the value is 0 aka uninitialized, add new color
# read in a random number: lw @ address 5 is random num
# random number (1-4) now stored in $r3
lw $r3, 5($r0)
sll $r7, $r3, 1
addi $r7, $r7, 1
# store it at the end of the sequence
sw $r3, 0($r20)
# flash new LED (turn on and then delay and then turn off)
sw $r7, 6($r0)
addi $r21, $r0, 1
sll $r22, $r21, 

_led_loop1:
blt $r22, $r21, _turnoff_led
nop
nop
nop
addi $r21, $r21, 1
j _led_loop1

_turnoff_led:
# flash led off
addi $r7, $r7, -1
sw $r7, 6($r0)

j _sequence
