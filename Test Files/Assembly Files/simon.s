nop             
nop             
nop             
nop

# REGISTERS: 
# r10 = user score
# start of sequence stored in address 20 in memory

# IO Addresses:
# lw to address 5 = get random number
# sw to address 6 = flash LED 
# lw to address 7 = check for button presses

# initializing $r10 = 0, $r10 = user's score
addi $r10, $r0, 0
addi $r20, $r0, 20

_sequence:
# flash the sequence of LEDs, it starts at address 20
lw $r1, 0($r20)
bne $r1, $r0, _continue
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
addi $r22, $r0, 50000000

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

# check for button inputs
j _button_press

_continue:
# now choose the button LED to flash, address 6 = LEDs ($r1 = 0-3)
sw $r1, 6($r0)
# move on to next color
addi $r20, $r20, 1
j _sequence

_button_press:
# now check for button input: lw address 7 = buttons
# ?? should this loop in verilog code or mips...?
# sequence to start at begining
addi $r20, $r0, 20
_button_loop: 
# check what the color should be
sw $r4, 0($r20)
bne $r4, $r0, _check_buttons # we haven't reached end of loop yet
# if we reached the end of the loop, jump back to sequence
# increase user's score by 1 
addi $r10, $r10, 1
j _sequence

_check_buttons:
# button press
lw $r2, 7($r0)
# end game if user didn't press the same button
bne $r4, $r2, _end
# otherwise go back to loop to check next color
addi $r20, $r20, 1
j _button_loop

_end:
# display score on the 7 segment display, address 8 = 7seg display
sw $r10, 8($r0)
