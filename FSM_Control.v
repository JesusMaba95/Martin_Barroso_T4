/******************************************************************
* Description
*	This is a code for FSM _Control of RISCV_MULTICYCLE
*	procesor.
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Modified by : 
	* 	Jesus Martin Barroso  ---> RISCV ARCHITECTURE FSM
* Date:
*	20/02/2021
******************************************************************/
module FSM_Control(
input clk,
input rst,
input zero,
input [6:0] opcode,
input [2:0] Funct3,
input [6:0] Funct7,

output reg PCWrite,
output reg AdrSrc,
output reg MemWrite,
output reg IRWrite,
output reg RegWrite,
output reg Branch,
output reg [2:0] ImmSrc,
output reg [1:0] ALUsrcA,
output reg [1:0] ALUsrcB,
output reg [2:0] ALUCtrl,
output reg [1:0] ResultSrc

);

localparam R_type_ARITH = 7'h33;//ADD,SUB,AND,OR,SLL,SLT,SLTU,XOR,SRL,SRA
localparam I_type_ARITH = 7'h13;//ADDI,SLLI,SLTI,SLTIU,XORI,SRLI,SRALI,ORI,ANDI
localparam I_type_LW    = 7'h03;//LW
localparam I_type_JALR  = 7'h67;//JALR
localparam S_type_SW    = 7'h23;//SW
localparam J_type       = 7'h6f;//JAL
localparam B_type       = 7'h63;//BEQ,BNE
localparam U_type       = 7'h17;//AUIPC

localparam S0_FETCH      = 4'b0000;
localparam S1_DECODE     = 4'b0001;
localparam S2_MEM_ADDR   = 4'b0010;
localparam S3_MEM_READ   = 4'b0011;
localparam S4_MEM_WBA    = 4'b0100;
localparam S5_MEM_WR     = 4'b0101;
localparam S6_EXECUTE_R  = 4'b0110;
localparam S7_ALU_WB     = 4'b0111;
localparam S8_EXECUTE_I  = 4'b1000;
localparam S9_JAL        = 4'b1001;
localparam S10_BEQ       = 4'b1010;
localparam S11_BNE       = 4'b1011;
localparam S12_JALR      = 4'b1100;
localparam S13_JALR      = 4'b1101;
localparam S14_BNEQ      = 4'b1110;
localparam S15_AUIPC     = 4'b1111;


reg [3:0] state;


/********************************************************************************************************************/

