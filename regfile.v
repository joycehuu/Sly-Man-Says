module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	// one hot decoder outputs
	wire [31:0] regA_decoder, regB_decoder, write_decoder; 
	wire [31:0] decode_0; // forces the 0 bit of write decoder to 0

	// Decoders for all ctrl_Reg (2 reads, 1 write)
	decoder32 read_A(.select(ctrl_readRegA), .enable(1'b1), .out(regA_decoder));
	decoder32 read_B(.select(ctrl_readRegB), .enable(1'b1), .out(regB_decoder));
	decoder32 write_enables(.select(ctrl_writeReg), .enable(ctrl_writeEnable), .out(write_decoder));

	// forces WE for reg 0 to always be 0
	assign decode_0[31:1] = write_decoder[31:1];
	assign decode_0[0] = 1'b0;

	
	// create 32 registers (all 32 bits)
    genvar j;
    generate
    for (j = 0; j <= 31; j = j + 1) begin
		wire [31:0] reg_out;
        register reg_(.Din(data_writeReg), .Qout(reg_out), .clk(clock), .en(decode_0[j]), .clr(ctrl_reset));
		assign data_readRegA = regA_decoder[j] ? reg_out : 32'bz;
		assign data_readRegB = regB_decoder[j] ? reg_out : 32'bz;
    end
    endgenerate

endmodule
