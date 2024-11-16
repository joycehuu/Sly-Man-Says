module button_press(input red_button, input yellow_button, input blue_button, input green_button, input clock, input poll_button, output[31:0] button_out);
    // latch most recent button, until a new one is pressed
    // 00=red (0), 01=blue (1), 10=green (2), 11=yellow (3)

    // xx which button ... x was pressed, x was read 
    // 4 bit number.... xxxx
    reg [2:0] button_pressed; 
    reg[31:0] counter;
    wire [31:0] button_temp1;

    wire first_cycle; 
    assign first_cycle = button_pressed[0] & poll_button;

    always @(posedge clock) begin
        case({red_button, blue_button, green_button, yellow_button})
            4'b1000: button_pressed = 3'b001;
            4'b0100: button_pressed = 3'b011;
            4'b0010: button_pressed = 3'b101;
            4'b0001: button_pressed = 3'b111;
            4'b0000: button_pressed = 3'b000;
        endcase
    end
    assign button_temp1[31:3] = 29'd0; 
    assign button_temp1[2:0] = button_pressed;

    assign button_out = (counter < 100000000) & (!first_cycle) ? 32'd0 : button_temp1;

    always @(posedge clock) begin
        if (poll_button == 1 && counter >= 100000000)
            counter <= 1;
        else if(counter > 0)
            counter <= counter + 1;
    end 

endmodule