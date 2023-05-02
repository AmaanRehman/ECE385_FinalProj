module reg_file(input logic Clk, LD_REG, Reset,
					 input logic [2:0] SR1_In, SR2_In, DR_In,
					 input logic [15:0] Bus_In,
					 output logic [15:0] SR1OUT, SR2OUT);
					 
	logic [15:0] reg_file [8];

	always_ff @ (posedge Clk)
		begin
			if(Reset) begin
				
				for (integer i = 0; i < 8; i = i + 1) begin
					
					reg_file[i] <= 16'b0;
					
				end
				
			end
			
			else if(LD_REG) begin
			
				reg_file[DR_In] <= Bus_In;
			
			end
			
		end
		
	always_comb
		begin
		
			SR1OUT = reg_file[SR1_In];
			SR2OUT = reg_file[SR2_In];
		
		end
endmodule
