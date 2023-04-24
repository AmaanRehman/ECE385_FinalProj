module reg_unit #(parameter N = 16) (input  logic Clk, Reset, Load,
											    input  logic [N-1:0] Din,
												 output logic [N-1:0] Data_Out	);
				  
    always_ff @ (posedge Clk)
    begin
	 
	 	 if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			  Data_Out <= 16'h0;
			  
		 else if (Load)
			  Data_Out <= Din;
    end
	 
endmodule
