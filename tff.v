module tff(T, clk, clr, q);
    input T, clk, clr;

    wire Tnot, notTandQ, TandnotQ, d_in, Qnot;

    output q;

    not notT(Tnot, T);
    not notQ(Qnot, q);
    and upperand(notTandQ, Tnot, q);
    and lowerand(TandnotQ, T, Qnot);
    or d_or(d_in, notTandQ, TandnotQ);

    dffe_ref dff(.d(d_in), .q(q), .clk(clk), .en(T), .clr(clr));

endmodule