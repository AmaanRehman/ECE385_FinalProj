module mux_4_1_16(input logic  [15:0] A, B, C, D,
						input logic  [1 :0] SelectBit,
						output logic [15:0] Out );
						
always_comb
begin
	
	if(SelectBit == 2'b00) begin
		Out = A; end
		
	else if(SelectBit == 2'b01) begin
		Out = B; end
		
	else if(SelectBit == 2'b10) begin
		Out = C; end
		
	else if(SelectBit == 2'b11) begin
		Out = D; end
	
	else begin
		Out = 16'hxxxx; end
		
	
end

endmodule

