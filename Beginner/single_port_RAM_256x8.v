//Design 256 byte memory with 1 byte width

module memory(clk, rst, addr, wdata, rdata, wr_rd, valid, ready);
//wr_rd: write read data control line, when wr_rd=1 > write data and when wr_rd=0 > read data
  
	parameter WIDTH=8;
	parameter DEPTH=256;
	parameter ADDR_WIDTH= 8;
	integer i;

	input clk, rst, wr_rd, valid;
	input [ADDR_WIDTH-1:0]addr; 
	input [WIDTH-1:0]wdata;
  
	output reg [WIDTH-1:0]rdata;
	output reg ready;
  
  	reg [WIDTH-1:0]mem[DEPTH-1];//258*8 memory size


	always@(posedge clk)begin
      
		if(rst) begin
			rdata=0;
			ready=0;
			for(i=0; i<DEPTH; i=i+1)begin
              mem[i]=0;//all address of memory are zero
			end
		end
      
		else begin
          
          if(valid==1)begin //if CS/EN is 1 then you write or read data 
				ready=1;//output 1 
            
            //Write operation
            
				if(wr_rd==1)begin
					mem[addr]=wdata;
				end
            
            //Read operation
            
				else if(wr_rd==0)begin
					rdata=mem[addr];	
				end 
        	end
          
			else ready=0;
          
		end

	end


endmodule
