module or_bitwise(A, B, out);
    input [31:0] A, B;
    output [31:0] out;

    or a0(out[0], A[0], B[0]);
    or a1(out[1], A[1], B[1]);
    or a2(out[2], A[2], B[2]);
    or a3(out[3], A[3], B[3]);
    or a4(out[4], A[4], B[4]);
    or a5(out[5], A[5], B[5]);
    or a6(out[6], A[6], B[6]);
    or a7(out[7], A[7], B[7]);
    or a8(out[8], A[8], B[8]);
    or a9(out[9], A[9], B[9]);
    or a10(out[10], A[10], B[10]);
    or a11(out[11], A[11], B[11]);
    or a12(out[12], A[12], B[12]);
    or a13(out[13], A[13], B[13]);
    or a14(out[14], A[14], B[14]);
    or a15(out[15], A[15], B[15]);
    or a16(out[16], A[16], B[16]);
    or a17(out[17], A[17], B[17]);
    or a18(out[18], A[18], B[18]);
    or a19(out[19], A[19], B[19]);
    or a20(out[20], A[20], B[20]);
    or a21(out[21], A[21], B[21]);
    or a22(out[22], A[22], B[22]);
    or a23(out[23], A[23], B[23]);
    or a24(out[24], A[24], B[24]);
    or a25(out[25], A[25], B[25]);
    or a26(out[26], A[26], B[26]);
    or a27(out[27], A[27], B[27]);
    or a28(out[28], A[28], B[28]);
    or a29(out[29], A[29], B[29]);
    or a30(out[30], A[30], B[30]);
    or a31(out[31], A[31], B[31]);

endmodule