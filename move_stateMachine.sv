module move_stateMachine(
			input  logic Clk,
			input  logic [7:0] keycode,
			output logic [1:0] motionFlag,
			output logic Load );
			
//			
//enum logic [3:0] {HALTED,
//						W,
//						A,
//						S,
//						D} State, Next_State;
//						
//always ff @ (posedge Clk)
//begin
//	
//	if (Reset)
//		State <= HALTED;
//	else
//		State <= Next_State;
//	
//end

logic [7:0] keycodeOut;

always_comb 
begin

//	Next_State = State;
	
	motionFlag = 2'b00;
	Load = 1'b0;
	
	unique case (keycode)
	
		8'h1A	:	begin
						motionFlag = 2'b00;	// W
						Load = 1'b1;
					end
		8'h04	:	begin
						motionFlag = 2'b01;	// A
						Load = 1'b1;
					end
		8'h16	:	begin
						motionFlag = 2'b10;	// S
						Load = 1'b1;
					end
		8'h07	:	begin
						motionFlag = 2'b11;	// D
						Load = 1'b1;
					end
					
		default: Load = 1'b0;
		
	endcase
end


endmodule
