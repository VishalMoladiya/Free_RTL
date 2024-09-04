//design
module sync_fifo(clk,rst,wr_en_i,rd_en_i,wdata_i,rdata_o,full,empty,error);

	parameter WIDTH=8;
	parameter DEPTH=64;
	parameter PTR_WIDTH=6; //Pointer width 2**(Pointer width) at last we increment and decrement the pinter it's count

	input clk,rst,wr_en_i,rd_en_i;
	input [WIDTH-1:0]wdata_i;

	output reg [WIDTH-1:0]rdata_o;
  	output reg full,empty,error;
	reg wr_toggle,rd_toggle;
	reg [PTR_WIDTH-1:0] wr_ptr,rd_ptr;
	integer i;

	reg [WIDTH-1:0] mem[DEPTH-1:0];

	always@(posedge clk)
	begin
		if(rst)
		begin
			//when rst occur all reg value should be zero
			rdata_o=0;
			wr_toggle=0;
			rd_toggle=0;
			full=0;
			empty=0;
			error=0;
			wr_ptr=6'b000000;
			rd_ptr=6'b000000;

			for(i=0;i<DEPTH;i=i+1)
				mem[i]=0;

		end

		else
		begin
			error=0;
			if(wr_en_i==1)
			begin
              	if(full==1)
					error=1;
				else
				begin
					mem[wr_ptr]=wdata_i;
					if(wr_ptr==DEPTH-1)
						wr_toggle = ~wr_toggle;
					else
						wr_ptr = wr_ptr+1;
				end
			end 

			else if(rd_en_i==1)
			begin
              	if(empty==1)
					error=1;
				else
				begin
					rdata_o=mem[rd_ptr];
					if(rd_ptr==DEPTH-1)
						rd_toggle = ~rd_toggle;
					else
						rd_ptr = rd_ptr+1;
				end
			end
		end
			
	end

	//generating full and empty condition
  always@(wr_ptr or rd_ptr)
    begin
        
		full=0;
		empty=0;
  
		if(wr_ptr == rd_ptr && wr_toggle != rd_toggle)//full condition
			full=1;
		if(wr_ptr == rd_ptr && wr_toggle == rd_toggle)//empty condition
			empty=1;
	end

endmodule
