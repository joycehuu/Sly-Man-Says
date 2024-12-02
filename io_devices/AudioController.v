module AudioController(
    input        clk, 		// System Clock Input 100 Mhz
    input[9:0]   switches,	// Tone control switches
    output       audioOut,	// PWM signal to the audio jack	
    output       audioEn);	// Audio Enable

	localparam MHz = 1000000;
	localparam SYSTEM_FREQ = 100*MHz; // System clock frequency
 
	assign audioEn = 1'b1;  // Enable Audio Output

	// Initialize the frequency array. FREQs[0] = 261
	reg[10:0] FREQs[0:15];
	initial begin
		$readmemh("FREQs.mem", FREQs);
	end

	wire[17:0] CounterLimit; 
	assign CounterLimit = SYSTEM_FREQ/(FREQs[switches[3:0]]<<1) - 1;
	////////////////////
	// Your Code Here //
	////////////////////
	reg clk1MHz = 0;
	reg[17:0] counter = 0;
	always @(posedge clk) begin
		if(counter < CounterLimit)
			counter <= counter + 1;
		else begin
			counter <= 0;
			clk1MHz <= ~clk1MHz;
		end
	end

	wire[9:0] duty_cycle;
	assign duty_cycle = clk1MHz ? 10'd900 : 10'd100;

	PWMSerializer pwm(clk, 1'b0, duty_cycle, audioOut);

	
endmodule