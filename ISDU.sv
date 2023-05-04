module ISDU (input logic Clk,
				 input logic Reset,
				 input logic [15:0] keycode,
				 input logic player1wins,
				 input logic player2wins,
				 input logic tie,
				 output logic LD_MENU,
				 output logic LD_Map1,
				 output logic LD_S1ENDGAME,
				 output logic LD_S2ENDGAME,
				 output logic Pause_En);
				 
				 
enum logic [3:0] {Halted,
						MainMenu,
						Play_M1,
						Snake1wins,
						Snake2wins,
						Wait_state1} State, Next_state;
						

always_ff @ (posedge Clk) begin

	if (Reset)
		State <= Halted;
	else
		State <= Next_state;
	
end

always_comb begin

	Next_state = State;
	
	LD_MENU  = 1'b0;
	LD_Map1  = 1'b0;
	Pause_En = 1'b0;
	LD_S1ENDGAME = 1'b0;
	LD_S2ENDGAME = 1'b0;
	
	unique case (State)
	
		Halted: Next_state = MainMenu;
		
		MainMenu: begin
		
				if (keycode[15:8] == 8'd88 || keycode[7:0] == 8'd88) begin
				
					Next_state = Play_M1;
					
				end
				
				else Next_state = MainMenu;
		end
		
		Play_M1: begin
		
			if (player1wins) begin
			
				Next_state = Snake1wins;
			
			end
			
			else if (player2wins) begin
			
				Next_state = Snake2wins;
			
			end
		
			else Next_state <= Play_M1;
			
		end
		
		Snake1wins: begin
		
			if (keycode[15:8] == 8'd88 || keycode[7:0] == 8'd88) begin
				
					Next_state = Wait_state1;
					
				end
				
			else Next_state = Snake1wins;
		
		end
		
		Snake2wins:  begin
		
			if (keycode[15:8] == 8'd88 || keycode[7:0] == 8'd88) begin
				
					Next_state = Wait_state1;
					
				end
				
			else Next_state = Snake2wins;
		
		end
		
		Wait_state1: begin
		
				if (keycode[15:8] == 8'd88  || keycode[7:0] == 8'd88 ) begin
						
					Next_state = Wait_state1;
							
				end
				
				else Next_state = MainMenu;
		
		end
		
		default: ;
	
	endcase
	
	
	case (State)
	
		Halted: ;
		MainMenu	   : LD_MENU = 1'b1;
		Play_M1	   : LD_Map1 = 1'b1; 
		Snake1wins	: LD_S1ENDGAME = 1'b1;
		Snake2wins	: LD_S2ENDGAME = 1'b1;
		
		default: ;
		
	endcase
		
end


endmodule