always@(posedge clk, negedge rst)
begin
       if(!rst)
		   begin
			     state <= S0_FETCH;
			end
			else
			   begin
				    case(state)
					   S0_FETCH:
						       state <= S1_DECODE;
						S1_DECODE:
						       if(opcode == I_type_LW)
							    state <= S2_MEM_ADDR;
								 else if(opcode == S_type_SW)
							    state <= S2_MEM_ADDR;
					          else if(opcode == R_type_ARITH)
							    state <= S6_EXECUTE_R;
					          else if(opcode == I_type_ARITH)
							    state <= S8_EXECUTE_I;
					          else if(opcode == J_type)
						   	 state <= S9_JAL;
								 else if(opcode == I_type_JALR)
						   	 state <= S12_JALR;
					          else if(opcode == B_type && Funct3 == 3'b000)
						   	 state <= S10_BEQ;
								 else if(opcode == B_type && Funct3 == 3'b001)
						   	 state <= S14_BNEQ;
								 else if(opcode == U_type)
								 state <= S15_AUIPC;
					          else 
					          state <= S1_DECODE;
						S2_MEM_ADDR:
						       if(opcode == I_type_LW)
							    state <= S3_MEM_READ;
								 else if(opcode == S_type_SW)
							    state <= S5_MEM_WR;
								 else 
					          state <= S2_MEM_ADDR;
						S3_MEM_READ:
								 state <= S4_MEM_WBA;
						S4_MEM_WBA:
						       state <= S0_FETCH;
						S5_MEM_WR:
						       state <= S0_FETCH;
						S6_EXECUTE_R:
			                state <= S7_ALU_WB;
						S7_ALU_WB:	
					          state <= S0_FETCH;	
						S8_EXECUTE_I:
						       state <= S7_ALU_WB;
						S9_JAL:
						       state <= S7_ALU_WB;	
						S10_BEQ:
						       state <= S0_FETCH;
					   S12_JALR:
						       state <= S13_JALR;
						S14_BNEQ:
						       state <= S0_FETCH;
					   S13_JALR:
						       state <= S7_ALU_WB;
					   S15_AUIPC:
								 state <= S0_FETCH;
						default: state <= S0_FETCH;
				  endcase
				end
end

always@(*)
begin
      case(state)
		     S0_FETCH:
			  begin
					PCWrite   = 1'b1;
					AdrSrc    = 1'b0;
					MemWrite  = 1'b0;
					IRWrite   = 1'b1;
					RegWrite  = 1'b0;
					Branch    = 1'b0;
					ImmSrc    = 3'bXXX;
					ALUsrcA   = 2'b00;
					ALUsrcB   = 2'b10;
					ResultSrc = 2'b10;
					ALUCtrl   = 3'b010; //ADD
			  end
			  S1_DECODE:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'b0;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b0;
					Branch    = 1'b0;
					if (opcode == I_type_ARITH || opcode == I_type_LW || opcode == I_type_JALR)
						ImmSrc    = 3'b000;
					else if (opcode == S_type_SW )
						ImmSrc    = 3'b001;
					else if (opcode == B_type )
						ImmSrc    = 3'b010;
					else if (opcode == J_type )
						ImmSrc    = 3'b011;
					else if (opcode == U_type)
						ImmSrc    = 3'b100;
					ALUsrcA   = 2'b01;
					ALUsrcB   = 2'b01;
					ResultSrc = 2'bXX;
					ALUCtrl   = 3'b010;//ADD
			  end
			  S2_MEM_ADDR:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'bX;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b0;
					Branch    = 1'b0;
					if (opcode == I_type_LW)
						ImmSrc    = 3'b000;
					else if (opcode == S_type_SW )
						ImmSrc    = 3'b001;
					ALUsrcA   = 2'b10;
					ALUsrcB   = 2'b01;
					ResultSrc = 2'bXX;
					ALUCtrl   = 3'b010;//ADD
			  end
			  S3_MEM_READ:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'b1;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b0;
					Branch    = 1'b0;
					ImmSrc    = 3'bXXX;
					ALUsrcA   = 2'bXX;
					ALUsrcB   = 2'bXX;
					ResultSrc = 2'b00;
					ALUCtrl   = 3'b010;//ADD
			  end
			  S4_MEM_WBA:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'bX;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b1;
					Branch    = 1'b0;
					ImmSrc    = 3'bXXX;
					ALUsrcA   = 2'bXX;
					ALUsrcB   = 2'bXX;
					ResultSrc = 2'b01;
					ALUCtrl   = 3'b010;//ADD
			  end
			  S5_MEM_WR:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'b1;
					MemWrite  = 1'b1;
					IRWrite   = 1'b0;
					RegWrite  = 1'b0;
					Branch    = 1'b0;
					ImmSrc    = 3'bXXX;
					ALUsrcA   = 2'bXX;
					ALUsrcB   = 2'bXX;
					ResultSrc = 2'b00;
					ALUCtrl   = 3'b010;//ADD
			  end
		     S6_EXECUTE_R:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'bX;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b0;
					Branch    = 1'b0;
					ImmSrc    = 3'bXXX;
					ALUsrcA   = 2'b10;
					ALUsrcB   = 2'b00;
					ResultSrc = 2'bXX;
					ALUCtrl   = 3'b010;//ADD
			  end
			  S7_ALU_WB:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'bX;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b1;
					Branch    = 1'b0;
					ImmSrc    = 3'bXXX;
					ALUsrcA   = 2'bXX;
					ALUsrcB   = 2'bXX;
					ResultSrc = 2'b00;
					ALUCtrl   = 3'b010;//ADD
			  end
			  S8_EXECUTE_I:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'bX;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b0;
					Branch    = 1'b0;
					ImmSrc    = 3'b000;
					ALUsrcA   = 2'b10;
					ALUsrcB   = 2'b01;
					ResultSrc = 2'bXX;
					case(Funct3)
						3'b000:
							ALUCtrl   = 3'b010;
						3'b001:
							ALUCtrl   = 3'b100;
						default:
							ALUCtrl   = 3'b010;
					endcase
			  end
			  S9_JAL:
			  begin
					PCWrite   = 1'b1;
					AdrSrc    = 1'b0;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b0;
					Branch    = 1'b0;
					ImmSrc    = 3'b011;
					ALUsrcA   = 2'b01;
					ALUsrcB   = 2'b10;
					ResultSrc = 2'b00;
					ALUCtrl   = 3'b010;//ADD
			  end
			  S10_BEQ:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'b0;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b0;
					Branch    = zero;
					ImmSrc    = 3'b010;
					ALUsrcA   = 2'b10;
					ALUsrcB   = 2'b00;
					ResultSrc = 2'b00;
					ALUCtrl   = 3'b011;//sub
			  end
			  S12_JALR:
			  begin
					PCWrite   = 1'b1;
					AdrSrc    = 1'b1;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b0;
					Branch    = 1'b0;
					ImmSrc    = 3'b000;
					ALUsrcA   = 2'b10;
					ALUsrcB   = 2'b01;//
					ResultSrc = 2'b10;
					ALUCtrl   = 3'b010;//add
			  end
			  S13_JALR:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'b1;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b0;
					Branch    = 1'b0;
					ImmSrc    = 3'b000;
					ALUsrcA   = 2'b01;
					ALUsrcB   = 2'b10;//
					ResultSrc = 2'b10;
					ALUCtrl   = 3'b010;//add
			  end
			  S14_BNEQ:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'b0;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b0;
					Branch    = !zero;
					ImmSrc    = 3'b010;
					ALUsrcA   = 2'b10;
					ALUsrcB   = 2'b00;
					ResultSrc = 2'b00;
					ALUCtrl   = 3'b011;//sub
			  end
			  S15_AUIPC:
			  begin
					PCWrite   = 1'b0;
					AdrSrc    = 1'b0;
					MemWrite  = 1'b0;
					IRWrite   = 1'b0;
					RegWrite  = 1'b1;
					Branch    = 1'b0;
					ImmSrc    = 3'b100;
					ALUsrcA   = 2'b01;
					ALUsrcB   = 2'b01;
					ResultSrc = 2'b10;
					ALUCtrl   = 3'b010;//sub
			  end
			  default:
			  begin
					PCWrite   = 1'b1;
					AdrSrc    = 1'b0;
					MemWrite  = 1'b0;
					IRWrite   = 1'b1;
					RegWrite  = 1'b0;
					Branch    = 1'b0;
					ImmSrc    = 3'bXXX;
					ALUsrcA   = 2'b00;
					ALUsrcB   = 2'b10;
					ResultSrc = 2'b00;
					ALUCtrl   = 3'b010; //ADD
			  end
			  
		endcase
end

endmodule
