module ServoController(
    input        clk, 		    // System Clock Input 100 Mhz
    input[9:0]   switches,	    // Position control switches
    output       servoSignal    // Signal to the servo
    );	
        
    wire[9:0] duty_cycle, duty_cycle1;

    // 28 gives duty cycle of 2.75% = no movement
    // higher is CCW > 2.75%  (5%) -> 50
    // lower is CW < 2.75% (0.50%) -> 6
    assign duty_cycle1 = switches[0] ? 10'd50 : 10'd28;
	assign duty_cycle = switches[1] ? 10'd6 : duty_cycle1;

    // 20 ms period = 20,000,000 ns
    // 100 mhz clk
    PWMSerializer #(20000000, 100) ServoSerializer(clk, 1'b0, duty_cycle, servoSignal);
    
endmodule