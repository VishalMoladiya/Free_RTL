//SPI
module spi(pclk_i,prst_i,paddr_i,pwrite_en_i,pwdata_i,prdata_o,penable_i,pready_o,pslverr_o,
	sclk_ref_i,sclk,mosi,miso,cs);

	parameter MAX_NUM_TRX=8;
	parameter S_IDLE=3'b000;
	parameter S_ADDR=3'b001;
	parameter S_IDLE_BW_ADDR_DATA=3'b010;
	parameter S_DATA=3'b011;
	parameter S_IDLE_BW_TRX=3'b100;


	input pclk_i,prst_i,pwrite_en_i,penable_i;
	input [7:0]pwdata_i;
	input [7:0]paddr_i;
	output reg[7:0]prdata_o;
	output reg pready_o,pslverr_o;
	input sclk_ref_i,miso;
	output reg mosi,cs,sclk;


	reg[7:0]addr_reg[MAX_NUM_TRX-1:0];
	reg[7:0]data_reg[MAX_NUM_TRX-1:0];
	reg[7:0]addr_to_drive;
	reg[7:0]data_to_drive;
	reg[7:0]data_collected;
	reg[7:0]ctrl_reg;
	reg[2:0]state,next_state;
	reg[3:0]num_trx;
	reg[2:0]crnt_tx_ptr;
	reg sclk_running;
	integer i;
	integer count;


	always@(next_state)begin
		state=next_state;
	end

	always@(sclk_ref_i)begin
		if(sclk_running)begin
			sclk=sclk_ref_i;
		end
		else
			sclk=1;
		end


		always@(posedge pclk_i)begin
			if(prst_i==1)begin
				pready_o=0;
				pslverr_o=0;
				prdata_o=0;
				mosi=1;
				sclk=1;
				cs=0;
				addr_to_drive=0;
				data_to_drive=0;
				ctrl_reg=0;
				crnt_tx_ptr=0;
				num_trx=0;
				sclk_running=0;
				state=S_IDLE;
				next_state=S_IDLE;
				for(i=0;i<MAX_NUM_TRX;i=i+1)begin
					addr_reg[i]=0;
					data_reg[i]=0;
				end
			end
			else begin
				if(penable_i==1)begin
					pready_o=1;
					if(pwrite_en_i==1)begin
						if(paddr_i>=8'h0 &&paddr_i<=8'h07)begin
							addr_reg[paddr_i]=pwdata_i;
						end
						if(paddr_i>=8'h10 &&paddr_i<=8'h17)begin
							data_reg[paddr_i-8'h10]=pwdata_i;
						end
						if(paddr_i==8'h20)begin
							ctrl_reg[3:0]=pwdata_i[3:0];
						end
					end
					else begin
						if(paddr_i>=8'h0 &&paddr_i<=8'h07)begin
							prdata_o=addr_reg[paddr_i];
						end
						if(paddr_i>=8'h10 &&paddr_i<=8'h17)begin
							prdata_o=data_reg[paddr_i-8'h10];
						end
						if(paddr_i==8'h20)begin
							prdata_o=ctrl_reg;
						end
					end
				end
			end
		end

		always@(posedge sclk_ref_i)begin
			if(!prst_i)begin
				case(state)
					S_IDLE:begin
						sclk_running=0;
						if(ctrl_reg[0]==1)begin
							ctrl_reg[0]=0;
							count=0;
							crnt_tx_ptr=ctrl_reg[6:4];
							num_trx=ctrl_reg[3:1]+1;
							addr_to_drive=addr_reg[crnt_tx_ptr];
							data_to_drive=data_reg[crnt_tx_ptr];
							next_state=S_ADDR;
						end
					end
					S_ADDR:begin
						sclk_running=1;
						mosi=addr_to_drive[count];
						count=count+1;
						if(count==8)begin
							count=0;
							next_state=S_IDLE_BW_ADDR_DATA;
						end
					end
					S_IDLE_BW_ADDR_DATA:begin
						sclk_running=0;
						count=count+1;
						if(count==4)begin
							count=0;
							next_state=S_DATA;
						end
					end
					S_DATA:begin
						sclk_running=1;
						if(addr_to_drive[7]==1) mosi=data_to_drive[count];
						else data_collected[count]=miso;
						count=count+1;
						if(count==8)begin
							count=0;
							num_trx=num_trx-1;
							crnt_tx_ptr=crnt_tx_ptr+1;
							ctrl_reg[6:4]=crnt_tx_ptr;
							addr_to_drive=0;
							data_to_drive=0;
							if(num_trx==0)begin
								next_state=S_IDLE;
							end
							else
								next_state=S_IDLE_BW_TRX;
						end
					end
					S_IDLE_BW_TRX:begin
						sclk_running=0;
						count=count+1;
						if(count==8)begin
							count=0;
							addr_to_drive=addr_reg[crnt_tx_ptr];
							data_to_drive=data_reg[crnt_tx_ptr];
							next_state=S_ADDR;
						end
					end
				endcase
				end
			end

		  assign mosi = state==S_ADDR ? addr_to_drive[count]: data_to_drive[count];
		  assign mosi = state==S_DATA ? data_to_drive[count]: addr_to_drive[count];

endmodule
