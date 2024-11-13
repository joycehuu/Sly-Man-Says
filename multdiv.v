module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    wire [31:0] mult_result, div_result;
    wire clear, enable, mult_resultrdy, div_resultrdy, mult_exception, div_exception, choose_mult;

    // clear whatever's happening when the ctrls pulse = 1
    assign clear = ctrl_MULT || ctrl_DIV; 
    assign enable = 1'b1;

    // multiply and divide modules
    mult multiply_module(.clock(clock), .enable(enable), .clear(clear), .data_operandA(data_operandA), .data_operandB(data_operandB), .mult_result(mult_result), .mult_resultrdy(mult_resultrdy), .mult_exception(mult_exception));
    div divide_module(.clock(clock), .enable(enable), .clear(clear), .data_operandA(data_operandA), .data_operandB(data_operandB), .div_result(div_result), .div_resultrdy(div_resultrdy), .div_exception(div_exception));

    // q output will go high and stay high when mult goes off (will clear itself when div goes high)
    dffe_ref ctrl(.q(choose_mult), .d(ctrl_MULT), .clk(clock), .en(ctrl_MULT), .clr(ctrl_DIV));

    // choosing result based on ctrl from dff
    assign data_result = choose_mult ? mult_result : div_result;
    assign data_exception = choose_mult ? mult_exception : div_exception;
    assign data_resultRDY = choose_mult ? mult_resultrdy : div_resultrdy;

endmodule