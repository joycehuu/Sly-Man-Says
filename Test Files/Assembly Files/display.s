_loop:
addi $t1, $r0, 1
sw $t1, 10($r0)
jal delay
j _loop

# two second delay
delay:
    # $t6 = 1, $t7 = 2^22
    addi $t6, $r0, 1
    sll $t7, $t6, 22
    # loop until $r21 >= $r22, $r21++ at end of loop
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
