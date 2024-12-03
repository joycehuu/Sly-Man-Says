addi $t0, $r0, 0
addi $t1, $r0, 1
addi $t2, $r0, 2
addi $t3, $r0, 3
addi $t4, $r0, 4

_loop:
    sw $t1, 9($r0)
    jal delay
    sw $t0, 9($r0)
    jal delay
    sw $t2, 9($r0)
    jal delay
    sw $t0, 9($r0)
    jal delay
    sw $t3, 9($r0)
    jal delay
    sw $t0, 9($r0)
    jal delay
    sw $t4, 9($r0)
    jal delay
    sw $t0, 9($r0)
    jal delay
    j _loop

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