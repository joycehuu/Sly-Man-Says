module mult(clear, enable, clock, data_operandA, data_operandB, mult_exception, mult_resultrdy, mult_result);
    input [31:0] data_operandA, data_operandB;
    input clear, enable, clock;

    output [31:0] mult_result;
    output mult_exception, mult_resultrdy;

    wire [65:0] product, d_in, after_adder, Qout, initial_din, shifted;
    wire signed [65:0] to_shift;

    // wires for adder
    wire [31:0] adder_result;
    wire carry_out, overflow, msb, excep1;
    // extend data_operand / multiplicand by 1 bit for modified booths overflow issue
    wire [32:0] extended_M, b_adder_input, two_M, M, sub;
    wire [5:0] count; // counter from tffs

    // counter to keep track of cycles
    counter16 tff_counter(.clk(clock), .en(enable), .clr(clear), .count(count));

    // sign extending M by 1 bit
    assign M[32] = data_operandA[31];
    assign M[31:0] = data_operandA[31:0];

    // control bit for choosing 2M or M
    // if the last two bits (00) or (11) = xnor then we use 2M instead of M
    assign two_M = M << 1;
    assign extended_M = ~(Qout[0] ^ Qout[1]) ? two_M : M;

    // control bit for add/subtract, subtract when (sub = 32 bits of 1) and add when 0 
    // subtract when 1, when MSB of the last three digits/sidecar preview = 1 
    assign sub = Qout[2] ? 33'd8589934591 : 33'd0;
    // xor B input with subtract bit to figure out whether add or subtract
    assign b_adder_input = extended_M ^ sub;

    // add upper half of product reg, and the calculated +/- M (or 2M)
    level2_cla_mult adder(.A(Qout[64:33]), .B(b_adder_input[31:0]), .Cin(sub[0]), .S(adder_result), .overflow(overflow), .carry_out(carry_out));
    // calculating extra sum bit for 33 bit
    xor sum(msb, Qout[65], b_adder_input[32], carry_out);
    
    // upper half of D_in is result, bottom is the multiplicand and calc values
    assign after_adder[65] = msb;
    assign after_adder[64:33] = adder_result;
    assign after_adder[32:0] = Qout[32:0];

    // choose adder result or do nothing 
    // Do nothing if last thre bits are 000 or 111 (so if nor all three bits = 1 (000) or if and all bits = 1 (111))
    assign to_shift = (!(|Qout[2:0])) || (&Qout[2:0]) ? Qout : after_adder;

    // initial_din = all 0's, bottom half is multiplier, last one 0 sidecar
    assign initial_din[32:1] = data_operandB;
    assign initial_din[65:33] = 33'b0;
    assign initial_din[0] = 1'b0;

    assign shifted = to_shift >>> 2; // right arithmetic shift product by 2

    // Din = the shifted results or the initial start depending on counter
    // if counter = 00000, then we set d_in to initial value, otherwise shifted output
    assign d_in = !(|count) ? initial_din : shifted;

    // product register
    register #(66) product_reg(.Din(d_in), .Qout(Qout), .clk(clock), .en(enable), .clr(clear));

    // truncate results
    assign mult_result = Qout[32:1];

    // when the upper 33 bits of product reg are not all 1's or all 0's, then exception 
    // also exception if + * + = - (001), - * - = - (111), + * - = + (010), - * + = + (100)
    assign excep1 = (!((!(|Qout[65:33])) || (&Qout[65:33])) || 
    (!data_operandA[31] & !data_operandB[31] & mult_result[31]) ||
    (data_operandA[31] & data_operandB[31] & mult_result[31]) ||
    (!data_operandA[31] & data_operandB[31] & !mult_result[31]) ||
    (data_operandA[31] & !data_operandB[31] & !mult_result[31])) ? 1'b1 : 1'b0;

    // but no exception if an operand is 0 (should test all cases with 0 in csv, 0*0, 0*+, 0*-, +*0, -*0)
    assign mult_exception = ((|data_operandA) & (|data_operandB)) ? excep1 : 1'b0;

    // When counter = 17 (10001) then go up (cycle 18)
    assign mult_resultrdy = (!count[5] & count[4] & !count[3] & !count[2] & !count[1] & count[0]) ? 1'b1 : 1'b0;

endmodule