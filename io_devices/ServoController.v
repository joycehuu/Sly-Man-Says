module ServoController(clk, useServo, direction, left_servo, right_servo);
    input clk, useServo;
    input[2:0] direction;
    output left_servo, right_servo;	
    
    // Direction: 000 goes nowhere, 001 forward, 010 backwards , 011 turn left, 100 turns right;
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
    // 50 mhz clk
    PWMSerializer #(20000000, 50) left(clk, 1'b0, duty_cycle_left, left_servo);
    PWMSerializer #(20000000, 50) right(clk, 1'b0, duty_cycle_right, right_servo);
    
endmodule