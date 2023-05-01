module health_stateMachine(input logic Clk,
									input logic Reset,
									input logic collision,
									output logic [1:0] healthCount,
									output logic gameEnd);
				 
				 
enum logic [3:0] {Halted, 
						Health3,
						Health2,
						Health1,
						Health0,
						WaitState1,
						WaitState2,
						WaitState3,
						WaitState4,
						WaitState5,
						WaitState6} State, Next_state;
						
						
logic bulletDirLatch;

//logic [6:0] counter;

always_ff @ (posedge Clk) begin

	if (Reset)
		State <= Halted;
		
	else begin
		
		State <= Next_state;
		
		
	end
		
		
	
end

always_comb begin

	Next_state = State;
	
	healthCount = 2'b11;
	gameEnd = 1'b0;
	
	unique case (State)
	
		Halted: Next_state = Health3;
		
		Health3: begin
		
			if (collision) Next_state = WaitState1;
		
		end
		
		WaitState1: begin
		
			if (collision) Next_state = WaitState1;
			else Next_state = WaitState2;
		
		end
		
		WaitState2: begin
		
			if (collision) Next_state = WaitState2;
			else Next_state = Health2;
		
		end
		
		Health2: begin
		
			if (collision) Next_state = WaitState3;
				
		end
		
		WaitState3: begin
		
			if (collision) Next_state = WaitState3;
			else Next_state = WaitState4;
		
		end
		
		WaitState4: begin
		
			if (collision) Next_state = WaitState2;
			else Next_state = Health1;
		
		end
		
		Health1: begin
		
			if (collision) Next_state = WaitState5;
		
		end
		
		WaitState5: begin
		
			if (collision) Next_state = WaitState5;
			else Next_state = WaitState5;
		
		end
		
		WaitState5: begin
		
			if (collision) Next_state = WaitState5;
			else Next_state = Health0;
		
		end
		
		Health0: ;
				
		
		default: ;
	
	endcase
	
	
	case (State)
	
		Halted: ;
		
		Health3		:	healthCount = 2'b11;
		WaitState1	:	healthCount = 2'b11;
		WaitState2	:	healthCount = 2'b11;
		Health2		:	healthCount = 2'b10;
		WaitState3	:	healthCount = 2'b10;
		WaitState4	:	healthCount = 2'b10;
		Health1		:	healthCount = 2'b01;
		WaitState5	:	healthCount = 2'b01;
		WaitState6	:	healthCount = 2'b01;
		
		Health0		:	begin
		
			healthCount = 2'b00;
			gameEnd		= 1'b1;
			
		end
		
		
		default: ;
		
	endcase
		
end


endmodule
