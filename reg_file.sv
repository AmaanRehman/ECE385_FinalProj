module reg_file(input logic Clk, LD_REG, Reset,
					 input logic [3:0] Index,
					 input logic [3:0] access_Index,
					 input logic [19:0] Data_In,
					 output logic [19:0] Data_Out);
					 
	logic [19:0] reg_file [15];

	always_ff @ (posedge Clk)
		begin
			if(Reset) begin
				
				for (integer i = 0; i < 15; i = i + 1) begin
					
					reg_file[i] <= 20'b0;
					
				end
				
			end
			
			else if(LD_REG) begin
			
				reg_file[Index] <= Data_In;
			
			end
			
		end
		
	always_comb
		begin
		
			Data_Out = reg_file[access_Index];
		
		end
endmodule
