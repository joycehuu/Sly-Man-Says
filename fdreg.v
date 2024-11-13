module fdreg(PC_in, PC_out, insn_in, insn_out, clk, en, clr);
    // Inputs
    input [31:0] PC_in, insn_in;
    input clk, en, clr;

    //Output
    output [31:0] PC_out, insn_out;

    // create 32 d-flip flops (32 bit register)
    genvar i;
    generate
    for (i = 0; i <= 31; i = i + 1) begin
        dffe_ref dff(.d(insn_in[i]), .q(insn_out[i]), .clk(clk), .en(en), .clr(clr));
        dffe_ref dff2(.d(PC_in[i]), .q(PC_out[i]), .clk(clk), .en(en), .clr(clr));
    end
    endgenerate

endmodule