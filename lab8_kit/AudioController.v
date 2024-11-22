module AudioController(
    input        clk, 		// System Clock Input 100 Mhz
    output[15:0] LED,
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
	
	////////////////////
	// Your Code Here //
	////////////////////
	
	wire[17:0] CounterLimit;
	assign CounterLimit = (SYSTEM_FREQ)/(FREQs[switches]) -1; 
	
	reg clk1MHz = 0;
	reg[17:0] counter=0;
	always @(posedge clk) begin 
	   if(counter < CounterLimit)
	       counter <= counter + 1;
	   else begin
	       counter <= 0;
	       clk1MHz <= ~clk1MHz;
	   end
	end

    wire [9:0] duty_cycle;
//    assign duty_cycle = clk1MHz ? 10'd900 : 10'd100;
    
    wire speakerOut;

//    PWMSerializer pwm(.clk(clk), .duty_cycle(duty_cycle), .signal(speakerOut));
    
    wire[5:0] micThresh;
    assign micThresh = (SYSTEM_FREQ / (MHz)) >> 1;
    
    reg capturedBit = 0;
    reg[31:0] micCounter = 0;
    wire[9:0] duty_cycle_mic;
    wire[9:0] duty_cycle_avg;
    always @(posedge clk) begin
        if (micCounter < micThresh - 1)
            micCounter <= micCounter + 1;
        else begin
            micCounter <= 0;
            micClk <= ~micClk;
        end
    end
    
    always @(posedge micClk) begin
        capturedBit <= micData;
    end
    
    wire micOut;
    PWMDeserializer pwmd(.clk(clk), .signal(micData), .duty_cycle(duty_cycle));
//    assign duty_cycle_avg = (duty_cycle + duty_cycle_mic) / 2;
    PWMSerializer pwmLast(.clk(clk), .duty_cycle(duty_cycle), .signal(audioOut));
//    assign audioOut = micOut + speakerOut;

    

endmodule