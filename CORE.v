module CORE
#(
	parameter MEMORY_DEPTH = 32,
	parameter PC_INCREMENT = 4,
	parameter DATA_WIDTH = 32
)
(

	input        clk,
	input        reset,
	input[(DATA_WIDTH-1):0]  ReadData_i,
	output[(DATA_WIDTH-1):0] Address_o,
	output[(DATA_WIDTH-1):0] WriteData_o,
	output       MemWrite_o
);
wire [(DATA_WIDTH-1):0]PC_w;
wire [(DATA_WIDTH-1):0]OldPC_w;
//wire [31:0]Addr_w;
//wire [31:0]ReadData_w;
wire [(DATA_WIDTH-1):0]ReadData_w2;
wire [(DATA_WIDTH-1):0]Instruction_w;
wire [(DATA_WIDTH-1):0]ReadReg1_Data_ff_w;
//wire [31:0]ReadReg2_Data_ff_w;
wire [(DATA_WIDTH-1):0]ReadReg1_Data_w;
wire [(DATA_WIDTH-1):0]ReadReg2_Data_w;
wire [(DATA_WIDTH-1):0]SrcA_w;
wire [(DATA_WIDTH-1):0]SrcB_w;
wire [(DATA_WIDTH-1):0]imm_w;
wire [(DATA_WIDTH-1):0]ALUResult_w;
wire [(DATA_WIDTH-1):0]ALUResult_ff_w;
wire [(DATA_WIDTH-1):0]MuxResult_w;
wire [2:0] ImmSel_w;
wire [2:0] ALUCtrl_w;
wire [1:0] ALUsrcA_w;
wire [1:0] ALUsrcB_w;
wire [1:0]ResultSrc_w;
wire Branch_w;
wire PC_WR_w;
wire AdrSrc_w;
wire IRWr_w;
wire zero_w;
wire PCWR_w;
wire AdrSrc_sel_w;
//wire MemWrite_o;
wire IRWrite_w;
wire RegWrite_w;

PC_Register
ProgramCounter
(
	.clk(clk),
	.reset(reset),
	.enable(PCWR_w || Branch_w),
	.NewPC(MuxResult_w),
	.PCValue(PC_w)
);

Mux_2_1 Mux_AdrSrc
(
	.sel(AdrSrc_sel_w),
	.In0(PC_w),
	.In1(MuxResult_w),
	.Output(Address_o)

);

//Instruction_Data_Memory
//IDMem
//(
	//.Address(Address),
	//.WriteData(ReadReg2_Data_ff_w),
	//.MemWrite(MemWrite_w),
	//.clk(clk),
	//.ReadData(ReadData_w)
//);
Register OldPc
(
  .clk(clk),
  .reset(reset),
  .enable(IRWrite_w),
  .DataInput(PC_w),
  .DataOutput(OldPC_w)
  
);
Register Instruction
(
  .clk(clk),
  .reset(reset),
  .enable(IRWrite_w),
  .DataInput(ReadData_i),
  .DataOutput(Instruction_w)
  
);

Register Data
(
  .clk(clk),
  .reset(reset),
  .enable(1'b1),
  .DataInput(ReadData_i),
  .DataOutput(ReadData_w2)
  
);
RegisterFile
#(
   .N(DATA_WIDTH)
) FILE
(
	.clk(clk),
	.reset(reset),
	.RegWrite(RegWrite_w),
	.WriteRegister(Instruction_w[11:7]),
	.ReadRegister1(Instruction_w[19:15]),
	.ReadRegister2(Instruction_w[24:20]),
	.WriteData(MuxResult_w),	
	.ReadData1(ReadReg1_Data_w),
	.ReadData2(ReadReg2_Data_w)

);
Register Rd_Reg_Data1
(
  .clk(clk),
  .reset(reset),
  .enable(1'b1),
  .DataInput(ReadReg1_Data_w),
  .DataOutput(ReadReg1_Data_ff_w)
  
);
Register Rd_Reg_Data2
(
  .clk(clk),
  .reset(reset),
  .enable(1'b1),
  .DataInput(ReadReg2_Data_w),
  .DataOutput(WriteData_o)
  
);
Mux_3_1 Mux_SrcA
(
	.sel(ALUsrcA_w),
	.In0(PC_w),
	.In1(OldPC_w),
	.In2(ReadReg1_Data_ff_w),
	.Output(SrcA_w)
);
Mux_3_1 Mux_SrcB
(
	.sel(ALUsrcB_w),
	.In0(WriteData_o),
	.In1(imm_w),
	.In2(PC_INCREMENT),
	.Output(SrcB_w)
);
ImmGen ImmGen_i 
(   
	.in(Instruction_w[31:7]),
	.ImmSel(ImmSel_w),
   .imm(imm_w)
);
ALU
ArithmeticLogicUnit 
(
	.ALUOperation(ALUCtrl_w),
	.A(SrcA_w),
	.B(SrcB_w),
	.Zero(zero_w),
	.ALUResult(ALUResult_w)
);
Register ALu_ff
(
  .clk(clk),
  .reset(reset),
  .enable(1'b1),
  .DataInput(ALUResult_w),
  .DataOutput(ALUResult_ff_w)
  
);
Mux_3_1 ResultSrc_Mux
(
	.sel(ResultSrc_w),
	.In0(ALUResult_ff_w),
	.In1(ReadData_w2),
	.In2(ALUResult_w),
	.Output(MuxResult_w)
);
FSM_Control	Control
(
  .clk(clk),
  .rst(reset),
  .zero(zero_w),
  .opcode(Instruction_w[6:0]),
  .Funct3(Instruction_w[14:12]),
  .Funct7(Instruction_w[31:25]),
  .PCWrite(PCWR_w),
  .AdrSrc(AdrSrc_sel_w),
  .MemWrite(MemWrite_o),
  .IRWrite(IRWrite_w),
  .RegWrite(RegWrite_w),
  .Branch(Branch_w),
  .ImmSrc(ImmSel_w),
  .ALUsrcA(ALUsrcA_w),
  .ALUsrcB(ALUsrcB_w),
  .ALUCtrl(ALUCtrl_w),
  .ResultSrc(ResultSrc_w)

);
endmodule