module xmreg(pc_in, pc_out, rstat_in, rstat_out, insn_in, insn_out, O_in, O_out, B_in, B_out, clk, en, clr);
    // Inputs
    input [31:0] insn_in, O_in, B_in, pc_in, rstat_in;
    input clk, en, clr;

    //Output
    output [31:0] insn_out, O_out, B_out, pc_out, rstat_out;

    // create 32 d-flip flops (32 bit register)
    genvar i;
    generate
    for (i = 0; i <= 31; i = i + 1) begin
        dffe_ref dff(.d(insn_in[i]), .q(insn_out[i]), .clk(clk), .en(en), .clr(clr));
        dffe_ref dff2(.d(pc_in[i]), .q(pc_out[i]), .clk(clk), .en(en), .clr(clr));
        dffe_ref dff3(.d(O_in[i]), .q(O_out[i]), .clk(clk), .en(en), .clr(clr));
        dffe_ref dff4(.d(B_in[i]), .q(B_out[i]), .clk(clk), .en(en), .clr(clr));
        dffe_ref dff5(.d(rstat_in[i]), .q(rstat_out[i]), .clk(clk), .en(en), .clr(clr));
    end
    endgenerate

endmodule