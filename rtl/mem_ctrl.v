module mem_ctrl #(
  parameter ADDR_W = 8,
  parameter DATA_W = 32
)(
  input  wire              clk,
  input  wire              rstn,
  // APB-lite style
  input  wire              psel,
  input  wire              penable,
  input  wire              pwrite,
  input  wire [ADDR_W-1:0] paddr,
  input  wire [DATA_W-1:0] pwdata,
  output reg  [DATA_W-1:0] prdata,
  output reg               pready,
  // SRAM side
  output reg               s_cs,
  output reg               s_we,
  output reg  [ADDR_W-1:0] s_addr,
  output reg  [DATA_W-1:0] s_din,
  input  wire [DATA_W-1:0] s_dout
);

  reg pending; // đánh dấu có request cần trả lời ở chu kỳ kế tiếp

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      pready  <= 1'b0;
      prdata  <= '0;
      s_cs    <= 1'b0;
      s_we    <= 1'b0;
      s_addr  <= '0;
      s_din   <= '0;
      pending <= 1'b0;
    end else begin
      pready  <= pending;   // trả lời sau 1 chu kỳ
      if (pending) begin
        prdata <= s_dout;   // s_dout đã ổn định sau khi s_addr set ở chu kỳ trước
      end
      pending <= 1'b0;
      s_cs    <= 1'b0;
      s_we    <= 1'b0;

      if (psel && penable) begin
        s_cs    <= 1'b1;
        s_we    <= pwrite;
        s_addr  <= paddr;
        s_din   <= pwdata;
        pending <= 1'b1;   // sẽ pready ở chu kỳ kế
      end
    end
  end
endmodule
