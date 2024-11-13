module instruction_decoder(instruction, opcode, rd, rs, rt, shamt, aluop, immediate, target);
    // don't really use but left in case I want to use the code
    input[31:0] instruction;
    output[4:0] opcode, rd, rs, rt, shamt, aluop;
    output[16:0] immediate;
    output[26:0] target; 

    assign opcode = instruction[31:27];
    assign rd = instruction[26:22];
    assign rs = instruction[21:17];
    assign rt = instruction[16:12];
    assign shamt = instruction[11:7];
    assign aluop = instruction[6:2];
    assign immediate = instruction[16:0];
    assign target = instruction[26:0];
endmodule