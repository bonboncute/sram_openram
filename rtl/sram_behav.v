module sram_behav #(
  parameter ADDR_W = 8,   // 256 words
  parameter DATA_W = 32
)(
  input  wire              clk,
  input  wire              cs,   // active high
  input  wire              we,   // 1=write, 0=read
  input  wire [ADDR_W-1:0] addr,
  input  wire [DATA_W-1:0] din,
  output wire [DATA_W-1:0] dout
);
  reg [DATA_W-1:0] mem [0:(1<<ADDR_W)-1];

  // Ghi đồng bộ
  always @(posedge clk) begin
    if (cs && we) mem[addr] <= din;
  end

  // Đọc bất đồng bộ, không gate cs để tránh thấy 0
  assign dout = mem[addr];

endmodule
