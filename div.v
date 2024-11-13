module div(clear, enable, clock, data_operandA, data_operandB, div_exception, div_resultrdy, div_result);
    input [31:0] data_operandA, data_operandB;
    input clear, enable, clock;

    output [31:0] div_result;
    output div_exception, div_resultrdy;

    // wires for adders
    wire [31:0] div_adder_out, V, sub_div, sumA, sumB, sum_flip, div_out;
    wire overflow_div, carry_out_div, overflowA, carry_outA, overflowB, carry_outB, overflow_flip, carry_out_flip;
    wire [5:0] count; // counter from tffs
    wire [31:0] divA, divB, posA, posB, div_flip, result1;
    wire [63:0] div_d, div_q, shifted_q, initial_div_d, calc_div_d;

    // counter to keep track of cycles
    counter16 tff_counter(.clk(clock), .en(enable), .clr(clear), .count(count));

    // division register
    register #(64) div_reg(.Din(div_d), .Qout(div_q), .clk(clock), .en(enable), .clr(clear));

    // divA = flipped bits of A, same for B
    assign divA = ~data_operandA;
    assign divB = ~data_operandB;
    // sumA = negative A
    level2_cla_mult adderA(.A(divA), .B(32'b1), .Cin(1'b0), .S(sumA), .overflow(overflowA), .carry_out(carry_outA));
    level2_cla_mult adderB(.A(divB), .B(32'b1), .Cin(1'b0), .S(sumB), .overflow(overflowB), .carry_out(carry_outB));

    // if A is - (MSB=1), make + 
    assign posA = data_operandA[31] ? sumA : data_operandA; 
    assign posB = data_operandB[31] ? sumB : data_operandB; 

    // initial_div_d = top half all 0's, bottom half is dividend
    assign initial_div_d[63:32] = 32'b0;
    assign initial_div_d[31:0] = posA;

    // Din = the shifted results or the initial start depending on counter
    // if counter = 000000, then we set d_in to initial value, otherwise shifted output
    assign div_d = !(|count) ? initial_div_d : calc_div_d;

    // control bit for add/subtract, subtract when MSB of R (Q) = 0, if 1 then add
    assign sub_div = div_q[63] ? 32'b0 : 32'd4294967295;
    // xor B input with subtract bit to figure out whether add or subtract
    assign V = posB ^ sub_div;

    // shift RQ left
    assign shifted_q = div_q << 1; // left shift by 1

    // R = R + V or R = R - V
    level2_cla_mult adder_div(.A(shifted_q[63:32]), .B(V[31:0]), .Cin(sub_div[0]), .S(div_adder_out), .overflow(overflow_div), .carry_out(carry_out_div));

    // assigning div_d (Q[0] = 1 if MSB of R = 0)
    assign calc_div_d[63:32] = div_adder_out;
    assign calc_div_d[31:1] = shifted_q[31:1];
    assign calc_div_d[0] = div_adder_out[31] ? 1'b0 : 1'b1;

    // truncate div reg results
    assign div_out = div_q[31:0];

    // div_flip = flipped bits of output
    assign div_flip = ~div_out;
    // sum_flip = negative div output
    level2_cla_mult adder_negate(.A(div_flip), .B(32'b1), .Cin(1'b0), .S(sum_flip), .overflow(overflow_flip), .carry_out(carry_out_flip));

    // When counter = 33 (100001) then go up
    assign div_resultrdy = (count[5] & !count[4] & !count[3] & !count[2] & !count[1] & count[0]) ? 1'b1 : 1'b0;
    // exception when dividing by zero (when B = 0)
    assign div_exception = !(|data_operandB) ? 1'b1 : 1'b0;
    
    // test edge case: max negative number -> flipping to positive would cause unary overflow
    // if +/+, or -/-, use the normal result, otherwise negate
    assign div_result = (data_operandA[31] & !data_operandB[31]) || (!data_operandA[31] & data_operandB[31]) ? sum_flip : div_out;

endmodule