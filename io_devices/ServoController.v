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

    // for JC
    // 28 gives duty cycle of 2.75% = no movement -> 28
    // higher is CCW > 2.75%  (5%) -> 36
    // lower is CW < 2.75% (2.15%) -> 20
    // for JB
    // 73 gives duty cycle of 7.255% = no movement -> 74
    // higher is CCW > 7.3%  (9.5%) -> 82
    // lower is CW < 7.3% (5.1%) -> 66
    always @ (posedge clk) begin 
        case (direction_reg) 
            3'b000: begin
                duty_cycle_left = 10'd75;
                duty_cycle_right = 10'd28;
            end
            3'b001: begin
                duty_cycle_left = 10'd82;  // forwards
                duty_cycle_right = 10'd20;
            end
            3'b010: begin
                duty_cycle_left = 10'd66;   // backwards
                duty_cycle_right = 10'd36;
            end
            3'b011: begin
                duty_cycle_left = 10'd82;   // turn left
                duty_cycle_right = 10'd36;
            end
            3'b100: begin
                duty_cycle_left = 10'd66;  // turn right
                duty_cycle_right = 10'd20;
            end
            3'b101: begin
                duty_cycle_left = 10'd86;  // forwards faster
                duty_cycle_right = 10'd16;
            end
            3'b110: begin
                duty_cycle_left = 10'd62;   // backwards faster
                duty_cycle_right = 10'd40;
            end
            default: begin
                duty_cycle_left = 10'd75;
                duty_cycle_right = 10'd28;
            end
        endcase
    end

    // 20 ms period = 20,000,000 ns
    // 50 mhz clk
    PWMSerializer #(20000000, 50) left(clk, 1'b0, duty_cycle_left, left_servo);
    PWMSerializer #(20000000, 50) right(clk, 1'b0, duty_cycle_right, right_servo);
    
endmodule