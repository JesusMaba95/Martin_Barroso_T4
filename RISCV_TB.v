/******************************************************************
* Description
*	Tb for RISCV 
* This ALU is written by using behavioral description.
* Version:
*	1.0
* Author:
*	Jesus MArtin Barroso
* email:
*	jesus.martin@iteso.mx
* Date:
*	27/02/2021

******************************************************************/

module RISCV_TB;
reg clk = 0;
reg rst = 1;
reg [31:0] gpio_in  = 32'h0000_0001;
wire [7:0]gpio_out;
  
RISCV
DUT
(
	.clk(clk),
	.reset(rst),
	.gpio_port_in(gpio_in),
	.gpio_port_out(gpio_out)


);
/*********************************************************/
initial // Clock generator
  begin
    forever #2 clk = !clk;
  end
/*********************************************************/
initial begin // reset generator
	#5 rst = 0;
	#5 rst = 1;
end


endmodule