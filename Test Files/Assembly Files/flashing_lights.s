main_loop:

# sequence starts at address 20, $s0 = the next empty space in memory where new color should be stored
addi $s0, $r0, 20

_led_sequence:
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
        j _loop_led_flash

    _exit_led_loop:
        # increment the next empty space in the sequence
        addi $s0, $s0, 1
        # jal check_buttons
        j _led_sequence

# check_buttons:


# flashes an LED 
flash_led:
    # passing in $a0 = color that we should turn on
    # $t5 is 32 bit num with color as [2:1] bits and [0] -> 1 if led should be on, 0 if off
    sll $t5, $a0, 1
    addi $t5, $t5, 1
    # flash new LED (turn on and then delay and then turn off)
    sw $t5, 6($r0)

    # $t6 = 1, $t7 = 2^19
    addi $t6, $r0, 1
    sll $t7, $t6, 19
    # loop until $r21 >= $r22, $r21++ at end of loop
    # basically delay/keep LED on for one second
    _led_loop1:
    blt $t7, $t6, _turnoff_led
    nop
    nop
    nop
    addi $t6, $t6, 1
    j _led_loop1

    _turnoff_led:
    # turn led off
    addi $t5, $t5, -1
    sw $t5, 6($r0)
    jr $ra