module WinnerP2_rom (
	input logic clock,
	input logic [14:0] address,
	output logic [2:0] q
);

logic [2:0] memory [0:19199] /* synthesis ram_init_file = "./WinnerP2/WinnerP2.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
