module button_press(input BTNU, input BTNL, input BTNR, input BTNC, input BTND, input clk);
    // up = red, left = yellow, down=green, right=blue
    always @(posedge clk) begin
		if(counter < CounterLimit)
			counter <= counter + 1;
		else begin
			counter <= 0;
			clk1MHz <= ~clk1MHz;
		end
	end
endmodule