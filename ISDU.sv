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
				 output logic Pause_En,
				 output logic AnimationActive,
				 output logic [2:0] offset,
				 output logic AnimationActive1,
				 output logic [2:0] offset1);
				 
				 
enum logic [6:0] {Halted,
						MainMenu,
						Play_M1,
						Snake1wins,
						Snake2wins,
						Wait_state1,
						V1,
						V2,
						V3, V3_1,
						V4, V4_1,
						V5,
						V6,
						V7,
						V11,
						V21,
						V31, V3_11,
						V41, V4_11,
						V51,
						V61,
						V71} State, Next_state;
						

always_ff @ (posedge Clk or posedge Reset) begin

	if (Reset)
		State <= Halted;
	else
		State <= Next_state;
	
end

logic [31:0] cntr, counter;
logic cntr_rst;

always_ff @ (posedge Clk or posedge Reset or posedge cntr_rst) begin

	if (Reset | cntr_rst) begin
		cntr <= 0;
		counter <= 0;
		
	end
		
	else begin
	
		cntr = cntr + 1;
		
		if (cntr == 32'd60) begin
		
			cntr <= 0;
			counter <= counter + 1;
			
	   end
		
	end

end

always_comb begin

	Next_state = State;
	
	LD_MENU  = 1'b0;
	LD_Map1  = 1'b0;
	Pause_En = 1'b0;
	LD_S1ENDGAME = 1'b0;
	LD_S2ENDGAME = 1'b0;
	offset = 3'b000;
	AnimationActive = 1'b0;
	offset1 = 3'b000;
	AnimationActive1 = 1'b0;
	cntr_rst = 1'b0;
	
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
			
				Next_state = V1;
			
			end
			
			else if (player2wins) begin
			
				Next_state = V11;
			
			end
		
			else Next_state <= Play_M1;
			
		end
		
		
		// Snake 2 Dying animation
		
		V1: Next_state = V2;
		
		V2: Next_state = V3;
		
		V3: Next_state = V4;
		
		V4: Next_state = V5;
		
		V5: Next_state = V3_1;
		
		V3_1: Next_state = V4_1;
		
		V4_1: Next_state = V6;
		
		V6: Next_state = V7;
		
		V7: begin
		
			if (counter == 32'd1) Next_state = Snake1wins;
			
		end
		
		
		// Snake 1 Dying animation
		
		V11: Next_state = V21;
		
		V21: Next_state = V31;
		
		V31: Next_state = V41;
		
		V41: Next_state = V51;
		
		V51: Next_state = V3_11;
		
		V3_11: Next_state = V4_11;
		
		V4_11: Next_state = V61;
		
		V61: Next_state = V71;
		
		V71: begin
		
			if (counter == 32'd1) Next_state = Snake2wins;
			
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
		
		V1: begin
			offset = 3'b000;
			AnimationActive = 1'b1;
			LD_Map1 = 1'b1;
		end
	
		V2: begin
			offset = 3'b001;
			AnimationActive = 1'b1;
			LD_Map1 = 1'b1;
		end
		
		
		V3, V3_1: begin
			offset = 3'b010;
			AnimationActive = 1'b1;
			LD_Map1 = 1'b1;	
		end

		V4, V4_1: begin	
			offset = 3'b011;
			AnimationActive = 1'b1;
			LD_Map1 = 1'b1;
		end
		
		V5: begin
			offset = 3'b100;
			AnimationActive = 1'b1;
			LD_Map1 = 1'b1;
		end
		V6: begin
			offset = 3'b101;
			AnimationActive = 1'b1;
			LD_Map1 = 1'b1;
			cntr_rst = 1'b1;
		end
		
		V7: begin
			offset = 3'b110;
			AnimationActive = 1'b1;
			LD_Map1 = 1'b1;
		end
		
		V11: begin
			offset1 = 3'b000;
			AnimationActive1 = 1'b1;
			LD_Map1 = 1'b1;
		end
	
		V21: begin
			offset1 = 3'b001;
			AnimationActive1 = 1'b1;
			LD_Map1 = 1'b1;
		end
		
		
		V31, V3_11: begin
			offset1 = 3'b010;
			AnimationActive1 = 1'b1;
			LD_Map1 = 1'b1;	
		end

		V41, V4_11: begin	
			offset1 = 3'b011;
			AnimationActive1 = 1'b1;
			LD_Map1 = 1'b1;
		end
		
		V51: begin
			offset1 = 3'b100;
			AnimationActive1 = 1'b1;
			LD_Map1 = 1'b1;
		end
		V61: begin
			offset1 = 3'b101;
			AnimationActive1 = 1'b1;
			LD_Map1 = 1'b1;
			cntr_rst = 1'b1;
		end
		
		V71: begin
			offset1 = 3'b110;
			AnimationActive1 = 1'b1;
			LD_Map1 = 1'b1;
		end
				
		Snake1wins	: LD_S1ENDGAME = 1'b1;
		Snake2wins	: LD_S2ENDGAME = 1'b1;
		
		default: ;
		
	endcase
		
end


endmodule
