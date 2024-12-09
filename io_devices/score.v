module score(
    input clock, 
    input change_score, 
    input [7:0] number, // number to display on 2-digit 7seg
    output reg anode_ones, anode_tens, 
    output reg top, top_right, bot_right, bot, bot_left, top_left, middle
);
    reg [3:0] tens, ones;  
    reg digit_toggle;  // Toggle between ones and tens
    reg [3:0] digit_value; 
    wire clock_div;
    localparam CYCLE = 500000; // 500 kHz for clock division
    reg [32:0] counter;

    // Splitting the number into tens and ones
    always @(posedge clock) begin
        if (change_score) begin  
            tens <= number / 10; 
            ones <= number % 10;        
        end
    end

    // Clock divider for cycling through digits
    always @(posedge clock) begin
        if (counter > CYCLE)
            counter <= 0;
        else
            counter <= counter + 1;
    end
    
    assign clock_div = counter >= (CYCLE >> 1) ? 1'b1 : 1'b0;

    // Toggle between tens and ones
    always @(posedge clock_div) begin
        digit_toggle <= ~digit_toggle;  // Toggle between 0 and 1
    end

    // Which digit to turn on
    always @(clock_div) begin
        case (digit_toggle)
            1'b0: begin
                digit_value = tens;
                anode_ones = 1'b1;  
                anode_tens = 1'b0;
            end 
            1'b1: begin
                digit_value = ones;
                anode_ones = 1'b0;  
                anode_tens = 1'b1;
            end
        endcase
    end

    // 7-segment decoding
    always @(clock_div) begin
        case (digit_value)
            4'd0: {top, top_right, bot_right, bot, bot_left, top_left, middle} = 7'b1111110;
            4'd1: {top, top_right, bot_right, bot, bot_left, top_left, middle} = 7'b0110000;
            4'd2: {top, top_right, bot_right, bot, bot_left, top_left, middle} = 7'b1101101;
            4'd3: {top, top_right, bot_right, bot, bot_left, top_left, middle} = 7'b1111001;
            4'd4: {top, top_right, bot_right, bot, bot_left, top_left, middle} = 7'b0110011;
            4'd5: {top, top_right, bot_right, bot, bot_left, top_left, middle} = 7'b1011011;
            4'd6: {top, top_right, bot_right, bot, bot_left, top_left, middle} = 7'b1011111;
            4'd7: {top, top_right, bot_right, bot, bot_left, top_left, middle} = 7'b1110000;
            4'd8: {top, top_right, bot_right, bot, bot_left, top_left, middle} = 7'b1111111;
            4'd9: {top, top_right, bot_right, bot, bot_left, top_left, middle} = 7'b1111011;
            default: {top, top_right, bot_right, bot, bot_left, top_left, middle} = 7'b0000000; // Blank display
        endcase
    end

endmodule
