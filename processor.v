/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

    // Latch inputs
    wire not_clock, enable, enable_fd_pc_stall;
    wire [31:0] nop_insn;
    not falling_clk(not_clock, clock);
    // WE = 0 when (mult or div AND result not ready)
    //assign enable = (is_mult_x || is_div_x) & !multdiv_ready ? 1'b0 : 1'b1;
    assign enable = 1'b1;
    assign nop_insn = 32'b0;

    // STALLING LOGIC FOR LW
    wire [31:0] dx_insn, fd_insn;
    wire stall_lw, stall_pulse, ctrl_stall;
    lwdep lw_dep(.lw_insn(dx_insn), .other_insn(fd_insn), .stall_lw(stall_lw));
    // Creates a pulse that goes high for one cycle when stall_lw, then stays 0 
    dffe_ref pulse_stall(.q(stall_pulse), .d(stall_lw), .clk(not_clock), .en(1'b1), .clr(reset));
    assign ctrl_stall = !stall_pulse & stall_lw;

    assign enable_fd_pc_stall = ctrl_stall ? 1'b0 : enable;

    // PC register (all latches are on falling edge clocks)
    wire[31:0] pc_in, pc_out;
    wire temp1, temp2, temp3; // unnecessary variables for the pc_alu
    wire[31:0] next_pc, pc_plusone, branch_pc, j_pc, jal_pc; 
    wire is_jal, is_jr;
    // jal = 00011 (resolved in execute)
    assign is_jal = !opcode_x[4] & !opcode_x[3] & !opcode_x[2] & opcode_x[1] & opcode_x[0];
    // jr = 00100 resolved in execute
    assign is_jr = !opcode_x[4] & !opcode_x[3] & opcode_x[2] & !opcode_x[1] & !opcode_x[0];

    // PC decoding to see if we need to jump
    wire[4:0] opcode_pc;
    wire [31:0] jump_target1;
    assign opcode_pc = q_imem[31:27];
    assign jump_target1[26:0] = q_imem[26:0];
    assign jump_target1[31:27] = 5'd0;

    // pc_plusone = PC + 1, calculated by pc_alu
    alu pc_alu(.data_operandA(pc_out), .data_operandB(32'd1), .ctrl_ALUopcode(5'd0), .ctrl_shiftamt(5'd0), .data_result(pc_plusone), .isNotEqual(temp1), .isLessThan(temp2), .overflow(temp3));
    // pc_in = pc+1+T (branchTarget) if branch taken else pc+1
    assign branch_pc = branchTaken ? branch_target : pc_plusone;
    // if jump (00001) assign pc_in to jump_target1 (we jump immediately after reading insn/fetch stage, so no flush)
    assign j_pc = (!opcode_pc[4] & !opcode_pc[3] & !opcode_pc[2] & !opcode_pc[1] & opcode_pc[0]) ? jump_target1 : branch_pc;
    // if jal (00011), PC = T (but we do this in execute and flush twice)
    assign jal_pc = is_jal ? target_x : j_pc;
    // if jr (00100), then PC = rd (flush insn twice like jal)
    // BYPASSING for JR
    wire [31:0] jr_temp1, jr_temp2, jr_temp3, jr_temp4, jr_temp5, jr_temp6, jr_temp7, jr_temp8, jr_temp9;
    // bypassing for writeback
    assign jr_temp1 = (is_jr & (rd_x == rd_w) & (writes_rd_w || !opcode_w[4] & opcode_w[3] & !opcode_w[2] & !opcode_w[1] & !opcode_w[0])) ? data_writeReg : dx_B;
    assign jr_temp2 = (is_jr & (rd_x == 5'd30) & mw_rstat != 0) ? mw_rstat : jr_temp1;
    assign jr_temp3 = (is_jr & (rd_x == 5'd31) & !opcode_w[4] & !opcode_w[3] & !opcode_w[2] & opcode_w[1] & opcode_w[0]) ? mw_pc : jr_temp2;
    assign jr_temp4 = (is_jr & (rd_x == 5'd30) & opcode_w[4] & !opcode_w[3] & opcode_w[2] & !opcode_w[1] & opcode_w[0]) ? mw_insn[26:0] : jr_temp3;
    // NOW above but for rd, and memory stage
    assign jr_temp5 = (is_jr & (rd_x == rd_m) & writes_rd_m) ? xm_O : jr_temp4;
    assign jr_temp6 = (is_jr & (rd_x == 5'd30) & xm_rstat != 0) ? xm_rstat : jr_temp5;
    assign jr_temp7 = (is_jr & (rd_x == 5'd31) & !opcode_m[4] & !opcode_m[3] & !opcode_m[2] & opcode_m[1] & opcode_m[0]) ? xm_pc : jr_temp6;
    assign jr_temp8 = (is_jr & (rd_x == 5'd30) & opcode_m[4] & !opcode_m[3] & opcode_m[2] & !opcode_m[1] & opcode_m[0]) ? xm_insn[26:0] : jr_temp7;
    // if it's the zero register, always bypass the value zero
    assign jr_temp9 = ((rd_x == 0) & is_jr) ? 32'd0 : jr_temp8;
    assign pc_in = is_jr ? jr_temp9 : jal_pc;
    register pc(.Din(pc_in), .Qout(pc_out), .clk(not_clock), .en(enable_fd_pc_stall), .clr(reset));

    // PC_out goes into the insn memory
    assign address_imem = pc_out;

    // Fetch/decode register
    // instruction IR comes from insn mem (q_imem)
    wire[31:0] fd_pc, fd_in;
    // if we branch and need to flush the instruction, do nop
    // if jr, we flush the insn (00100) -> execute stage resolve
    // if jal (00011), flush insns -> execute stage resolved
    assign fd_in = (branchTaken || is_jal || is_jr) ? nop_insn : q_imem;
    fdreg fd(.PC_in(pc_plusone), .PC_out(fd_pc), .insn_in(fd_in), .insn_out(fd_insn), .clk(not_clock), .en(enable_fd_pc_stall), .clr(reset));

    // Decode stage, based on the instruction from the f/d latch
    wire[4:0] opcode_d, rd_d, rs_d, rt_d;
    assign opcode_d = fd_insn[31:27];
    assign rd_d = fd_insn[26:22];
    assign rs_d = fd_insn[21:17];
    assign rt_d = fd_insn[16:12];

    // Control bit (will need more logic/also choose Rd if branching)
    wire chooseRd;
    // Choose Rd if sw (11000), bne (00010), blt (00110), jr (00100)
    assign chooseRd = (!opcode_d[4] & !opcode_d[3] & opcode_d[2] & opcode_d[1] & opcode_d[0]) 
        || (!opcode_d[4] & !opcode_d[3] & !opcode_d[2] & opcode_d[1] & !opcode_d[0]) 
        || (!opcode_d[4] & !opcode_d[3] & opcode_d[2] & opcode_d[1] & !opcode_d[0])
        || (!opcode_d[4] & !opcode_d[3] & opcode_d[2] & !opcode_d[1] & !opcode_d[0]);
    // Inputing the controls into register file
    // if bex (10110) (readregA = $rstatus aka $r30)
    assign ctrl_readRegA = (opcode_d[4] & !opcode_d[3] & opcode_d[2] & opcode_d[1] & !opcode_d[0]) ? 5'd30 : rs_d;
    assign ctrl_readRegB = chooseRd ? rd_d : rt_d;

    // Decode/execute latch
    // A and B from reading reg file
    wire[31:0] dx_pc, dx_A, dx_B, dx_in;
    // if we branch and need to flush the instruction, do nop
    // also nop if jal (00011) or jr or need to stall for lw
    assign dx_in = branchTaken || is_jal || is_jr || stall_lw ? nop_insn : fd_insn;
    dxreg dx(.PC_in(fd_pc), .PC_out(dx_pc), .insn_in(dx_in), .insn_out(dx_insn), .A_in(data_readRegA), .A_out(dx_A), .B_in(data_readRegB), .B_out(dx_B), .clk(not_clock), .en(enable), .clr(reset));
    
    // Execute stage
    // Decoding again for this stage based on d/x latch
    wire[4:0] opcode_x, shamt_x, aluop_x, rs_x, rt_x, rd_x;
    wire[16:0] immediate_x;
    wire[31:0] target_x;
    assign rd_x = dx_insn[26:22];
    assign rs_x = dx_insn[21:17];
    assign rt_x = dx_insn[16:12];
    assign opcode_x = dx_insn[31:27];
    assign shamt_x = dx_insn[11:7];
    assign aluop_x = dx_insn[6:2];
    assign immediate_x = dx_insn[16:0];
    assign target_x[26:0] = dx_insn[26:0];
    assign target_x[31:27] = 5'd0;

    // instantiate ALU
    wire notEqual, lessThan, alu_overflow, isAddi, branchTaken; 
    wire [31:0] alu_out, alu_B, signext_immed, alu_out_no_multdiv; 
    wire[4:0] aluOpcode_in, aluOpcode_temp1;
    // Sign-extend the immediate
    assign signext_immed[16:0] = immediate_x;
    assign signext_immed[31:17] = immediate_x[16] ? 15'd32767 : 15'd0;
    // $rs + N when addi, sw, lw
    // addi op (00101), sw (00111), lw (010000)
    assign isAddi = (!opcode_x[4] & !opcode_x[3] & opcode_x[2] & !opcode_x[1] & opcode_x[0]) 
        || (!opcode_x[4] & !opcode_x[3] & opcode_x[2] & opcode_x[1] & opcode_x[0]) 
        || (!opcode_x[4] & opcode_x[3] & !opcode_x[2] & !opcode_x[1] & !opcode_x[0]);

    // BYPASS LOGIC
    wire [4:0] opcode_m, opcode_w;
    wire reads_rs_x, writes_rd_m, writes_rd_w, reads_rt_x, reads_rd_x;
    wire [31:0] alu_B_temp1, alu_B_temp2, alu_B_temp3, alu_B_temp4, alu_B_temp5, alu_B_temp6, alu_B_temp7, alu_B_temp8, alu_B_temp9, alu_B_temp10, alu_B_temp11, alu_B_temp12, alu_B_temp13, alu_B_temp14, alu_B_temp15, alu_B_temp16, alu_B_temp17;
    // if the writeback stage writes to $rd = $rs (that reads here), bypass
    assign alu_B_temp1 = ((rt_x == rd_w) & reads_rt_x & (writes_rd_w || !opcode_w[4] & opcode_w[3] & !opcode_w[2] & !opcode_w[1] & !opcode_w[0])) ? data_writeReg : dx_B;
    // if it's reg 30, check if ahead insn had an exception and choose exception
    assign alu_B_temp2 = ((rt_x == 5'd30) & reads_rt_x & mw_rstat != 0) ? mw_rstat : alu_B_temp1;
    // if it's reg 31, check if ahead insn is jal (00011), and write the PC+1 value
    assign alu_B_temp3 = ((rt_x == 5'd31) & reads_rt_x & !opcode_w[4] & !opcode_w[3] & !opcode_w[2] & opcode_w[1] & opcode_w[0]) ? mw_pc : alu_B_temp2;
    // if it's reg 30, check if it's setx (10101), and then assign target [26:0]
    assign alu_B_temp4 = ((rt_x == 5'd30) & reads_rt_x & opcode_w[4] & !opcode_w[3] & opcode_w[2] & !opcode_w[1] & opcode_w[0]) ? mw_insn[26:0] : alu_B_temp3;
    // NOW doing the above lines but for rd 
    assign alu_B_temp5 = ((rd_x == rd_w) & reads_rd_x & (writes_rd_w || !opcode_w[4] & opcode_w[3] & !opcode_w[2] & !opcode_w[1] & !opcode_w[0])) ? data_writeReg : alu_B_temp4;
    assign alu_B_temp6 = ((rd_x == 5'd30) & reads_rd_x & mw_rstat != 0) ? mw_rstat : alu_B_temp5;
    assign alu_B_temp7 = ((rd_x == 5'd31) & reads_rd_x & !opcode_w[4] & !opcode_w[3] & !opcode_w[2] & opcode_w[1] & opcode_w[0]) ? mw_pc : alu_B_temp6;
    assign alu_B_temp8 = ((rd_x == 5'd30) & reads_rd_x & opcode_w[4] & !opcode_w[3] & opcode_w[2] & !opcode_w[1] & opcode_w[0]) ? mw_insn[26:0] : alu_B_temp7;
    // NOW above but for rt, and memory stage
    assign alu_B_temp9 = ((rt_x == rd_m) & reads_rt_x & writes_rd_m) ? xm_O : alu_B_temp8;
    assign alu_B_temp10 = ((rt_x == 5'd30) & reads_rt_x & xm_rstat != 0) ? xm_rstat : alu_B_temp9;
    assign alu_B_temp11 = ((rt_x == 5'd31) & reads_rt_x & !opcode_m[4] & !opcode_m[3] & !opcode_m[2] & opcode_m[1] & opcode_m[0]) ? xm_pc : alu_B_temp10;
    assign alu_B_temp12 = ((rt_x == 5'd30) & reads_rt_x & opcode_m[4] & !opcode_m[3] & opcode_m[2] & !opcode_m[1] & opcode_m[0]) ? xm_insn[26:0] : alu_B_temp11;
    // NOW above but for rd, and memory stage
    assign alu_B_temp13 = ((rd_x == rd_m) & reads_rd_x & writes_rd_m) ? xm_O : alu_B_temp12;
    assign alu_B_temp14 = ((rd_x == 5'd30) & reads_rd_x & xm_rstat != 0) ? xm_rstat : alu_B_temp13;
    assign alu_B_temp15 = ((rd_x == 5'd31) & reads_rd_x & !opcode_m[4] & !opcode_m[3] & !opcode_m[2] & opcode_m[1] & opcode_m[0]) ? xm_pc : alu_B_temp14;
    assign alu_B_temp16 = ((rd_x == 5'd30) & reads_rd_x & opcode_m[4] & !opcode_m[3] & opcode_m[2] & !opcode_m[1] & opcode_m[0]) ? xm_insn[26:0] : alu_B_temp15;

    // if it's the zero register, always bypass the value zero
    assign alu_B_temp17 = ((rd_x == 0) & reads_rd_x) || ((rt_x == 0) & reads_rt_x) ? 32'd0 : alu_B_temp16;

    assign alu_B = isAddi ? signext_immed : alu_B_temp17; // Choose whether alu input should be the immediate or value from reg
    // Make the alu opcode add (00000) if it's addi
    assign aluOpcode_temp1 = isAddi ? 5'd0 : aluop_x;
    // Make the alu opcode sub (00001) if it's a blt (00110) or bne (00010)
    assign aluOpcode_in = (!opcode_x[4] & !opcode_x[3] & opcode_x[2] & opcode_x[1] & !opcode_x[0]) || (!opcode_x[4] & !opcode_x[3] & !opcode_x[2] & opcode_x[1] & !opcode_x[0]) ? 5'd1 : aluOpcode_temp1;
    
    // bypass X/M output into ALU if X/M writes to a reg that ALU uses
    wire [31:0] alu_A_temp1, alu_A_temp2, alu_A_temp3, alu_A_temp4, alu_A_temp5, alu_A_temp6, alu_A_temp7, alu_A_temp8, alu_Ain_bypass;
    readrs rs_read_x(.opcode(opcode_x), .reads_rs(reads_rs_x));
    writesrd rd_write_m(.opcode(opcode_m), .writes_rd(writes_rd_m));
    writesrd rd_write_w(.opcode(opcode_w), .writes_rd(writes_rd_w));
    assign reads_rt_x = &(~opcode_x);
    // bne, blt, and sw reads rd
    assign reads_rd_x = (!opcode_x[4] & !opcode_x[3] & !opcode_x[2] & opcode_x[1] & !opcode_x[0]) || (!opcode_x[4] & !opcode_x[3] & opcode_x[2] & opcode_x[1] & !opcode_x[0]) || (!opcode_x[4] & !opcode_x[3] & opcode_x[2] & opcode_x[1] & opcode_x[0]);

    // if the writeback stage writes to $rd = $rs (that reads here), bypass
    assign alu_A_temp1 = ((rs_x == rd_w) & reads_rs_x & (writes_rd_w || !opcode_w[4] & opcode_w[3] & !opcode_w[2] & !opcode_w[1] & !opcode_w[0])) ? data_writeReg : dx_A;
    // if it's reg 30, check if ahead insn had an exception and choose exception
    assign alu_A_temp2 = ((rs_x == 5'd30) & reads_rs_x & mw_rstat != 0) ? mw_rstat : alu_A_temp1;
    // if it's reg 31, check if ahead insn is jal (00011), and write the PC+1 value
    assign alu_A_temp3 = ((rs_x == 5'd31) & reads_rs_x & !opcode_w[4] & !opcode_w[3] & !opcode_w[2] & opcode_w[1] & opcode_w[0]) ? mw_pc : alu_A_temp2;
    // if it's reg 30, check if it's setx (10101), and then assign target [26:0]
    assign alu_A_temp4 = ((rs_x == 5'd30) & reads_rs_x & opcode_w[4] & !opcode_w[3] & opcode_w[2] & !opcode_w[1] & opcode_w[0]) ? mw_insn[26:0] : alu_A_temp3;
    // if the memory stage writes to $rd = $rs (read in execute), bypass
    assign alu_A_temp5 = ((rs_x == rd_m) & reads_rs_x & writes_rd_m) ? xm_O : alu_A_temp4;
    // if it's reg 30, check if ahead insn had an exception and choose exception
    assign alu_A_temp6 = ((rs_x == 5'd30) & reads_rs_x & xm_rstat != 0) ? xm_rstat : alu_A_temp5;
    // if it's reg 31, check if ahead insn is jal (00011), and write the PC+1 value
    assign alu_A_temp7 = ((rs_x == 5'd31) & reads_rs_x & !opcode_m[4] & !opcode_m[3] & !opcode_m[2] & opcode_m[1] & opcode_m[0]) ? xm_pc : alu_A_temp6;
    // if it's reg 30, check if it's setx (10101), and then assign target [26:0]
    assign alu_A_temp8 = ((rs_x == 5'd30) & reads_rs_x & opcode_m[4] & !opcode_m[3] & opcode_m[2] & !opcode_m[1] & opcode_m[0]) ? xm_insn[26:0] : alu_A_temp7;
    
    // if it's the zero register, always bypass the value zero
    assign alu_Ain_bypass = (rs_x == 0) & reads_rs_x ? 32'd0 : alu_A_temp8;

    // additional logic for blt (00110) ($rd = alu_B but has to go in dataOpA, so flip A and B inputs)
    wire [31:0] alu_Ain, alu_Bin;
    assign alu_Ain = (!opcode_x[4] & !opcode_x[3] & opcode_x[2] & opcode_x[1] & !opcode_x[0]) ? alu_B : alu_Ain_bypass;
    assign alu_Bin = (!opcode_x[4] & !opcode_x[3] & opcode_x[2] & opcode_x[1] & !opcode_x[0]) ? alu_Ain_bypass : alu_B;

    alu alu_1(.data_operandA(alu_Ain), .data_operandB(alu_Bin), .ctrl_ALUopcode(aluOpcode_in), .ctrl_shiftamt(shamt_x), .data_result(alu_out_no_multdiv), .isNotEqual(notEqual), .isLessThan(lessThan), .overflow(alu_overflow));
    
    // Multdiv
    // wire is_mult_x, is_div_x, multdiv_excep, multdiv_ready, ctrl_mult, ctrl_div, pulse_mult, pulse_div;
    // wire[31:0] multdiv_result;
    // // mult op = 00000 (aluop = 00110)
    // assign is_mult_x = &(~opcode_x) & (!aluop_x[4] & !aluop_x[3] & aluop_x[2] & aluop_x[1] & !aluop_x[0]);
    // // div op = 00000 (aluop = 00111)
    // assign is_div_x = &(~opcode_x) & (!aluop_x[4] & !aluop_x[3] & aluop_x[2] & aluop_x[1] & aluop_x[0]);
    // // Creates a pulse that goes high for one cycle when is_mult, then stays 0 
    // dffe_ref pulse(.q(pulse_mult), .d(is_mult_x), .clk(clock), .en(1'b1), .clr(reset));
    // assign ctrl_mult = !pulse_mult & is_mult_x;
    // // div pulse
    // dffe_ref pulse2(.q(pulse_div), .d(is_div_x), .clk(clock), .en(1'b1), .clr(reset));
    // assign ctrl_div = !pulse_div & is_div_x;

    // multdiv multdiv_1(.data_operandA(alu_Ain), .data_operandB(alu_Bin), .ctrl_MULT(ctrl_mult), .ctrl_DIV(ctrl_div), .clock(clock), .data_result(multdiv_result), .data_exception(multdiv_excep), .data_resultRDY(multdiv_ready));
    // assign alu_out = (is_mult_x || is_div_x) & multdiv_ready ? multdiv_result : alu_out_no_multdiv;
    assign alu_out = alu_out_no_multdiv;

    // Status exceptions (for overflow)
    wire[31:0] rstatus, add_ovf, addi_ovf, sub_ovf, mult_ovf; 
    // mux everything together to get what rstatus should be
    // add overflow if opcode = 00000 and aluop = 00000 and overflow, rstatus = 1
    assign add_ovf = (&(~opcode_x)) & (&(~aluop_x)) & alu_overflow ? 32'd1 : 32'd0;
    // addi overflow if opcode = 00101 and overflow, rstatus = 2
    assign addi_ovf = (!opcode_x[4] & !opcode_x[3] & opcode_x[2] & !opcode_x[1] & opcode_x[0]) & alu_overflow ? 32'd2 : add_ovf;
    // sub overflow if opcode = 00000 and aluop = 00001 and overflow, rstatus = 3
    assign sub_ovf = (&(~opcode_x)) & (!aluop_x[4] & !aluop_x[3] & !aluop_x[2] & !aluop_x[1] & aluop_x[0]) & alu_overflow ? 32'd3 : addi_ovf;
    // mult overflow if opcode = 00000 and aluop = 00110 and overflow, rstatus = 4
    // assign mult_ovf = (&(~opcode_x)) & (!aluop_x[4] & !aluop_x[3] & aluop_x[2] & aluop_x[1] & !aluop_x[0]) & multdiv_excep ? 32'd4 : sub_ovf;
    // // div overflow if opcode = 00000 and aluop = 00111 and overflow, rstatus = 5
    // assign rstatus = (&(~opcode_x)) & (!aluop_x[4] & !aluop_x[3] & aluop_x[2] & aluop_x[1] & aluop_x[0]) & multdiv_excep ? 32'd5 : mult_ovf;
    assign rstatus = sub_ovf;
    
    // branchTaken (AND aluout and the branch opcode)
    // if insn = bne (00010) AND $rd != $rs 
    // if insn = blt (00110) AND $rd < $rs
    // if insn = bex (10110) AND $rstatus != 0
    // bypassing for bex
    // TO DO: Might need to check more bex cases... if writing to R30
    wire [31:0] bex_bypass_temp, bex_bypass_temp1, bex_bypass_temp2, bex_bypass_temp3, bex_bypass_temp4;
    assign bex_bypass_temp = (rd_w == 5'd30 & !opcode_w[4] & opcode_w[3] & !opcode_w[2] & !opcode_w[1] & !opcode_w[0]) ? data_writeReg : dx_A;
    // Check if ahead insn had an exception and choose exception for Writeback stage
    assign bex_bypass_temp1 = (mw_rstat != 0) ? mw_rstat : bex_bypass_temp;
    // check if it's setx (10101), and then assign target [26:0]
    assign bex_bypass_temp2 = (opcode_w[4] & !opcode_w[3] & opcode_w[2] & !opcode_w[1] & opcode_w[0]) ? mw_insn[26:0] : bex_bypass_temp1;
    // for memory stage
    assign bex_bypass_temp3 = (xm_rstat != 0) ? xm_rstat : bex_bypass_temp2;
    assign bex_bypass_temp4 = (opcode_m[4] & !opcode_m[3] & opcode_m[2] & !opcode_m[1] & opcode_m[0]) ? xm_insn[26:0] : bex_bypass_temp3;
    assign branchTaken = ((!opcode_x[4] & !opcode_x[3] & !opcode_x[2] & opcode_x[1] & !opcode_x[0]) && notEqual) 
        || ((!opcode_x[4] & !opcode_x[3] & opcode_x[2] & opcode_x[1] & !opcode_x[0]) && lessThan)
        || (opcode_x[4] & !opcode_x[3] & opcode_x[2] & opcode_x[1] & !opcode_x[0]) & (bex_bypass_temp4 != 32'd0);

    // Branch alu (PC + 1 + N), (PC+1 = dx_pc), N=signextendedimmed
    wire notEqual1, lessThan1, alu_overflow1;
    wire[31:0] branch_target1, branch_target; 
    alu branch_alu(.data_operandA(dx_pc), .data_operandB(signext_immed), .ctrl_ALUopcode(5'b0), .ctrl_shiftamt(shamt_x), .data_result(branch_target1), .isNotEqual(notEqual1), .isLessThan(lessThan1), .overflow(alu_overflow1));
    // if bex (10110) and rstatus != 0, branch = T 
    assign branch_target = (opcode_x[4] & !opcode_x[3] & opcode_x[2] & opcode_x[1] & !opcode_x[0]) & (bex_bypass_temp4 != 32'd0) ? target_x : branch_target1;

    // X/M register
    wire[31:0] xm_insn, xm_O, xm_B, xm_pc, xm_rstat, B_in_xm_bypass;
    // pass in bypassed B (rd) for sw, otherwise normal dx_B 
    assign B_in_xm_bypass = (!opcode_x[4] & !opcode_x[3] & opcode_x[2] & opcode_x[1] & opcode_x[0]) ? alu_B_temp17 : dx_B;
    xmreg xm(.pc_in(dx_pc), .pc_out(xm_pc), .rstat_in(rstatus), .rstat_out(xm_rstat), .insn_in(dx_insn), .insn_out(xm_insn), .O_in(alu_out), .O_out(xm_O), .B_in(B_in_xm_bypass), .B_out(xm_B), .clk(not_clock), .en(enable), .clr(reset));

    // Memory stage
    // Decoding again for memory + controls
    wire[4:0] rd_m, rs_m, rt_m;
    assign rd_m = xm_insn[26:22];
    assign rs_m = xm_insn[21:17];
    assign rt_m = xm_insn[16:12];
    assign opcode_m = xm_insn[31:27];

    // memory bypassing 
    // if sw (00111) and if the ahead insn writes to the sw reg
    wire [31:0] data_temp1, data_temp2, data_temp3, data_temp4;
    assign data_temp1 = (!opcode_m[4] & !opcode_m[3] & opcode_m[2] & opcode_m[1] & opcode_m[0] && (rd_m == rd_w) && (writes_rd_w || !opcode_w[4] & opcode_w[3] & !opcode_w[2] & !opcode_w[1] & !opcode_w[0])) ? data_writeReg : xm_B;
    // if it's reg 30, check if ahead insn had an exception and choose exception
    assign data_temp2 = ((rd_m == 5'd30) & mw_rstat != 0) ? mw_rstat : data_temp1;
    // if it's reg 31, check if ahead insn is jal (00011), and write the PC+1 value
    assign data_temp3 = ((rd_m == 5'd31) & !opcode_w[4] & !opcode_w[3] & !opcode_w[2] & opcode_w[1] & opcode_w[0]) ? mw_pc : data_temp2;
    // if it's reg 30, check if it's setx (10101), and then assign target [26:0]
    assign data_temp4 = ((rs_x == 5'd30) & opcode_w[4] & !opcode_w[3] & opcode_w[2] & !opcode_w[1] & opcode_w[0]) ? mw_insn[26:0] : data_temp3;

    // For sw
    // assign WE for dmem = 1, if opcode is sw (00111)
    assign wren = (!opcode_m[4] & !opcode_m[3] & opcode_m[2] & opcode_m[1] & opcode_m[0]);
    // MEM[$rs + N] = $rd
    // xm_B = $rd and xm_O = $rs+N (which comes from alu_out)
    assign data = (rd_m == 0) ? 32'd0 : data_temp4;
    // For lw, $rd = MEM[$rs + N] -> xm_O = $rs+N (from alu_out)
    assign address_dmem = xm_O;

    // M/W register (because I'm lazy reusing the xm reg lol)
    wire[31:0] mw_insn, mw_O, mw_D, mw_pc, mw_rstat;
    xmreg mw(.pc_in(xm_pc), .pc_out(mw_pc), .rstat_in(xm_rstat), .rstat_out(mw_rstat), .insn_in(xm_insn), .insn_out(mw_insn), .O_in(xm_O), .O_out(mw_O), .B_in(q_dmem), .B_out(mw_D), .clk(not_clock), .en(enable), .clr(reset));

    // Writeback stage
    // Decoding again for write back + controls
    wire[31:0] writeDatatemp1, writeDatatemp2, writeDatatemp3, target_w;
    wire[4:0] rd_w, rs_w, rt_w, tempWriteReg1;
    wire isExcep;
    assign opcode_w = mw_insn[31:27];
    assign rd_w = mw_insn[26:22];
    assign target_w[26:0] = mw_insn[26:0];
    assign target_w[31:27] = 5'd0;

    // there's an exception if rstatus != 0 
    assign isExcep = mw_rstat != 32'd0; 
    // WE on if it's an ALUop (opcode = 00000), addi (00101), or lw (010000), jal (00011), setx (10101)
    assign ctrl_writeEnable = &(~opcode_w) || (!opcode_w[4] & !opcode_w[3] & opcode_w[2] & !opcode_w[1] & opcode_w[0]) 
        || (!opcode_w[4] & opcode_w[3] & !opcode_w[2] & !opcode_w[1] & !opcode_w[0])
        || (!opcode_w[4] & !opcode_w[3] & !opcode_w[2] & opcode_w[1] & opcode_w[0])
        || (opcode_w[4] & !opcode_w[3] & opcode_w[2] & !opcode_w[1] & opcode_w[0]);

	// register to write to, if jal, then reg 31, otherwise rd
    assign tempWriteReg1 = (!opcode_w[4] & !opcode_w[3] & !opcode_w[2] & opcode_w[1] & opcode_w[0]) ? 5'd31 : rd_w;  
    // if there's an exception (or setx), write to reg 30, otherwise normal reg  
    assign ctrl_writeReg = (isExcep || (opcode_w[4] & !opcode_w[3] & opcode_w[2] & !opcode_w[1] & opcode_w[0])) ? 5'd30 : tempWriteReg1;

    // Data we are writing, if lw (010000), write the data from memory, otherwise use alu_output
    assign writeDatatemp1 = (!opcode_w[4] & opcode_w[3] & !opcode_w[2] & !opcode_w[1] & !opcode_w[0]) ? mw_D : mw_O;
    // if there's a status exception, write the exception data
    assign writeDatatemp2 = isExcep ? mw_rstat : writeDatatemp1;
    // if jal (00011), write PC+1, otherwise choose prev data
    assign writeDatatemp3 = (!opcode_w[4] & !opcode_w[3] & !opcode_w[2] & opcode_w[1] & opcode_w[0]) ? mw_pc : writeDatatemp2;  
    // if setx (10101), write T (target), otherwise prev data
    assign data_writeReg = (opcode_w[4] & !opcode_w[3] & opcode_w[2] & !opcode_w[1] & opcode_w[0]) ? target_w : writeDatatemp3;

endmodule
