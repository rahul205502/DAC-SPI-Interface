
# 🚀 Verilog DAC SPI Master Controller

This repository contains the Verilog Hardware Description Language (HDL) implementation of a **Serial Peripheral Interface (SPI) Master controller** specifically designed to interface with an external **Digital-to-Analog Converter (DAC)** device.

The module acts as the SPI Master for the DAC device and is built around a standard **Finite State Machine (FSM)** approach to manage the timing and control signals necessary for a 32-bit serial data transfer.

---

## ✨ Features and Design Highlights

* **SPI Master Implementation:** The DAC module acts as the SPI Master, generating the clock (`spi_sck`) and controlling the Chip Select (`dac_cs`).
* **32-Bit Transaction Framing:** It serializes a parallel 12-bit digital data value, along with necessary command and address information, into a **32-bit serial stream**.
* **SPI Mode 0 Support:** The clock operates in **SPI Mode 0** ($CPOL=0$, $CPHA=0$). Data is sampled on the **rising edge** of the clock. 

[Image of SPI Mode 0 timing diagram]

* **MSB First Transmission:** Data is transmitted **Most Significant Bit (MSB) first**.
* **FSM Control:** A 3-bit state register (`dac_state`) governs the transaction sequence.

---

## 🏗️ Project Structure

| File | Description |
| :--- | :--- |
| `DAC.v` | The main Verilog module containing the DAC SPI Master FSM logic. |
| `DAC_tb.v` | The Verilog testbench used for simulation and verification of the `DAC.v` module. |

---

## 📌 Module Interface

The primary ports of the `DAC.v` module are defined below:

| Port Name | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | Input | 1 | FPGA 50 MHz clock. |
| `reset` | Input | 1 | Asynchronous reset, active high. |
| `data` | Input | 12 | 12-bit digital value for the DAC output. |
| `address` | Input | 4 | DAC channel address (A, B, C, D). |
| `command` | Input | 4 | DAC command (e.g., $4^{\prime}h3$ for write). |
| `dac_cs` | Output | 1 | Chip Select (Active Low) for the DAC. |
| `spi_sck` | Output | 1 | SPI Serial Clock. |
| `spi_mosi` | Output | 1 | SPI Master Out, Slave In data line. |
| `send` | Output | 1 | Status flag, pulsed high when transaction completes. |

---

## ⚙️ 32-Bit Transaction Structure

The total 32-bit word (`dac_out`) transmitted to the DAC is structured as follows:

$$\text{DAC Transaction} = \{ \text{8 bits (Don't Care)}, \text{4 bits (Command)}, \text{4 bits (Address)}, \text{12 bits (Data)}, \text{4 bits (Don't Care)} \}$$

The corresponding Verilog assignment in State 1 (**32 BIT ASSIGN**) is:

```verilog
dac_out <= {8'hxx, command, address, data, 4'hx};
