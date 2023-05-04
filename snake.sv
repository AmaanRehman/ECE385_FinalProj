//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  snake ( input Reset, frame_clk,
				input [15:0] keycode,
				input [8:0] x_velocity, y_velocity,
               	output [9:0]  BallX, BallY, BallS,
				
				// Motion Flag
				input [1:0] motionFlag,

				// Obstacle Input
				input logic OB1Flag,
				output logic [9:0] LEDR);
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 
    parameter [9:0] Ball_X_Center=220;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    assign Ball_Size = 12;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
        end
           
        else 
        begin 
				 if ( (Ball_Y_Pos + Ball_Size) >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
					  Ball_Y_Motion <= (~ (Ball_Y_Step) + 1'b1);  // 2's complement.
					  
				 else if ( (Ball_Y_Pos - Ball_Size) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
					  Ball_Y_Motion <= Ball_Y_Step;
					  
				  else if ( (Ball_X_Pos + Ball_Size) >= Ball_X_Max )  // Ball is at the Right edge, BOUNCE!
					  Ball_X_Motion <= (~ (Ball_X_Step) + 1'b1);  // 2's complement.
					  
				 else if ( (Ball_X_Pos - Ball_Size) <= Ball_X_Min )  // Ball is at the Left edge, BOUNCE!
					  Ball_X_Motion <= Ball_X_Step;
					  
				 else begin // EDIT #1: 'begin' added
					  Ball_Y_Motion <= Ball_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
					  
//				 if (!OB1Flag) begin
				 case (keycode[7:0])
					8'h04 : begin
//							if ((Ball_X_Pos <= Ball_X_Min) || OB1Flag == 1'b1) Ball_X_Motion <= 0;

//							else begin
								Ball_X_Motion <= -1;//A
								Ball_Y_Motion<= 0;
//							end
					end
					        
					8'h07 : begin
//							if ((Ball_X_Pos + Ball_Size >= Ball_X_Max) || OB1Flag == 1'b1) Ball_X_Motion <= 0;	

//							else begin
					        	Ball_X_Motion <= 1;//D
							  	Ball_Y_Motion <= 0;
//							end
					end

					8'h16 : begin
//							if ((Ball_Y_Pos + Ball_Size >= Ball_X_Max) || OB1Flag == 1'b1) Ball_Y_Motion <= 0;

//							else begin			
								Ball_Y_Motion <= 1;//S
							  	Ball_X_Motion <= 0;
//							end
					end
							  
					8'h1A : begin
//							if ((Ball_Y_Pos <= Ball_Y_Min) || OB1Flag == 1'b1) Ball_Y_Motion <= 0;
					        
//							else begin
								Ball_Y_Motion <= -1;//W
							 	Ball_X_Motion <= 0;
//							 end	  
					end
					default: begin
//							Ball_Y_Motion <= 0;
//							Ball_X_Motion <= 0;

//						if (OB1Flag == 1'b1) begin
//							Ball_X_Motion <= 0;
//							Ball_Y_Motion <= 0;
//						end
//						
//						else begin
//						
//							Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
//							Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
//						
//						end
					
					end
			   endcase
				
				case (keycode[15:8])
					8'h04 : begin
//							if ((Ball_X_Pos <= Ball_X_Min) || OB1Flag == 1'b1) Ball_X_Motion <= 0;

//							else begin
								Ball_X_Motion <= -1;//A
								Ball_Y_Motion<= 0;
//							end
					end
					        
					8'h07 : begin
//							if ((Ball_X_Pos + Ball_Size >= Ball_X_Max) || OB1Flag == 1'b1) Ball_X_Motion <= 0;	

//							else begin
					        	Ball_X_Motion <= 1;//D
							  	Ball_Y_Motion <= 0;
//							end
					end

					8'h16 : begin
//							if ((Ball_Y_Pos + Ball_Size >= Ball_X_Max) || OB1Flag == 1'b1) Ball_Y_Motion <= 0;

//							else begin			
								Ball_Y_Motion <= 1;//S
							  	Ball_X_Motion <= 0;
//							end
					end
							  
					8'h1A : begin
//							if ((Ball_Y_Pos <= Ball_Y_Min) || OB1Flag == 1'b1) Ball_Y_Motion <= 0;
					        
//							else begin
								Ball_Y_Motion <= -1;//W
							 	Ball_X_Motion <= 0;
//							 end	  
					end
					default: begin
//							Ball_Y_Motion <= 0;
//							Ball_X_Motion <= 0;

//						if (OB1Flag == 1'b1) begin
//							Ball_X_Motion <= 0;
//							Ball_Y_Motion <= 0;
//						end
						
//						else begin
//						
//							Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
//							Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
//						
//						end
					
					end
			   endcase

//				 end
//
//				 else begin 
//					Ball_X_Motion <= 0;
//					Ball_Y_Motion <= 0;
//				 end
				
				end // EDIT #2: 'end' added
				

				if(x_velocity[8])
				begin 
					LEDR[0] = 1; 
				end 
				else 
				if(y_velocity[8])
				begin 
					LEDR[1] = 1; 
				end 
				
				LEDR[2] <= OB1Flag;

				if (!OB1Flag) begin
					Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
					Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
				end
				
				else begin
				
					case (motionFlag) 
					
						2'b00: begin		// W
							
							Ball_Y_Pos <= (Ball_Y_Pos + 1);  // Keep ball position
							Ball_X_Pos <= (Ball_X_Pos + 0);
							
						end
						
						2'b01: begin
						
							Ball_Y_Pos <= (Ball_Y_Pos + 0);
						   Ball_X_Pos <= (Ball_X_Pos + 1);
							
						end
						
						2'b10: begin
						
							Ball_Y_Pos <= (Ball_Y_Pos - 1);
						   Ball_X_Pos <= (Ball_X_Pos + 0);
							
						end
						
						2'b11: begin
						
							Ball_Y_Pos <= (Ball_Y_Pos + 0);
						   Ball_X_Pos <= (Ball_X_Pos - 1);
							
						end
					endcase
//						

//					Ball_Y_Pos <= (Ball_Y_Pos + 0);  // Keep ball position
//					Ball_X_Pos <= (Ball_X_Pos + 0);
				end

			end
		end  
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
    

endmodule
