module apb(pclk_i, prst_i, penable_i, pwrite_i, paddr_i, pwdata_i, prdata_o, pready_o, psel_i);

input pclk_i,prst_i;
input penable_i,psel_i;
input [31:0] paddr_i;
input [31:0] pwdata_i;
input pwrite_i;
output reg [31:0] prdata_o;
output reg pready_o;

//reg pwrite_i_temp;
reg [31:0] paddr_i_temp;
reg [31:0] pwdata_i_temp;

parameter S_IDLE=2'b01;
parameter S_SETUP=2'b10;
parameter S_ACCESS=2'b11;
integer i;

reg [31:0] mem[31:0];
reg [1:0] state,next_state;

always@(psel_i) begin
				$display("%t TEST_DUT_DISP: psel_i=%b, penable_i=%b ", $time, psel_i, penable_i);
end

always@(posedge pclk_i) begin
		if(prst_i==1) 
				state <= S_IDLE;
		else
				state <= next_state;
end

always@(*) begin
		if(prst_i==1) begin
				pready_o=0;
				prdata_o=0;
				next_state = S_IDLE;
          		for(i=0;i<32;i=i+1) begin
						mem[i]=0;
				end
		end
		else begin
				case(next_state)
						S_IDLE: begin
								if(psel_i==1) begin
									pready_o=1;
										if(penable_i==0)
												next_state=S_SETUP;
								end
								else begin
										next_state=S_IDLE;
								end
						end
						S_SETUP: begin
										if(psel_i==1) begin
																if(penable_i==1)begin
																				next_state=S_ACCESS;
																				paddr_i_temp = paddr_i;
																				pwdata_i_temp= pwdata_i;
																end
												end	
								end
						S_ACCESS:begin
								pready_o=1;
								if(pwrite_i==1) begin
										if(pready_o==1) begin
												mem[paddr_i_temp]=pwdata_i_temp;
										end
								end
						  		else begin
													pready_o = 1;
										prdata_o=mem[paddr_i_temp];
								end
								//pready_o=0;
								if(pready_o==0) begin
										next_state=S_ACCESS;
								end
								else if 
										(psel_i==1) begin
												if(penable_i==0) begin
														next_state=S_SETUP;
														$display("%t setup phase", $time);
												end

										end
										else begin
												if (penable_i==0) begin
														next_state=S_IDLE;
														$display("%t idle phase", $time);
												end
										end

								end
						endcase	
				end
		end
 endmodule
