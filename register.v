module register #(parameter WIDTH=32) (Din, Qout, clk, en, clr);
    // Inputs
    input [WIDTH-1:0] Din;
    input clk, en, clr;

    //Output
    output [WIDTH-1:0] Qout;

    // create 32 d-flip flops (32 bit register)
    genvar i;
    generate
    for (i = 0; i <= WIDTH-1; i = i + 1) begin
        dffe_ref dff(.d(Din[i]), .q(Qout[i]), .clk(clk), .en(en), .clr(clr));
    end
    endgenerate

endmodule