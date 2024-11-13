module level2_cla_mult(A, B, Cin, S, overflow, carry_out);
    // modifying my cla to take 33 bit inputs for modified booths
    input [31:0] A, B;
    input Cin; // c0 = Cin
    output [31:0] S;
    output overflow;
    output carry_out;
    wire [32:1] C;
    wire [3:0] G, P;
    wire P0c0,
        P1G0, P1P0c0,
        P2G1, P2P1G0, P2P1P0c0,
        P3G2, P3P2G1, P3P2P1G0, P3P2P1P0c0;

    // c8 = G0 + P0c0
    and carry1(P0c0, P[0], Cin);
    or c8(C[8], G[0], P0c0);

    // c16 = G1 + P1G0 + P1P0c0
    and carry20(P1G0, P[1], G[0]);
    and carry21(P1P0c0, P[1], P[0], Cin);
    or c16(C[16], G[1], P1G0, P1P0c0);

    // c24
    and carry30(P2G1, P[2], G[1]);
    and carry31(P2P1G0, P[2], P[1], G[0]);
    and carry32(P2P1P0c0, P[2], P[1], P[0], Cin);
    or c24(C[24], G[2], P2G1, P2P1G0, P2P1P0c0);

    // c32
    and carry40(P3G2, P[3], G[2]);
    and carry41(P3P2G1, P[3], P[2], G[1]);
    and carry42(P3P2P1G0, P[3], P[2], P[1], G[0]);
    and carry43(P3P2P1P0c0, P[3], P[2], P[1], P[0], Cin);
    or c32(C[32], G[3], P3G2, P3P2G1, P3P2P1G0, P3P2P1P0c0);

    // 4 8-bit CLA blocks for 32-bit adder
    eight_bit_cla block0(.A(A[7:0]), .B(B[7:0]), .Cin(Cin), .S(S[7:0]), .C(C[7:1]), .G(G[0]), .P(P[0]));
    eight_bit_cla block1(.A(A[15:8]), .B(B[15:8]), .Cin(C[8]), .S(S[15:8]), .C(C[15:9]), .G(G[1]), .P(P[1]));
    eight_bit_cla block2(.A(A[23:16]), .B(B[23:16]), .Cin(C[16]), .S(S[23:16]), .C(C[23:17]), .G(G[2]), .P(P[2]));
    eight_bit_cla block3(.A(A[31:24]), .B(B[31:24]), .Cin(C[24]), .S(S[31:24]), .C(C[31:25]), .G(G[3]), .P(P[3]));

    assign carry_out = C[32];
    // Overflow if two most significant carry bits are !=
    xor xor_overflow(overflow, C[32], C[31]);

endmodule