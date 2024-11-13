module counter16(clk, en, count, clr);
    input clk, en, clr;
    output [5:0] count;
    wire Q0, Q1, Q2, Q3, Q4, Q5, and1, and2, and3, and4, and5;

    tff tff_0(.T(en), .q(Q0), .clr(clr), .clk(clk));
    tff tff_1(.T(and1), .q(Q1), .clr(clr), .clk(clk));
    tff tff_2(.T(and2), .q(Q2), .clr(clr), .clk(clk));
    tff tff_3(.T(and3), .q(Q3), .clr(clr), .clk(clk));
    tff tff_4(.T(and4), .q(Q4), .clr(clr), .clk(clk));
    tff tff_5(.T(and5), .q(Q5), .clr(clr), .clk(clk));

    and first_and(and1, en, Q0);
    and second_and(and2, and1, Q1);
    and third_and(and3, and2, Q2);
    and fourth_and(and4, and3, Q3);
    and fifth_and(and5, and4, Q4);

    assign count[0] = Q0;
    assign count[1] = Q1;
    assign count[2] = Q2;
    assign count[3] = Q3;
    assign count[4] = Q4;
    assign count[5] = Q5; 

endmodule