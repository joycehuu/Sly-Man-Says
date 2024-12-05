module audio(clock, play_audio, color, on_off, audioEn, audioOut);
    input clock, play_audio, on_off;
    input [2:0] color;
    output audioEn, audioOut;

    reg[2:0] color_reg; 
    reg onoff_reg;
    wire [3:0] assign_colors;

    always @(posedge clock) begin
        if(play_audio == 1'b1) begin
            color_reg <= color;
            onoff_reg <= on_off;
        end
    end

    localparam MHz = 1000000;
	localparam SYSTEM_FREQ = 50*MHz; // System clock frequency
 
	assign audioEn = onoff_reg;  // Enable Audio Output

	// Initialize the frequency array. FREQs[0] = 261
	reg[10:0] FREQs[0:4];
	initial begin
        $readmemh("FREQs.mem", FREQs);
        // assign FREQs[0] = 25000000 / 261;
        // assign FREQs[1] = 25000000 / 500;  
        // assign FREQs[2] = 25000000 / 700;
        // assign FREQs[3] = 25000000 / 880;
	end

	wire[17:0] CounterLimit; 
	assign CounterLimit = SYSTEM_FREQ/(FREQs[color_reg]<<1) - 1;
	//assign CounterLimit = FREQs[color_reg];

	reg clk1MHz = 0;
	reg[17:0] counter = 0;
	always @(posedge clock) begin
		if(counter < CounterLimit)
			counter <= counter + 1;
		else begin
			counter <= 0;
			clk1MHz <= ~clk1MHz;
		end
	end

	wire[9:0] duty_cycle;
	assign duty_cycle = clk1MHz ? 10'd900 : 10'd100;

	PWMSerializer pwm(clock, 1'b0, duty_cycle, audioOut);


endmodule