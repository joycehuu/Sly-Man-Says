module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
    
    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    wire [31:0] adder_result, and_result, or_result, sll_result, sra_result, B_input, sub;
    wire EQ0, GT0, GTorEQ, eq_select, normalLT;
    
    // xor B input with subtract bit to subtract
    // adder will subtract when the last bit of the ALUopcode is 1 (sub = 32 bits of 1) and add when 0 
    assign sub = ctrl_ALUopcode[0] ? 32'd4294967295 : 32'd0;
    xor_bitwise B_xor_sub(.A(data_operandB), .B(sub), .out(B_input));

    level2_cla adder(.A(data_operandA), .B(B_input), .Cin(sub[0]), .S(adder_result), .overflow(overflow));
    and_bitwise and_out(.A(data_operandA), .B(data_operandB), .out(and_result));
    or_bitwise or_out(.A(data_operandA), .B(data_operandB), .out(or_result));
    sll sll_out(.A(data_operandA), .out(sll_result), .shift(ctrl_shiftamt));
    sra sra_out(.A(data_operandA), .out(sra_result), .shift(ctrl_shiftamt));

    or eq(isNotEqual, data_result[0], data_result[1], data_result[2], data_result[3], data_result[4], data_result[5], data_result[6], data_result[7], 
        data_result[8], data_result[9], data_result[10], data_result[11], data_result[12], data_result[13], data_result[14], data_result[15],
        data_result[16], data_result[17], data_result[18], data_result[19], data_result[20], data_result[21], data_result[22], data_result[23],
        data_result[24], data_result[25], data_result[26], data_result[27], data_result[28], data_result[29], data_result[30], data_result[31]);

    // MSB = 1 if A < B
    assign normalLT = data_result[31];

    // Check overflow case (one number is + and other is -, so if MSB of A is 1, it's negative/LT)
    assign isLessThan = overflow ? data_operandA[31] : normalLT;

    mux_8 choose_result(data_result, ctrl_ALUopcode[2:0], adder_result, adder_result, and_result, or_result, sll_result, sra_result, 32'd0, 32'd0);

endmodule