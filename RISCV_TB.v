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
reg rst = 0;

  
RISCV
DUT
(
	.clk(clk),
	.reset(rst)


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