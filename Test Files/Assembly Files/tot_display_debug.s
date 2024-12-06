# r10 = user score
# start of sequence stored in address 20 in memory

# IO Addresses:
# lw to address 5 = get random number
# sw to address 6 = flash LED 
# lw to address 7 = check for button presses

main_loop:
# in $s7 will be long delay value, $s6 = short delay value
addi $t0, $r0, 1
sll $s7, $t0, 22
addi $t0, $r0, 1
sll $s6, $t0, 21

# sequence starts at address 20, $s0 = the next empty space in memory where new color should be stored
addi $s0, $r0, 20
addi $sp, $sp, 10000

# at the beginning flash all LEDs and play all noises 
addi $t1, $r0, 7
addi $t0, $r0, 1

# initialize score to 0
addi $s5, $r0, 0

_flash_all:
    blt $t1, $t0 _exit_beg
    # flash red
    sw $t1, 6($r0)
    # play audio
    sw $t1, 8($r0)

    # short delay
    addi $a0, $s6, 0
    jal delay

    # turn led off
    addi $t1, $t1, -1
    sw $t1, 6($r0)
    # play audio
    sw $t1, 8($r0)

    # move to next color
    addi $t1, $t1, -1
    j _flash_all

_exit_beg: 
    # short delay
    addi $a0, $s6, 0
    jal delay

_led_sequence:
    # update score
    sw $s5, 10($r0)

    # get random num
    lw $t0, 5($r0)
    # zero out the upper 30 bits (lower 2 bits = color) = $t2
    addi $t1, $r0, 3
    and $t2, $t1, $t0
    # store the color at end of sequence in memory
    sw $t2, 0($s0)
    # $s1 = my counter for where I currently am in the sequence
    addi $s1, $r0, 20

    _loop_led_flash:
        blt $s0, $s1, _exit_led_loop
        # start reading from sequence
        lw $a0, 0($s1)
        # flash the light that's next in sequence
        jal flash_led
        # increment to next color in sequence
        addi $s1, $s1, 1

        # long delay
        addi $a0, $s7, 0
        jal delay
        j _loop_led_flash

    _exit_led_loop:
        # increment the next empty space in the sequence
        addi $s0, $s0, 1
        addi $a0, $s0, 0
        jal check_buttons
        # $v0 != 0 means user messed up and end game
        bne $v0, $r0, _end_game
        # otherwise keep continuing the sequence
        # increase score
        addi $s5, $s5, 1
        j _led_sequence

_end_game:
    nop
    nop

    # turn on all leds
    # addi $t0, $r0, 1
    # sw $t0, 6($r0)
    # addi $t1, $r0, 3
    # sw $t1, 6($r0)
    # addi $t2, $r0, 5
    # sw $t2, 6($r0)
    # addi $t3, $r0, 7
    # sw $t3, 6($r0)

    # play audio
    addi $t0, $r0, 9
    sw $t0, 8($r0)

    # flash $t5 = the correct color they were supposed to press
    sll $t0, $t5, 1
    addi $t0, $t0, 1
    # flash new LED (turn on and then delay and then turn off)
    sw $t0, 6($r0)
    # short delay
    addi $a0, $s6, 0
    jal delay
    addi $t0, $t0, -1
    sw $t0, 6($r0)
    # short delay
    addi $a0, $s6, 0
    jal delay

    # turn on
    addi $t0, $t0, 1
    sw $t0, 6($r0)
    # short delay
    addi $a0, $s6, 0
    jal delay

    addi $t0, $t0, -1
    sw $t0, 6($r0)
    # short delay
    addi $a0, $s6, 0
    jal delay

    # turn off all LEDs
    # addi $t0, $r0, 0
    # sw $t0, 6($r0)
    # nop
    # nop
    # addi $t0, $r0, 2
    # sw $t0, 6($r0)
    # addi $t0, $r0, 4
    # sw $t0, 6($r0)
    # addi $t0, $r0, 6
    # sw $t0, 6($r0)

    # turn off audio
    addi $t0, $r0, 8
    sw $t0, 8($r0)

    j _do_nothing

_do_nothing:
    nop 
    nop
    j _do_nothing

check_buttons:
    # passed into the argument register is where the end of the sequence is in memory
    # returns 1 if user messed up and end game
    # returns 0 if user got all right
    addi $sp, $sp, -4
    sw $s0, 0($sp)
    sw $s1, 1($sp)
    sw $s2, 2($sp)
    sw $ra, 3($sp)

    # $s0 = where we are in the sequence
    # $s2 = end of sequence
    addi $s0, $r0, 20
    addi $s2, $a0, 0

    # Check that user pressed a button
    _wait_button_press:
        lw $t4, 7($r0)
        addi $t1, $r0, 1
        # getting the lsb and seeing if button pressed, 0 = no button press, 1 = pressed
        and $t3, $t1, $t4
        bne $t3, $r0, _check_correct_button
        # otherwise if lsb = 0, no button was pressed so keep waiting/looping
        j _wait_button_press

    _check_correct_button:
        addi $t1, $r0, 6
        # $s1 = the color of button pressed
        and $s1, $t1, $t4
        sra $s1, $s1, 1
        addi $a0, $s1, 0
        jal flash_led
        # loading in the color of sequence
        lw $t5, 0($s0)
        bne $t5, $s1, _wrong_color
        # otherwise user got it correct, move on to next color
        addi $s0, $s0, 1

        # delay bc button press issues
        # short delay
        addi $a0, $s6, 0
        jal delay

        # keep waiting for button press if we haven't reached end of sequence
        bne $s0, $s2 _wait_button_press
        j _correct_color
    
    _correct_color:
        addi $v0, $r0, 0
        j _clean_check_buttons

    _wrong_color:
        addi $v0, $r0, 1

    _clean_check_buttons:
        lw $s0, 0($sp)
        lw $s1, 1($sp)
        lw $s2, 2($sp)
        lw $ra, 3($sp)
        addi $sp, $sp, 4
        jr $ra

# flashes an LED 
flash_led:
    addi $sp, $sp -2
    sw $s0, 0($sp)
    sw $ra, 1($sp)

    # passing in $a0 = color that we should turn on
    # $t5 is 32 bit num with color as [2:1] bits and [0] -> 1 if led should be on, 0 if off
    sll $s0, $a0, 1
    addi $s0, $s0, 1
    # flash new LED (turn on and then delay and then turn off)
    sw $s0, 6($r0)
    # play audio
    sw $s0, 8($r0)

    # long delay
    addi $a0, $s7, 0
    jal delay

    # turn led off
    addi $s0, $s0, -1
    sw $s0, 6($r0)
    # play audio
    sw $s0, 8($r0)

    lw $s0, 0($sp)
    lw $ra, 1($sp)
    addi $sp, $sp, 2
    jr $ra

# two second delay
delay:
    # pass in $a0 = how much to delay...
    # $t6 = 1, $t7 = 2^22
    addi $t6, $r0, 1
    addi $t7, $a0, 0
    # loop until $t6 >= $t7, $t7++ at end of loop
    # basically delay/keep LED on for one second
    _led_loop1:
    blt $t7, $t6, _exit_delay
    nop
    nop
    nop
    addi $t6, $t6, 1
    j _led_loop1

    _exit_delay:
    jr $ra
