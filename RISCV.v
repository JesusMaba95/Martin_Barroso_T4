/******************************************************************
* Description
*	RISCV TOP MODULE
* Author:
*	Jesus Martin Barroso
* email:
*	jesus.martin@iteso.mx
* Date:
*	20/02/2021
******************************************************************/

module RISCV
#(
	parameter MEMORY_DEPTH = 32,
	parameter PC_INCREMENT = 4,
	parameter DATA_WIDTH = 32
)
(
	input clk,
	input reset,
	output [7:0]gpio_port_in,
	output [7:0]gpio_port_out
);
wire [31:0]PC_w;
wire [31:0]OldPC_w;
wire [31:0]Addr_w;
wire [31:0]ReadData_w;
wire [31:0]ReadData_w2;
wire [31:0]Instruction_w;
wire [31:0]ReadReg1_Data_ff_w;
wire [31:0]ReadReg2_Data_ff_w;
wire [31:0]ReadReg1_Data_w;
wire [31:0]ReadReg2_Data_w;
wire [31:0]SrcA_w;
wire [31:0]SrcB_w;
wire PC_WR_w;
wire AdrSrc_w;
wire MemWr_w;
wire IRWr_w;
wire RegW_w;

PC_Register
ProgramCounter
(
	//.clk(clk),
	//.reset(reset),
	//.enable(PC_WR_w),
	//.NewPC(),
	.PCValue(PC_w)
);

Mux_2_1 Mux_AdrSrc
(
	//.sel(AdrSrc_w),
	.In0(PC_w),
	//.In1(),
	.Output(Addr_w)

);

Instruction_Data_Memory
#(
	.INSTRUCTION_MEMORY_DEPTH(32),
	.DATA_MEMORY_DEPTH(32),
	.DATA_WIDTH(32)
)
IDMem
(
	.Address(Addr_w),
	//.WriteData,
	//.MemWrite(MemWr_w),
	//.clk(clk),
	.ReadData(ReadData_w)
);
Register OldPc
(
  //.clk(clk),
  //.reset(reset),
  //.enable(IRWr_w),
  .DataInput(PC_w),
  .DataOutput(OldPC_w)
  
);
Register Instruction
(
  //.clk(clk),
  //.reset(reset),
  //.enable(IRWr_w),
  .DataInput(ReadData_w),
  .DataOutput(Instruction_w)
  
);

Register Data
(
  .clk(clk),
  //.reset(reset),
  //.enable(1'b1),
  .DataInput(ReadData_w),
  .DataOutput(ReadData_w2)
  
);
RegisterFile
#(
   .N(DATA_WIDTH)
) FILE
(
	//.clk(clk),
	//.reset(rst),
	.RegWrite(RegW_w),
	.WriteRegister(Instruction_w[11:7]),
	.ReadRegister1(Instruction_w[19:15]),
	.ReadRegister2(Instruction_w[24:20]),
	//.WriteData(),	
	.ReadData1(ReadReg1_Data_w),
	.ReadData2(ReadReg2_Data_w)

);
Register Rd_Reg_Data1
(
  //.clk(clk),
  //.reset(reset),
  //.enable(1'b1),
  .DataInput(ReadReg1_Data_w),
  .DataOutput(ReadReg1_Data_ff_w)
  
);
Register Rd_Reg_Data2
(
  //.clk(clk),
  //.reset(reset),
  //.enable(1'b1),
  .DataInput(ReadReg2_Data_w),
  .DataOutput(ReadReg2_Data_ff_w)
  
);
Mux_3_1 Mux_SrcA
(
	//.sel(AdrSrc_w),
	.In0(PC_w),
	.In1(OldPC_w),
	.In2(ReadReg1_Data_ff_w),
	.Output(SrcA_w)
);
endmodule