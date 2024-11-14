module light_up(input clock, input flash_led, input[1:0] color, input on_off, output red_led, output blue_led, output green_led, output yellow_led);
    reg[1:0] color_led; 
    reg onoff_reg;
    wire [3:0] assign_colors;

    always @(posedge clock) begin
        if(flash_led == 1'b1) begin
            color_led <= color;
            onoff_reg <= on_off;
        end
    end

    assign assign_colors = onoff_reg << color_led; 
    assign red_led = assign_colors[0];
    assign blue_led = assign_colors[1];
    assign green_led = assign_colors[2];
    assign yellow_led = assign_colors[3];

endmodule