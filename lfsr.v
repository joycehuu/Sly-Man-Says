// linear feedback shift register
module lfsr(clk, set_seed, random_num);
    input clk, set_seed; 
    output [31:0] random_num;
    wire [31:0] Din, Qout, seed, shift_d;

    assign seed = 32'd1007261951;
    assign shift_d[31:1] = Qout[30:0];
    assign shift_d[0] = Qout[19] ^ Qout[3]; // xor random bits
    assign Din = set_seed ? seed : shift_d;
    assign random_num = Qout;

    register #(32) lsfrreg(.Din(Din), .Qout(Qout), .clk(clk), .en(1'b1), .clr(1'b0));

endmodule