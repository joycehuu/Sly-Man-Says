module ServoController(
    input        clk, 		     // System Clock Input 100 Mhz
    input        clk_100mhz,
    input        useServo,        // tells us that we want to use the servos
    input       [2:0] direction, // 000 goes nowhere, 001 forward, 010 backwards , 011 turn left, 100 turns right;
    output left_servo,
    output right_servo);	
        
    reg[9:0] duty_cycle_left, duty_cycle_right;
    reg[2:0] direction_reg;
    
    always @ (posedge clk) begin 
        if(useServo == 1'b1) begin
            direction_reg <= direction;
        end
    end
    
    always @ (posedge clk) begin 
        case (direction_reg) 
            3'b000: begin
                duty_cycle_left = 10'd28;
                duty_cycle_right = 10'd28;
            end
            3'b001: begin
                duty_cycle_left = 10'd50;  // forwards
                duty_cycle_right = 10'd6;
            end
            3'b010: begin
                duty_cycle_left = 10'd6;   // backwards
                duty_cycle_right = 10'd50;
            end
            3'b011: begin
                duty_cycle_left = 10'd6;   // turn left
                duty_cycle_right = 10'd28;
            end
            3'b100: begin
                duty_cycle_left = 10'd50;  // turn right
                duty_cycle_right = 10'd28;
            end
            default: begin
                duty_cycle_left = 10'd28;
                duty_cycle_right = 10'd28;
            end
        endcase
    end

    // 20 ms period = 20,000,000 ns
    // 100 mhz clk
    PWMSerializer #(20000000, 100) left(clk_100mhz, 1'b0, duty_cycle_left, left_servo);
    PWMSerializer #(20000000, 100) right(clk_100mhz, 1'b0, duty_cycle_right, right_servo);
    
endmodule