module ServoController(
    input        clk, 		    // System Clock Input 100 Mhz
    input[9:0]   switches,	    // Position control switches
    output       servoSignal    // Signal to the servo
    );	
        
    wire[9:0] duty_cycle;
    
    localparam PERIOD_WIDTH_NS = 20000000;  // Total width of the period in nanoseconds
    localparam SYS_FREQ_MHZ   = 100;
    localparam SYSTEM_FREQ = 100*MHz;
    localparam MHz = 1000000;

    
    ////////////////////
	// Your Code Here //
	////////////////////
	
    assign duty_cycle = clk1MHz ? 10'd100 : 10'd50;
    
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

	PWMSerializer #(.PERIOD_WIDTH_NS(PERIOD_WIDTH_NS), .SYS_FREQ_MHZ(SYS_FREQ_MHZ)) ServoSerializer(.clk(clk), .duty_cycle(duty_cycle), .signal(servoSignal));
    
endmodule