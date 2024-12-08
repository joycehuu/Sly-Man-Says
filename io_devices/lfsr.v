// linear feedback shift register
module lfsr(clk, reset, random_num);
    input clk, reset; 
    output [31:0] random_num;
    // wire [31:0] Din, Qout, seed, shift_d;
    reg [31:0] random_num = 32'hB4BCD35C;
    wire bottom_bit;

    assign bottom_bit = random_num[31] ^ random_num[21] ^ random_num[1] ^ random_num[0] ^ 1'b1;

    always @(posedge clk) begin
        random_num <= {random_num[30:0], bottom_bit};
    end

    // assign seed = 32'hB4BCD35C;
    // assign shift_d[31:1] = Qout[30:0];
    // assign shift_d[0] = Qout[31] ^ Qout[19] ^ Qout[3]; // xor random bits
    // assign Din = reset ? seed : shift_d;
    // assign random_num = Qout;

    // register #(32) lsfrreg(.Din(Din), .Qout(Qout), .clk(clk), .en(1'b1), .clr(1'b0));
    

endmodule