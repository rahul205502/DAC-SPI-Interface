`timescale 1ns / 1ps

module DAC_tb;

reg  clk;
reg  reset;
reg spi_miso;

reg  [11:0] data;
reg  [03:0] address;
reg  [03:0] command;

wire send;
wire dac_cs, spi_sck, spi_mosi, dac_clr;

wire SPI_SS_B, AMP_CS, AD_CONV, SF_CE0, FPGA_INIT_B;

parameter CLK_PERIOD = 20; 
// 1/50MHz = 1/(50 x 10^6) Hz = 20 x 10^(-9) sec = 20 ns
always #(CLK_PERIOD / 2) clk = ~clk;

DAC dut (
    .clk (clk),
    .reset (reset),
    .spi_miso (spi_miso),
    
    .data (data),
    .address (address),
    .command (command),
    
    .send (send),
    .dac_cs (dac_cs),
    .spi_sck (spi_sck),
    .spi_mosi (spi_mosi),
    .dac_clr (dac_clr),
    
    .SPI_SS_B (SPI_SS_B),
    .AMP_CS (AMP_CS),
    .AD_CONV (AD_CONV),
    .SF_CE0 (SF_CE0),
    .FPGA_INIT_B (FPGA_INIT_B)
);

initial begin
    clk = 0;
    reset = 1;
    spi_miso = 0; // miso is not used here
    data = 12'hABC;
    address = 4'h0;
    command = 4'h3;
    
    #(CLK_PERIOD * 2) reset = 0;
    
    $display("====== Starting DAC SPI Transaction at time: %0t ======", $time);
    #1330;
    $display("====== DAC SPI Transaction finished at time: %0t ======", $time);
    
    $finish;
end

initial begin
$monitor("Time: %0t, State: %0d, CS: %0d, SCK: %0d, MOSI: %0b, send: %0b, Count: %0d",
          $time, dut.dac_state, dac_cs, spi_sck, spi_mosi, send, dut.count);
end

endmodule