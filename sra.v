module sra(shift, A, out);
    input [4:0] shift;
    input [31:0] A;
    output [31:0] out;

    wire [31:0] shift1, shift2, shift4, shift8, shift16;
    wire [31:0] out1, out2, out4, out8;

    // shift by 1
    assign shift1[30:0] = A[31:1];
    assign shift1[31] = A[31] ? 1'd1 : 1'd0;
    assign out1 = shift[0] ? shift1 : A;

    // shift by 2
    assign shift2[29:0] = out1[31:2];
    assign shift2[31:30] = A[31] ? 2'd3 : 2'd0;
    assign out2 = shift[1] ? shift2 : out1;

    // shift by 4
    assign shift4[27:0] = out2[31:4];
    assign shift4[31:28] = A[31] ? 4'd15 : 4'd0;
    assign out4 = shift[2] ? shift4 : out2;

    // shift by 8
    assign shift8[23:0] = out4[31:8];
    assign shift8[31:24] = A[31] ? 8'd255 : 8'd0;
    assign out8 = shift[3] ? shift8 : out4;

    // shift by 16
    assign shift16[15:0] = out8[31:16];
    assign shift16[31:16] = A[31] ? 16'd65535 : 16'd0;
    assign out = shift[4] ? shift16 : out8;

endmodule 