module venomCountMachine(input logic Clk,
									input logic Reset,
									input logic [15:0] keycode,
									input logic [7:0] expectedKeycode,
									output logic [1:0] venomCount);
				 
				 
enum logic [3:0] {Halted, 
						Venom1,
						Venom2,
						Venom3,
						Wait_state1,
						Wait_state2,
						Wait_state3,
						Reload_Venom} State, Next_state;
						
						
logic bulletDirLatch;

always_ff @ (posedge Clk) begin

	if (Reset)
		State <= Halted;
	else
		State <= Next_state;
	
end

always_comb begin

	Next_state = State;
	
	venomCount = 2'b00;
	
	unique case (State)
	
		Halted: Next_state = Venom1;
		
		Venom1: begin
		
				if (keycode[15:8] == expectedKeycode  || keycode[7:0] == expectedKeycode ) begin
				
					Next_state = Wait_state1;
					
				end
				
				else Next_state = Venom1;
		end
		
		Wait_state1: begin
		
				if (keycode[15:8] == expectedKeycode  || keycode[7:0] == expectedKeycode ) begin
						
					Next_state = Wait_state1;
							
				end
				
				else Next_state = Venom2;
		
		end
		
		Venom2: begin
		
				if (keycode[15:8] == expectedKeycode  || keycode[7:0] == expectedKeycode ) begin
				
					Next_state = Wait_state2;
					
				end
				
				else Next_state = Venom2;
				
		end
		
		Wait_state2: begin
		
				if (keycode[15:8] == expectedKeycode  || keycode[7:0] == expectedKeycode ) begin
						
					Next_state = Wait_state2;
							
				end
				
				else Next_state = Venom3;
		
		end
		
		Venom3: begin
		
				if (keycode[15:8] == expectedKeycode  || keycode[7:0] == expectedKeycode ) begin
				
					Next_state = Wait_state3;
					
				end
				
				else Next_state = Venom3;
		end
				
		
		Wait_state3: begin
		
				if (keycode[15:8] == expectedKeycode  || keycode[7:0] == expectedKeycode ) begin
						
					Next_state = Wait_state3;
							
				end
				
				else Next_state = Reload_Venom;
		
		end
		
		Reload_Venom: Next_state = Reload_Venom;
				
		
		default: ;
	
	endcase
	
	
	case (State)
	
		Halted: ;
		
		Venom1		:	venomCount = 2'b00;
		Wait_state1 :	venomCount = 2'b00;
		Venom2		:	venomCount = 2'b01;
		Wait_state2 :	venomCount = 2'b01;
		Venom3		:	venomCount = 2'b10;
		Wait_state3 :	venomCount = 2'b10;
		Reload_Venom:  venomCount = 2'b11;
		
		default: ;
		
	endcase
		
end


endmodule
