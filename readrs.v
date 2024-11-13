module readrs(opcode, reads_rs);
    input [4:0] opcode;
    output reads_rs;
    // reads rs if opcode=0 (R-type), addi, lw, sw, bne, and blt
    assign reads_rs = &(~opcode) || (!opcode[4] & !opcode[3] & opcode[2] & !opcode[1] & opcode[0])
        || (!opcode[4] & opcode[3] & !opcode[2] & !opcode[1] & !opcode[0])
        || (!opcode[4] & !opcode[3] & opcode[2] & opcode[1] & opcode[0]) 
        || (!opcode[4] & !opcode[3] & !opcode[2] & opcode[1] & !opcode[0]) 
        || (!opcode[4] & !opcode[3] & opcode[2] & opcode[1] & !opcode[0]);
        
endmodule