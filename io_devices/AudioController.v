module AudioController(
    input        clk, 		// System Clock Input 100 Mhz
    output servoSignal,
    input        micData,	// Microphone Output
    input[9:0]   switches,	// Tone control switches
    output reg   micClk = 0, 	// Mic clock 
    output       chSel,		// Channel select; 0 for rising edge, 1 for falling edge
    output       audioOut,	// PWM signal to the audio jack	
    output       audioEn);	// Audio Enable

	localparam MHz = 1000000;
	localparam SYSTEM_FREQ = 100*MHz; // System clock frequency

	assign chSel   = 1'b0;  // Collect Mic Data on the rising edge 
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

	wire[9:0] duty_cycle1;
	wire[9:0] duty_cycle;
	assign duty_cycle = (duty_cycle1 + duty_cycle2)/2;
	assign duty_cycle = clk1MHz ? 10'd1023 : 10'd0;

	PWMSerializer pwm(clk, 1'b0, duty_cycle, audioOut);

	wire[5:0]  micThresh;
	assign micThresh = (SYSTEM_FREQ / (1*MHz)) >> 1;

	reg capturedBit = 0;
	reg[31:0] micCounter = 0;
	always @(posedge clk) begin
		if (micCounter < micThresh - 1)  
			micCounter <= micCounter + 1;
		else begin
			micCounter <= 0;
			micClk <= ~micClk;
		end
	end

	always @(posedge micClk) begin
		capturedBit <= micData; // Assign mic input on the clock edges
	end
	wire[9:0] duty_cycle2;
	PWMDeserializer pwmd2(clk, 1'b0, micData, duty_cycle2);

	
endmodule