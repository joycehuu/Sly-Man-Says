module score(clock, change_score, number, anode_ones, anode_tens, top, top_right, bot_right, bot, bot_left, top_left, middle);
    input clock, change_score;
    input[7:0] number; // number to display on 3 digit 7seg
    output reg anode_ones, anode_tens, top, top_right, bot_right, bot, bot_left, top_left, middle;

    reg [3:0] tens, ones;  
    reg current_digit;          
    reg [3:0] digit_value; 

    // Splitting the number into each digit
    always @(posedge clock) begin
        if (change_score) begin  
            tens <= number / 10; 
            ones <= number % 10;        
        end
    end

    // which digit to turn on
    always @(posedge clock) begin
        // Cycle through digits
        current_digit <= current_digit + 1; 
        case (current_digit)
            2'b0: begin
                anode_ones <= 1'b0;  
                anode_tens <= 1'b1;
                digit_value <= ones;
            end
            2'b1: begin
                anode_ones <= 1'b1;  
                anode_tens <= 1'b0;
                digit_value <= tens;
            end
        endcase
    end

    // 7 seg decoding
    always @(posedge clock) begin
        case (digit_value)
            4'd0: {top, top_right, bot_right, bot, bot_left, top_left, middle} <= 7'b1111110;
            4'd1: {top, top_right, bot_right, bot, bot_left, top_left, middle} <= 7'b0110000;
            4'd2: {top, top_right, bot_right, bot, bot_left, top_left, middle} <= 7'b1101101;
            4'd3: {top, top_right, bot_right, bot, bot_left, top_left, middle} <= 7'b1111001;
            4'd4: {top, top_right, bot_right, bot, bot_left, top_left, middle} <= 7'b0110011;
            4'd5: {top, top_right, bot_right, bot, bot_left, top_left, middle} <= 7'b1011011;
            4'd6: {top, top_right, bot_right, bot, bot_left, top_left, middle} <= 7'b1011111;
            4'd7: {top, top_right, bot_right, bot, bot_left, top_left, middle} <= 7'b1110000;
            4'd8: {top, top_right, bot_right, bot, bot_left, top_left, middle} <= 7'b1111111;
            4'd9: {top, top_right, bot_right, bot, bot_left, top_left, middle} <= 7'b1111011;
            default: {top, top_right, bot_right, bot, bot_left, top_left, middle} <= 7'b0000000; // Blank display
        endcase
    end

endmodule