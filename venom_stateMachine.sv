module venom_stateMachine(input logic Clk,
									input logic Reset,
									input logic [15:0] keycode,
									input logic [7:0] expectedKeycode,
									input logic collision,
									input logic [1:0] venomCount,venomCountState,
									input logic [1:0] motionFlag,
									output logic [1:0] bulletDir,
									output logic venomMovement,
									output logic LED);
				 
				 
enum logic [2:0] {Halted, 
						Idle,
						bulletFired,
						bulletMoving} State, Next_state;
						
						
logic bulletDirLatch;

always_ff @ (posedge Clk or posedge Reset) begin

	if (Reset)
		State <= Halted;
	else
		State <= Next_state;
	
end


always_ff @ (posedge Clk) begin

	if (bulletDirLatch) bulletDir <= motionFlag;

end

always_comb begin

	Next_state = State;
	
	bulletDirLatch = 1'b0;
	venomMovement = 1'b0;
	LED = 1'b0;
	
	unique case (State)
	
		Halted: Next_state = Idle;
		
		Idle: begin
		
				if ((keycode[15:8] == expectedKeycode  || keycode[7:0] == expectedKeycode) && (venomCount == venomCountState)) begin
				
					Next_state = bulletFired;
					LED = 1'b1;
					
				end
				
				else Next_state = Idle;
		end
		
		bulletFired: Next_state = bulletMoving;
		
		bulletMoving: begin
		
			if (collision) Next_state = Idle;
			else Next_state = bulletMoving;
		
		end
				
		
		default: ;
	
	endcase
	
	
	case (State)
	
		Halted: ;
		
		Idle 			 : venomMovement = 1'b0;
		
		bulletFired  : begin
		
			bulletDirLatch = 1'b1; 
		
		end
		
		
		bulletMoving: venomMovement = 1'b1;
		
		default: ;
		
	endcase
		
end


endmodule
