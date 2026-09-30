`timescale 1ns/1ps
module tb_top;
  reg clk=0, rstn=0;
  always #5 clk = ~clk; // 100 MHz

  reg psel=0, penable=0, pwrite=0;
  reg [7:0] paddr=0;
  reg [31:0] pwdata=0;
  wire [31:0] prdata;
  wire pready;

  wire s_cs, s_we;
  wire [7:0]  s_addr;
  wire [31:0] s_din, s_dout;

  mem_ctrl dut (
    .clk(clk), .rstn(rstn),
    .psel(psel), .penable(penable), .pwrite(pwrite),
    .paddr(paddr), .pwdata(pwdata),
    .prdata(prdata), .pready(pready),
    .s_cs(s_cs), .s_we(s_we), .s_addr(s_addr),
    .s_din(s_din), .s_dout(s_dout)
  );

  sram_behav sram (
    .clk(clk), .cs(s_cs), .we(s_we),
    .addr(s_addr), .din(s_din), .dout(s_dout)
  );

  task apb_write(input [7:0] addr, input [31:0] data);
  begin
    @(negedge clk);
    psel=1; penable=1; pwrite=1; paddr=addr; pwdata=data;
    @(negedge clk);
    while (!pready) @(negedge clk);
    psel=0; penable=0; pwrite=0;
  end
  endtask

  task apb_read(input [7:0] addr, output [31:0] data);
  begin
    @(negedge clk);
    psel=1; penable=1; pwrite=0; paddr=addr;
    @(negedge clk);
    while (!pready) @(negedge clk);
    data = prdata;
    psel=0; penable=0;
  end
  endtask

  integer i;
  reg [31:0] rd;
  initial begin
    $dumpfile("out/dump.vcd");
    $dumpvars(0, tb_top);
    #20 rstn=1;
    for (i=0;i<4;i=i+1) apb_write(i[7:0], 32'hA5A50000 + i);
    for (i=0;i<4;i=i+1) begin
      apb_read(i[7:0], rd);
      if (rd !== (32'hA5A50000 + i)) $display("MISMATCH %0d exp=%h got=%h", i, (32'hA5A50000 + i), rd);
      else $display("OK %0d = %h", i, rd);
    end
    #50 $finish;
  end
endmodule
