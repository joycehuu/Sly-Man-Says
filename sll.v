module sll(shift, A, out);
    input [4:0] shift;
    input [31:0] A;
    output [31:0] out;

    wire [31:0] shift1, shift2, shift4, shift8, shift16;
    wire [31:0] out1, out2, out4, out8;

    // shift by 1
    assign shift1[31:1] = A[30:0];
    assign shift1[0] = 1'b0;
    assign out1 = shift[0] ? shift1 : A;

    // shift by 2
    assign shift2[31:2] = out1[29:0];
    assign shift2[1:0] = 2'd0;
    assign out2 = shift[1] ? shift2 : out1;

    // shift by 4
    assign shift4[31:4] = out2[27:0];
    assign shift4[3:0] = 4'd0;
    assign out4 = shift[2] ? shift4 : out2;

    // shift by 8
    assign shift8[31:8] = out4[23:0];
    assign shift8[7:0] = 8'd0;
    assign out8 = shift[3] ? shift8: out4;

    // shift by 16
    assign shift16[31:16] = out8[15:0];
    assign shift16[15:0] = 16'd0;
    assign out = shift[4] ? shift16 : out8;


endmodule