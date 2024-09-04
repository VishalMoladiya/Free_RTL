//N-bit Johnson counter

module nbit_johnson#(parameter N=1)(clk,rst,Q);
  integer i;
  input clk,rst;
  output reg [N-1:0]Q;
  
  always@(posedge clk) begin
    
    if(rst)
      Q <= 1; //Starting Johnson counter
    
    else begin
      
      Q[N-1] <= ~Q[0]; //last FF data transfer to first FF
      
      for(i=0;i<(N-1);i=i+1)
        
        Q[i] <= Q[i+1]; //shifting data
      
    	end
  end
endmodule
