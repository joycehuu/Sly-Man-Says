module writesrd(opcode, writes_rd);
    input [4:0] opcode;
    output writes_rd;
    // writes rd if opcode=0 (R-type), addi
    assign writes_rd = &(~opcode) || (!opcode[4] & !opcode[3] & opcode[2] & !opcode[1] & opcode[0]);

endmodule