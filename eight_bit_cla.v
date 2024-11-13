module eight_bit_cla(A, B, Cin, S, C, G, P);
        
    input [7:0] A, B;
    input Cin; // Cin = C[0]
    output [7:0] S;
    output G, P;
    output [7:1] C;
    wire [7:0] g, p;
    wire p0c0, 
        p1g0, p1p0c0,  
        p2g1, p2p1g0, p2p1p0c0, 
        p3g2, p3p2g1, p3p2p1g0, p3p2p1p0c0,
        p4g3, p4p3g2, p4p3p2g1, p4p3p2p1g0, p4p3p2p1p0c0,
        p5g4, p5p4g3, p5p4p3g2, p5p4p3p2g1, p5p4p3p2p1g0, p5p4p3p2p1p0c0,
        p6g5, p6p5g4, p6p5p4g3, p6p5p4p3g2, p6p5p4p3p2g1, p6p5p4p3p2p1g0, p6p5p4p3p2p1p0c0,
        p7g6, p7p6g5, p7p6p5g4, p7p6p5p4g3, p7p6p5p4p3g2, p7p6p5p4p3p2g1, p7p6p5p4p3p2p1g0, p7p6p5p4p3p2p1p0c0;

    // c[1] = g[0] + p[0]c[0]
    and g0(g[0], A[0], B[0]);
    or p0(p[0], A[0], B[0]);
    and p0c01(p0c0, Cin, p[0]);
    or c1(C[1], g[0], p0c0);

    // c[2] = g[1] + p[1]g[0] + p[1]p[0]c[0]
    and g1(g[1], A[1], B[1]);
    or p1(p[1], A[1], B[1]);
    and p1g01(p1g0, p[1], g[0]);
    and p1p0c01(p1p0c0, p[1], p[0], Cin);
    or c2(C[2], g[1], p1g0, p1p0c0);

    // c[3] = g[2] + p[2]g[1] + p[2]p[1]g[0] + p[2]p[1]p[0]c[0]
    and g2(g[2], A[2], B[2]);
    or p2(p[2], A[2], B[2]);
    and p2g11(p2g1, p[2], g[1]);
    and p2p1g01(p2p1g0, p[2], p[1], g[0]);
    and p2p1p0c01(p2p1p0c0, p[2], p[1], p[0], Cin);
    or c3(C[3], g[2], p2g1, p2p1g0, p2p1p0c0);

    // c[4]
    and g3(g[3], A[3], B[3]);
    or p3(p[3], A[3], B[3]);
    and p3g21(p3g2, p[3], g[2]);
    and p3p2g11(p3p2g1, p[3], p[2], g[1]);
    and p3p2p1g01(p3p2p1g0, p[3], p[2], p[1], g[0]);
    and p3p2p1p0c01(p3p2p1p0c0, p[3], p[2], p[1], p[0], Cin);
    or c4(C[4], g[3], p3g2, p3p2g1, p3p2p1g0, p3p2p1p0c0);

    // c[5]
    and g4(g[4], A[4], B[4]);
    or p4(p[4], A[4], B[4]);
    and p4g31(p4g3, p[4], g[3]);
    and p4p3g21(p4p3g2, p[4], p[3], g[2]);
    and p4p3p2g11(p4p3p2g1, p[4], p[3], p[2], g[1]);
    and p4p3p2p1g01(p4p3p2p1g0, p[4], p[3], p[2], p[1], g[0]);
    and p4p3p2p1p0c01(p4p3p2p1p0c0, p[4], p[3], p[2], p[1], p[0], Cin);
    or c5(C[5], g[4], p4g3, p4p3g2, p4p3p2g1, p4p3p2p1g0, p4p3p2p1p0c0);

    // c[6]
    and g5(g[5], A[5], B[5]);
    or p5(p[5], A[5], B[5]);
    and p5g41(p5g4, p[5], g[4]);
    and p5p4g31(p5p4g3, p[5], p[4], g[3]);
    and p5p4p3g21(p5p4p3g2, p[5], p[4], p[3], g[2]);
    and p5p4p3p2g11(p5p4p3p2g1, p[5], p[4], p[3], p[2], g[1]);
    and p5p4p3p2p1g01(p5p4p3p2p1g0, p[5], p[4], p[3], p[2], p[1], g[0]);
    and p5p4p3p2p1p0c01(p5p4p3p2p1p0c0, p[5], p[4], p[3], p[2], p[1], p[0], Cin);
    or c6(C[6], g[5], p5g4, p5p4g3, p5p4p3g2, p5p4p3p2g1, p5p4p3p2p1g0, p5p4p3p2p1p0c0);

    // c[7]
    and g6(g[6], A[6], B[6]);
    or p6(p[6], A[6], B[6]);
    and p6g51(p6g5, p[6], g[5]);
    and p6p5g41(p6p5g4, p[6], p[5], g[4]);
    and p6p5p4g31(p6p5p4g3, p[6], p[5], p[4], g[3]);
    and p6p5p4p3g21(p6p5p4p3g2, p[6], p[5], p[4], p[3], g[2]);
    and p6p5p4p3p2g11(p6p5p4p3p2g1, p[6], p[5], p[4], p[3], p[2], g[1]);
    and p6p5p4p3p2p1g01(p6p5p4p3p2p1g0, p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
    and p6p5p4p3p2p1p0c01(p6p5p4p3p2p1p0c0, p[6], p[5], p[4], p[3], p[2], p[1], p[0], Cin);
    or c7(C[7], g[6], p6g5, p6p5g4, p6p5p4g3, p6p5p4p3g2, p6p5p4p3p2g1, p6p5p4p3p2p1g0, p6p5p4p3p2p1p0c0);

    // c[8]
    and g7(g[7], A[7], B[7]);
    or p7(p[7], A[7], B[7]);
    and p7g61(p7g6, p[7], g[6]);
    and p7p6g51(p7p6g5, p[7], p[6], g[5]);
    and p7p6p5g41(p7p6p5g4, p[7], p[6], p[5], g[4]);
    and p7p6p5p4g31(p7p6p5p4g3, p[7], p[6], p[5], p[4], g[3]);
    and p7p6p5p4p3g21(p7p6p5p4p3g2, p[7], p[6], p[5], p[4], p[3], g[2]);
    and p7p6p5p4p3p2g11(p7p6p5p4p3p2g1, p[7], p[6], p[5], p[4], p[3], p[2], g[1]);
    and p7p6p5p4p3p2p1g01(p7p6p5p4p3p2p1g0, p[7], p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
    and p7p6p5p4p3p2p1p0c01(p7p6p5p4p3p2p1p0c0, p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0], Cin);
    // or c8(C[8], g[7], p7g6, p7p6g5, p7p6p5g4, p7p6p5p4g3, p7p6p5p4p3g2, p7p6p5p4p3p2g1, p7p6p5p4p3p2p1g0, p7p6p5p4p3p2p1p0c0);

    // P = p7p6p5p4p3p2p1p0
    // G = g7 + p7g6 + ... + p7p6p5p4p3p2p1g0
    and P0(P, p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0]);
    or G0(G, g[7], p7g6, p7p6g5, p7p6p5g4, p7p6p5p4g3, p7p6p5p4p3g2, p7p6p5p4p3p2g1, p7p6p5p4p3p2p1g0);

    // Sum bits
    xor s0(S[0], A[0], B[0], Cin);
    xor s1(S[1], A[1], B[1], C[1]);
    xor s2(S[2], A[2], B[2], C[2]);
    xor s3(S[3], A[3], B[3], C[3]);
    xor s4(S[4], A[4], B[4], C[4]);
    xor s5(S[5], A[5], B[5], C[5]);
    xor s6(S[6], A[6], B[6], C[6]);
    xor s7(S[7], A[7], B[7], C[7]);

endmodule