module intr_ctrl(
  //APB signals
  pclk_i,prst_i,paddr_i,pwdata_i,prdata_o,pwrite_i,penable_i,pready_o,pslverr_o,
  //processor signals
  intr_to_service_o,intr_valid_o,intr_serviced_i,//think w.r.t. INTC
  //peripherals signals
  intr_active_i);
  
  //number of intereupt or no of peripherals
  parameter NUM_INTR =16;
  
	//possible states
	parameter S_NO_INTR =2'b00;
	parameter S_INTR_ACTIVE =2'b01;
	parameter S_PROCESS_INTR =2'b10;
  
	//APB signals
	input pclk_i,prst_i,pwrite_i,penable_i;
	input [3:0] paddr_i;
	input [3:0] pwdata_i;
	output reg [3:0] prdata_o;
	output reg pready_o,pslverr_o;
  //processor signals
  input intr_serviced_i;
	output reg [3:0] intr_to_service_o;
	output reg intr_valid_o;
  //peripherals signal
  input [NUM_INTR-1:0] intr_active_i;
  
	integer i;
  //priority register
  reg [3:0] prio_reg [NUM_INTR-1:0]; 
	//state diagram signals  
	reg [1:0] state,next_state;
  //selection of prioroty register
	reg[3:0]highest_prio;
	reg[3:0]intr_with_highest_prio;
	reg first_match_f;//for reference of register
	//state diagram logic  
	always@(next_state)begin
		state=next_state;
	end
	//we need 2 always blocks i> programming in to register ii> handling the interrupts
  
  //i>Programming in to priority register
	 always@(posedge pclk_i)begin
      
    if(prst_i==1)begin //all reg equal to zero
			prdata_o=0;
			pready_o=0;
			pslverr_o=0;
			intr_to_service_o=0;
			intr_valid_o=0;
			highest_prio=0;
			intr_with_highest_prio=0;
			first_match_f=0;
          
			for(i=0;i<NUM_INTR;i=i+1)begin
				prio_reg[i]=0;
			end
			next_state=S_NO_INTR;
	
		end
		//check handshaking is happen or not      
		else begin
			if(penable_i==1)begin
				pready_o=1;
				if(pwrite_i==1)begin
                  	prio_reg[paddr_i]=pwdata_i;//write in to priority register
				end
				else begin
                  	prdata_o=prio_reg[paddr_i];//read from priority register
				end
			end
          
			else begin
				pready_o=0;
			end
		end
	end
  
	//ii>Handling the interrupt
	always @(posedge pclk_i)begin
    if(prst_i==0)begin
	    case(state)
				S_NO_INTR:
          begin
            //If interrupt is raised go into next state
	          if(intr_active_i)begin
						  next_state=S_INTR_ACTIVE;
						  first_match_f=1;
						end
	        end
	                 
				S_INTR_ACTIVE:
          begin
            //Handling interrupt to INTC
						for(i=0;i<NUM_INTR;i=i+1)begin
              if(intr_active_i[i])begin //checking: Is interrupt active or not?
								if(first_match_f==1)begin
									intr_with_highest_prio=i;
									highest_prio=prio_reg[i];
									first_match_f=0;//Interrupt with highest priority can't be repeat
								end
								else begin
                  //If first match flag is zero then check it's highest priority
									if(prio_reg[i]>highest_prio)begin
										intr_with_highest_prio=i;
										highest_prio=prio_reg[i];
							      first_match_f=0;
									end
								end
              end
						end
						//Handling interrupt to processor
						intr_valid_o=1;//processor considered the given signal if valid is '1'.
						intr_to_service_o=intr_with_highest_prio;
						next_state=S_PROCESS_INTR;
				end
	              
				S_PROCESS_INTR:begin
          //If interrupt is serviced then make all zero
					if(intr_serviced_i==1)begin
						intr_with_highest_prio=0;
						highest_prio=0;
						intr_valid_o=0;
						intr_to_service_o=0;
						next_state=S_INTR_ACTIVE;
							
            if(intr_active_i) begin
              first_match_f=1;
            end
						else
							next_state=S_NO_INTR;
					end
				end
			endcase
		end
	end
 endmodule
