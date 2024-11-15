_check_buttons:
# check for button press
lw $r1, 7($r0)
# turn led based on button press 
sw $r1, 6($r0)

j _check_buttons

