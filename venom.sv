module  venom ( input Reset, frame_clk, vga_clk,
					input [15:0] keycode,
					input [7:0] expectedKeycode,
					input [9:0] snakeX, snakeY,
					input [1:0] venomCount, venomCountState,
					input [1:0] motionFlag,
					input logic collision,
					input logic venom_on,
					output logic venomMovement,
               output [9:0]  VenomX, VenomY, VenomS,
					output [2:0] LED
				);
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    assign Ball_Size = 4;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 
	 logic [1:0] bulletDir;
	 logic setBulletDir;
	 
//	 reg_unit #(2) bulletDirection(
//					.Clk(Clk),
//					.Reset(Reset),							/// Might have to change this to game reset
//					.Din(motionFlag),
//					.Load(setBulletDir),
//					.Data_Out(bulletDir));
					

	venom_stateMachine (.Clk(vga_clk),
							  .Reset(Reset),
							  .keycode(keycode),
							  .expectedKeycode(expectedKeycode),
							  .collision(collision),
							  .motionFlag(motionFlag),
							  .bulletDir(bulletDir),
							  .venomMovement(venomMovement),
							  .venomCount(venomCount),
							  .venomCountState(venomCountState));

	
	assign LED[2] = venomMovement;
//	assign LED[1:0] = bulletDir;

   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball    
		  
		  if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= snakeY;
				Ball_X_Pos <= snakeX;
        end
           
        else if (venomMovement == 1'b1)
        begin 
				
					case (bulletDir) 
					
						2'b00: begin		// W
							
							   Ball_Y_Motion <= -3;
							   Ball_X_Motion <= 0;
							  
							   Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
								Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
							
						end
						
						2'b01: begin		// A
						
							
								Ball_X_Motion <= -3;
								Ball_Y_Motion<= 0;
								
								Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
								Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
								
//								LED[2] <= 1'b1;
							
						end
						
						2'b10: begin		// S
						
								Ball_Y_Motion <= 3;
								Ball_X_Motion <= 0;
								
								Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
								Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
							
						end
						
						2'b11: begin		// D
						
								Ball_X_Motion <= 3;
								Ball_Y_Motion <= 0;
								
								Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
								Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
							
						end
						
						default: begin
						
							Ball_Y_Pos <= snakeY;
							Ball_X_Pos <= snakeX;
//							LED[2] <= 1'b0;
						end
						
					endcase
					
					if (venomMovement) begin
					
					end
				
			end
				
			else begin
					Ball_Y_Pos <= snakeY;  // Update ball position
					Ball_X_Pos <= snakeX;
			end
				
   
		end  

       
    assign VenomX = Ball_X_Pos;
   
    assign VenomY = Ball_Y_Pos;
   
    assign VenomS = Ball_Size;
    

endmodule
