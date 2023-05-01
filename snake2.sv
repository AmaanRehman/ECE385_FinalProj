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


module  snake2 ( input Reset, frame_clk,
					input [15:0] keycode,
					input [8:0] x_velocity, y_velocity,
               output [9:0]  BallX, BallY, BallS,
					
					// Motion Flag
					input [1:0] motionFlag,
					input logic OB2Flag,
					output logic [9:0] LEDR);
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 
    parameter [9:0] Ball_X_Center=420;  // Center position on the X axis
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
					  
				 
				 case (keycode[7:0])
					8'h50 : begin

								Ball_X_Motion <= -1;//A
								Ball_Y_Motion<= 0;
							  end
					        
					8'h4f : begin
								
					        Ball_X_Motion <= 1;//D
							  Ball_Y_Motion <= 0;
							  end

							  
					8'h51 : begin

					        Ball_Y_Motion <= 1;//S
							  Ball_X_Motion <= 0;
							 end
							  
					8'h52 : begin
					
							  Ball_Y_Motion <= -1;//W
							  Ball_X_Motion <= 0;
					        
							 end	  
					default: ;
			   endcase
				
				
				case (keycode[15:8])
					8'h50 : begin

								Ball_X_Motion <= -1;//A
								Ball_Y_Motion<= 0;
							  end
					        
					8'h4f : begin
								
					        Ball_X_Motion <= 1;//D
							  Ball_Y_Motion <= 0;
							  end

							  
					8'h51 : begin

					        Ball_Y_Motion <= 1;//S
							  Ball_X_Motion <= 0;
							 end
							  
					8'h52 : begin
					        Ball_Y_Motion <= -1;//W
							  Ball_X_Motion <= 0;
							 end	  
					default: ;
			   endcase
				
				
				
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
				
				if (!OB2Flag) begin

					Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
					Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
				end
				
				else begin
				
					case (motionFlag) 
					
						2'b00: begin		// W
							
							Ball_Y_Pos <= (Ball_Y_Pos + 1);  // Keep ball position
							Ball_X_Pos <= (Ball_X_Pos + 0);
							
						end
						
						2'b01: begin		// A
						
							Ball_Y_Pos <= (Ball_Y_Pos + 0);
						   Ball_X_Pos <= (Ball_X_Pos + 1);
							
						end
						
						2'b10: begin		// S
						
							Ball_Y_Pos <= (Ball_Y_Pos - 1);
						   Ball_X_Pos <= (Ball_X_Pos + 0);
							
						end
						
						2'b11: begin		// D
						
							Ball_Y_Pos <= (Ball_Y_Pos + 0);
						   Ball_X_Pos <= (Ball_X_Pos - 1);
							
						end
					endcase
				end
		end  
    end
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
    

endmodule
