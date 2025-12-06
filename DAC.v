
module DAC (
    input  wire clk,    // 50 MHZ FPGA CLOCK
    input  wire reset,
    input  wire spi_miso,   // MASTER IN, SLAVE OUT   
    
    input  wire [11:0] data,    // DIGITAL TO BE GIVEN TO DAC MODULE
    input  wire [03:0] address, // DAC ADDRESS FOR A, B, C, D PIN
    input  wire [03:0] command,  // COMMAND = 4'B0011
    
    output reg  send,
    output reg  dac_cs, spi_sck, spi_mosi, dac_clr,  // SIGNAL ON DAC
    // PERIPHERALS SIGNALS TO BE DISABLED
    output wire SPI_SS_B, AMP_CS, AD_CONV, SF_CE0, FPGA_INIT_B
);

// INTERNAL REGISTERS
reg [02:0] dac_state;   // DAC STATES
// DAC INPUT = {8'b(dont_care), 4'b(command), 4'b(address), 12'b(data), 4'b(dont_care)}
reg [31:0] dac_out; 
reg [05:0] count = 32;

assign SPI_SS_B = 1;    // SPI FLASH
assign AMP_CS = 1;  // AMPLIFIER SELECT
assign AD_CONV = 0; // ADC CONVERSION
assign SF_CE0 = 1;  // STRATA FLASH
assign FPGA_INIT_B = 1; // PLATFORM FLASH

always @ (posedge clk or posedge reset) begin
    if (reset == 1) begin
        dac_cs <= 1;
        spi_sck <= 0;
        spi_mosi <= 0;
        dac_clr <= 1;
        send <= 0;
        dac_state <= 0;
    end
    else begin
        case (dac_state)
            0: begin // IDLE
               dac_cs <= 1;
               spi_sck <= 0;
               spi_mosi <= 0;
               dac_clr <= 1;
               send <= 0;
               // count <= 32;
               dac_state <= dac_state + 1;
            end
            
            1: begin // 32 BIT ASSIGNING TO DAC
                dac_out <= {8'hxx, command, address, data, 4'hx};
                dac_state <= dac_state + 1;
            end
            
            2: begin // BIT ASSIGNING ON SPI_MOSI LINE
                dac_cs <= 0;  // FPGA TRANSMITS DATA ON MOSI LINE WHEN DAC_CS <= 0;
                spi_sck <= 0;
                // ASSIGNING DIGITAL BIT TO MOSI LINE, STARTING FROM MSB
                spi_mosi <= dac_out[count - 1];
                count <= count - 1;
                dac_state <= dac_state + 1;
            end
            
            3: begin    // WAITING FOR COMPLETE 32 BIT INPUT TO MOSI
                if (count > 0) begin
                    spi_sck <= 1;
                    dac_state <= 2;
                end
                else begin
                    spi_sck <= 1;
                    dac_state <= dac_state + 1;
                end
            end
            
            4: begin
                spi_sck <= 0;
                dac_state <= dac_state + 1;
            end
            
            5: begin
                dac_cs <= 1; // ANALOG CONVERSION STARTS, WHEN DAC_CS<=1 
                            // AFTER ASSIGNING 32 BIT TO MOSI LINE
                dac_state <= dac_state + 1;
            end
            
            6: begin
                send <= 1;
                dac_state <= dac_state + 1;
            end
            
            7: begin
                send <= 0;
                dac_state <= 1;
            end
            
            default: begin
                dac_cs <= 1;
                spi_mosi <= 0;
                spi_sck <= 0;
                dac_clr <= 1;
                send <= 0;
                dac_state <= 0;
                count <= 32;
            end
        endcase
    end
end

endmodule