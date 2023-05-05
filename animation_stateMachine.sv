module animation_stateMachine(input logic Clk,
									input logic Reset,
									input logic animationEnable,
									input logic [9:0] snakeXPos,
									input logic [9:0] snakeYPos,
									output logic AnimationActive,
									output logic [2:0] offset);
				 
				 
enum logic [3:0] {Halted, 
						V1,
						V2,
						V3,
						V4,
						V5,
						V6,
						V7} State, Next_state;
						
						
logic bulletDirLatch;
logic [6:0] cntr;

always_ff @ (posedge Clk or posedge Reset or posedge animationEnable) begin

	if (Reset)
		State <= Halted;
	else
		State <= Next_state;
		
	
end

logic cntr_rst;
always_ff @(posedge Clk) begin
	if (cntr_rst)
				cntr <= '0;
	else if (State != Halted)
		cntr = cntr + 1;
end

always_comb begin

	Next_state = State;
	
	AnimationActive = 1'b0;
	offset = 3'b000;
	cntr_rst = '0;
	
	unique case (State)
	
		Halted: begin
		
			if (animationEnable) begin
			
				Next_state = V1;
			
			end
		
		end
		
		V1: Next_state = V2;

		V2: Next_state = V3;
		
		V3: Next_state = V4;
		
		V4: Next_state = V5;
		
		V5: Next_state = V6;
		
		V6: Next_state = V7;
		
		V7: Next_state = Halted;
				
		
		default: ;
	
	endcase
	
	
	case (State)
	
		Halted: ;
		
		V1: begin
		
			offset = 3'b000;
			AnimationActive = 1'b1;
		
		end
		
		
		V2: begin
		
			offset = 3'b001;
			AnimationActive = 1'b1;
		
		end
		
		
		V3: begin
		
			offset = 3'b010;
			AnimationActive = 1'b1;
		
		end
		
		V4: begin
		
			offset = 3'b011;
			AnimationActive = 1'b1;
		
		end
		
		
		V5: begin
		
			offset = 3'b100;
			AnimationActive = 1'b1;
		
		end
		
		V6: begin
		
			offset = 3'b101;
			AnimationActive = 1'b1;
		
		end
		
		V7: begin
		
			offset = 3'b110;
			AnimationActive = 1'b1;
		
		end
		
		
		default: ;
		
	endcase
		
end




endmodule
