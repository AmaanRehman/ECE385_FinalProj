module down_head_p2_rom (
	input logic clock,
	input logic [9:0] address,
	output logic [2:0] q
);

logic [2:0] memory [0:575] /* synthesis ram_init_file = "./down_head_p2/down_head_p2.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
