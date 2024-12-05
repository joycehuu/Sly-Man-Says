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
		output red_led, output blue_led, output green_led, output yellow_led, input reset, output audioOut, output audioEn, output left_servo, output right_servo,
		output anode_ones, output anode_tens, output top, output top_right, output bot_right, output bot, output bot_left, output top_left, output middle, output [7:0] LED);

	wire clock;

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut, memDataOut_normal, memData_temp1;
	wire[31:0] random_num;

	assign clock = clk_50mhz;
	wire clk_50mhz;
	wire locked;
	clk_wiz_0 pll(.clk_out1(clk_50mhz), .reset(1'b0), .locked(locked), .clk_in1(clk_100mhz));

	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "display";
	
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
	assign memData_temp1 = (memAddr[11:0] == 12'd5) ? random_num : memDataOut_normal;
	wire start_random_pulse;
	lfsr random_reg(.clk(clock), .reset(start_random_pulse), .random_num(random_num));
	// Creates a pulse that goes high for one cycle when reset, then stays 0 
    dffe_ref pulse_stall(.q(start_random_pulse), .d(reset), .clk(clock), .en(1'b1), .clr(1'b0));

	// if sw to address 6, flash the led 
	wire flash_led;
	assign flash_led = (mwe == 1'b1) & (memAddr[11:0] == 12'd6);
	// memDataIn[1:0] cases: 00=flash red, 01=flash blue, 10=flash green, 11=flash yellow
	light_up lights(.clock(clock), .flash_led(flash_led), .color(memDataIn[2:1]), .on_off(memDataIn[0]), .red_led(red_led), .blue_led(blue_led), .green_led(green_led), .yellow_led(yellow_led));

	// if sw to address 8, play audio
	wire play_audio;
	assign play_audio = (mwe == 1'b1) & (memAddr[11:0] == 12'd8);
	// memDataIn[1:0] cases: 00=red sound, 01=blue, 10=green, 11=yellow
	audio make_sound(.clock(clock), .play_audio(play_audio), .color(memDataIn[3:1]), .on_off(memDataIn[0]), .audioEn(audioEn), .audioOut(audioOut));

	wire [31:0] button_out;
	wire poll_button;
	// if lw to address 7, calling check_buttons
	assign poll_button = (memAddr[11:0] == 12'd7);
	assign memDataOut = (memAddr[11:0] == 12'd7) ? button_out : memData_temp1;
	// only assign memdataout to the actual color, and only if there was a button press?
	button_press press(red_button, yellow_button, blue_button, green_button, clock, poll_button, button_out);

	// sw to address 9 is useServo = 1
	//000 goes nowhere, 001 forward, 010 backwards , 011 turn left, 100 turns right;
	wire useServo;
	assign useServo = (mwe == 1'b1) & (memAddr[11:0] == 12'd9);
	ServoController servo(.clk(clock), .useServo(useServo), .direction(memDataIn[2:0]), .left_servo(left_servo), .right_servo(right_servo)); 

	// sw to address 10 is for displaying value to 7 seg
	wire change_score;
	assign change_score = (mwe == 1'b1) & (memAddr[11:0] == 12'd10);
	//score display_score(clock, 1'b1, 7'd27, AN[0], AN[1], CA, CB, CC, CD, CE, CF, CG);
	score display_score(clock, change_score, memDataIn[7:0], anode_ones, anode_tens, top, top_right, bot_right, bot, bot_left, top_left, middle);
	reg [7:0] LED_reg;
	always @(posedge clock) begin
	   if(change_score)
	       LED_reg[7:0] <= memDataIn[7:0];
   end
   assign LED[7:0] = LED_reg;
	//score display_score(clock,  1'b1, 7'd27, anode_ones, anode_tens, top, top_right, bot_right, bot, bot_left, top_left, middle);
    //assign {top, top_right, bot_right, bot, bot_left, top_left, middle} = switches;
    //assign anode_ones = 1'b0; 
    //assign anode_tens = 1'b0;

endmodule
