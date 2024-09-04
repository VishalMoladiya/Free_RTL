module FourBitALU(
  input wire [3:0] A,       // 4-bit input A
  input wire [3:0] B,       // 4-bit input B
  input wire [3:0] ShiftAmount, // Shift amount for shift operations
  input wire [3:0] RotateAmount, // Rotate amount for rotation operations
  input wire [3:0] OpCode,  // 4-bit operation code
  output reg [3:0] Result,  // 4-bit output
  output reg Cout,          // Carry-out for addition
  output reg Bout,          // Borrow-out for subtraction
  output reg Overflow,      // Overflow flag
  output reg Zero,          // Zero flag
  output reg Sign,          // Sign flag
  output reg Parity         // Parity flag
);

  // Internal signals
  reg [4:0] temp_result;  // Internal 5-bit result for shift and rotation operations
  reg [4:0] temp_A;       // Internal 5-bit representation of A for shift and rotation operations

  always @(A, B, ShiftAmount, RotateAmount, OpCode) begin
    // Internal signals initialization
    temp_result = 5'b0;
    temp_A = {1'b0, A};

    // ALU operation
    case(OpCode)
      4'b0000: Result = A + B;         // Addition
      4'b0001: Result = A - B;         // Subtraction
      4'b0010: Result = A & B;         // Bitwise AND
      4'b0011: Result = A | B;         // Bitwise OR
      4'b0100: Result = A ^ B;         // Bitwise XOR
      4'b0101: Result = A << ShiftAmount; // Logical Shift Left
      4'b0110: Result = A >>> ShiftAmount; // Logical Shift Right (zero-fill)
      4'b0111: Result = (A >> ShiftAmount) | (A << (4 - ShiftAmount)); // Rotate Right
      4'b1000: Result = (A << RotateAmount) | (A >> (4 - RotateAmount)); // Rotate Left
      default: Result = 4'bxxxx;       // Default to 'x' for undefined operations
    endcase

    // Carry-out for addition
    Cout = (OpCode == 4'b0000) && ((A[3] & B[3]) | (A[3] & Result[3]) | (B[3] & Result[3]));

    // Borrow-out for subtraction
    Bout = (OpCode == 4'b0001) && ((A[3] & ~B[3]) | ((A[3] ^ B[3]) & Result[3]));

    // Overflow detection for signed addition and subtraction
    Overflow = (OpCode == 4'b0000 || OpCode == 4'b0001) && ((A[3] & B[3] & ~Result[3]) | (~A[3] & ~B[3] & Result[3]));

    // Zero flag
    Zero = (Result == 4'b0);

    // Sign flag
    Sign = Result[3];

    // Parity flag
    Parity = ^Result;
  end

endmodule
