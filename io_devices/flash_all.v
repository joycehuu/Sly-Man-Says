module flash_all(input clock, output red_led, output blue_led, output green_led, output yellow_led);
    // clock freq (turn on all LEDs for one second and then turn them off after 4 seconds)
    localparam CLOCK_FREQ = 50000000; // 50 MHz
    localparam ONE_SECOND = CLOCK_FREQ; // one sec
    localparam SIX_SECONDS = CLOCK_FREQ * 6; // 6 seconds

    // counter for clock timing
    reg [31:0] counter = 0;

    // whether led should be on or off
    reg leds_on = 0;

    always @(posedge clock) begin
        if (counter <= ONE_SECONDS) begin
            counter <= counter + 1;
            leds_on <= 1'b1; // turn on led
        end else if(counter <= SIX_SECONDS) begin
            counter <= counter + 1; // reset the counter after 6 seconds
            leds_on <= 1'b0; // turn off led
        end else begin
            counter <= 0; // reset the counter after 6 seconds (if > 6 sec)
        end
    end

    // turn leds on or off
    always @(posedge clock) begin
        if (leds_on) begin
            red_led <= 1;
            blue_led <= 1;
            green_led <= 1;
            yellow_led <= 1;
        end else begin
            red_led <= 0;
            blue_led <= 0;
            green_led <= 0;
            yellow_led <= 0;
        end
    end

endmodule