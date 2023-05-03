module Second_Counter (input clk_60Hz,
							  input reset,
							  output [31:0] count
);


logic [25:0] counter;

always_ff @(posedge clk_60Hz or posedge reset)
begin

	if (reset) begin
	
			count <= 0;
			counter <= 0;
		
	end
	
	else begin
	
		counter <= counter + 1;
		
		if(counter == 60) begin
		
        counter <= 0;
        count <= count + 1;
		  
		end
	end

end

endmodule
