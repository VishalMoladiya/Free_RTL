//110101 pattern detector

module pattern_110101(clk,rst,in,out,PS,NS,count);
  
parameter S0=3'b000, S1=3'b001, S2=3'b010, S3=3'b011,
  		  S4=3'b100, S5=3'b101; 
  
  input clk,rst,in;
  output reg out;
  output reg [2:0] PS,NS,count=0;
  
//nextstate assign 
  always@(posedge clk) begin
    if(rst)
      PS <= S0;
  	else
      PS <= NS;
  end

//State change
  always@(PS,in,NS) 
    begin
          case(PS)  
            S0: if(in) NS = S1;
                  else NS = S0;


            S1: if(in) NS = S2;
                  else NS = S0;

            S2: if(in) NS = S1;
                  else NS = S3;
            
            S3: if(in) NS = S4;
                  else NS = S0;
            
            S4: if(in) NS = S0;
                  else NS = S5;
            
            S5: if(in) NS = S1;
                  else NS = S0;

		    endcase
  	end
  
//Outputs        
  always@(PS,in)
    begin
         case(PS)  
           S0: if(in) out = 0;
               else out = 0;
           
           S1: if(in) out = 0;
               else out = 0;

           S2: if(in) out = 0;
               else out = 0;
           
           S3: if(in) out = 0;
               else out = 0;
           
           S4: if(in) out = 0;
               else out = 0;
           
           S5: if(in) begin out = 1; count=count+1; end
               else out = 0;

		    endcase
      
    end
endmodule
