module lwdep(lw_insn, other_insn, stall_lw);
    input [31:0] lw_insn, other_insn;
    output stall_lw;
    wire[4:0] lw_opcode, lw_rd, lw_rs, lw_rt, ot_opcode, ot_rd, ot_rs, ot_rt;
    wire is_lw;
    assign lw_opcode = lw_insn[31:27];
    assign lw_rd = lw_insn[26:22];
    assign lw_rs = lw_insn[21:17];
    assign lw_rt = lw_insn[16:12];
    assign ot_opcode = other_insn[31:27];
    assign ot_rd = other_insn[26:22];
    assign ot_rs = other_insn[21:17];
    assign ot_rt = other_insn[16:12];
    
    assign is_lw = !lw_opcode[4] & lw_opcode[3] & !lw_opcode[2] & !lw_opcode[1] & !lw_opcode[0];

    // reads rd if opcode=0 (R-type), addi, sw, lw, bne, blt, jr, bex
    assign stall_lw = is_lw & ((&(~ot_opcode) & (lw_rd == ot_rs || lw_rd == ot_rt))
        || (!ot_opcode[4] & !ot_opcode[3] & ot_opcode[2] & !ot_opcode[1] & ot_opcode[0] & (lw_rd == ot_rs))
        || (!ot_opcode[4] & !ot_opcode[3] & ot_opcode[2] & ot_opcode[1] & ot_opcode[0] & (lw_rd == ot_rs)) 
        || (!ot_opcode[4] & ot_opcode[3] & !ot_opcode[2] & !ot_opcode[1] & !ot_opcode[0] & (lw_rd == ot_rs))
        || (!ot_opcode[4] & !ot_opcode[3] & !ot_opcode[2] & ot_opcode[1] & !ot_opcode[0] & (lw_rd == ot_rs || lw_rd == ot_rd)) 
        || (!ot_opcode[4] & !ot_opcode[3] & ot_opcode[2] & ot_opcode[1] & !ot_opcode[0] & (lw_rd == ot_rs || lw_rd == ot_rd))
        || (!ot_opcode[4] & !ot_opcode[3] & ot_opcode[2] & !ot_opcode[1] & !ot_opcode[0] & (lw_rd == ot_rd))
        || (ot_opcode[4] & !ot_opcode[3] & ot_opcode[2] & ot_opcode[1] & !ot_opcode[0] & (lw_rd == 5'd30)));

endmodule