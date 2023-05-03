module VGA_Random_Coords (
  input Clk,
  input reset,
  input seedIn,
  output logic [9:0] rnd
);

logic feedback;
assign feedback = random[9] ^ random[6] ^ seedIn;

logic [9:0] random, random_next, random_done;

assign random_next = {random[8:0], feedback};

logic [3:0] count;

always_ff @(posedge Clk or posedge reset) begin

	
	if (reset) begin
	
		random <= 10'hF;
		count <= 4'd0;
	
	end
	
	else begin
	
		random <= random_next;
		count <= count + 1;
		
		if (count == 4'd9) begin
		
			count <= 0;
			
			random_done <= random;
		
		end
	
	end
end


assign rnd = random_done;


endmodule
