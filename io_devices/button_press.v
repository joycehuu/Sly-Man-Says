module button_press(input red_button, input yellow_button, input blue_button, input green_button, input clock, output[31:0] button_out);
    // latch most recent button, until a new one is pressed
    // 00=red (0), 01=blue (1), 10=green (2), 11=yellow (3)

    // xx which button ... x was pressed, x was read 
    // 4 bit number.... xxxx
    reg [2:0] button_pressed; 
    always @(posedge clock) begin
        case({red_button, blue_button, green_button, yellow_button})
            4'b1000: button_pressed = 3'b001;
            4'b0100: button_pressed = 3'b011;
            4'b0010: button_pressed = 3'b101;
            4'b0001: button_pressed = 3'b111;
            4'b0000: button_pressed = 3'b000;
        endcase
    end
    assign button_out[31:3] = 29'd0; 
    assign button_out[2:0] = button_pressed;

endmodule