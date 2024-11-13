module dxreg(PC_in, PC_out, insn_in, insn_out, A_in, A_out, B_in, B_out, clk, en, clr);
    // Inputs
    input [31:0] PC_in, insn_in, A_in, B_in;
    input clk, en, clr;

    //Output
    output [31:0] PC_out, insn_out, A_out, B_out;

    // create 32 d-flip flops (32 bit register)
    genvar i;
    generate
    for (i = 0; i <= 31; i = i + 1) begin
        dffe_ref dff(.d(insn_in[i]), .q(insn_out[i]), .clk(clk), .en(en), .clr(clr));
        dffe_ref dff2(.d(PC_in[i]), .q(PC_out[i]), .clk(clk), .en(en), .clr(clr));
        dffe_ref dff3(.d(A_in[i]), .q(A_out[i]), .clk(clk), .en(en), .clr(clr));
        dffe_ref dff4(.d(B_in[i]), .q(B_out[i]), .clk(clk), .en(en), .clr(clr));
    end
    endgenerate

endmodule