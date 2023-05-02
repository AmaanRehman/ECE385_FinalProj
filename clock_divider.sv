module clock_divider(
  input logic Clk,
  input logic reset,
  output logic ClkOut
);

logic [24:0] counter = 25'd0; // 4-bit counter for dividing clock by 16

always_ff @(posedge Clk)
begin
  if (reset)
    counter <= 4'd0;
	 
  else if (counter == 24'd25) // divide by 16
    counter <= 4'd0;
  else
    counter <= counter + 1;
end

assign ClkOut = counter == 4'd0 ? 1'b1 : 1'b0; // Output clock is high for 1 out of 16 cycles

endmodule