`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper (input clk_100mhz, input red_button, input blue_button, input green_button, input yellow_button, 
		output red_led, output blue_led, output green_led, output yellow_led, input reset);
	wire clock;

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut, memDataOut_normal;
	wire[31:0] random_num;

	assign clock = clk_50mhz;
	wire clk_50mhz;
	wire locked;
	clk_wiz_0 pll(.clk_out1(clk_50mhz), .reset(1'b0), .locked(locked), .clk_in1(clk_100mhz));

	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "led";
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataOut)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut_normal));

	// send a pulse into reset... 
	// if lw to address 5, then assign memDataOut to random_num
	assign memDataOut = (memAddr[11:0] == 12'd5) ? random_num : memDataOut_normal;
	wire start_random_pulse;
	lfsr random_reg(.clk(clock), .reset(start_random_pulse), .random_num(random_num));
	// Creates a pulse that goes high for one cycle when reset, then stays 0 
    dffe_ref pulse_stall(.q(start_random_pulse), .d(reset), .clk(clock), .en(1'b1), .clr(1'b0));

	// if sw to address 6, flash the led 
	assign flash_led = (mwe == 1'b1) & (memAddr[11:0] == 12'd6);
	// memDataIn[1:0] cases: 00=flash red, 01=flash blue, 10=flash green, 11=flash yellow
	light_up lights(.clock(clock), .flash_led(flash_led), .color(memDataIn[2:1]), .on_off(memDataIn[0]), .red_led(red_led), .blue_led(blue_led), .green_led(green_led), .yellow_led(yellow_led));


endmodule
