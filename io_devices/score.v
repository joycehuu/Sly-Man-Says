module score(clock, change_score, number, cathode_1, cathode_2, cathode_3, top, top_right, bot_right, bot, bot_left, top_left, middle);
    input clock, change_score;
    input[9:0] number; // number to display on 3 digit 7seg
    output cathode_1, cathode_2, cathode_3, top, top_right, bot_right, bot, bot_left, top_left, middle;

    reg [3:0] hundreds, tens, ones;  
    reg [1:0] current_digit;          
    reg [3:0] digit_value; 

    // Splitting the number into each digit
    always @(posedge clock) begin
        if (change_score) begin
            hundreds = number / 100;     
            tens = (number % 100) / 10; 
            units = number % 10;        
        end
    end

    // which digit to turn on
    always @(posedge clock) begin
        // Cycle through digits 0, 1, 2
        current_digit <= current_digit + 1; 
        case (current_digit)
            2'b00: begin
                cathode_1 = 1'b0;  
                cathode_2 = 1'b1;
                cathode_3 = 1'b1;
                digit_value = hundreds;
            end
            2'b01: begin
                cathode_1 = 1'b1;
                cathode_2 = 1'b0; 
                cathode_3 = 1'b1;
                digit_value = tens;
            end
            2'b10: begin
                cathode_1 = 1'b1;
                cathode_2 = 1'b1;
                cathode_3 = 1'b0;
                digit_value = units;
            end
        endcase
    end

    // 7 seg decoding
    always @(*) begin
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