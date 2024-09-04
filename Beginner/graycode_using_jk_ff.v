//DFF

module d_ff(d,clk,rst,q);
  input d,clk,rst;
  output reg q;
  always@(posedge clk) begin
      if(rst)
          q <= 1'b0;
      else
          q <= d;
  end
endmodule

//graycounter

module graycounter(clk,rst,count);
  
  input clk,rst;
  output [2:0] count;
  wire q2, q1, q0;
  wire [3:0]a;
  wire [2:0]o;

  assign count = {q2, q1, q0};
  
//d2
  and a1(a[0],q2,q0);
  and a2(a[1],q1,~q0);
  or o1(o[0],a[0],a[1]);
//d1
  and a3(a[2],~q2,q0);
  and a4(a[3],~q1,q0);
  or o2(o[1],a[2],a[3]);
//d0
  xnor x1(o[2],q2,q1);
  
//counter design
  
  d_ff d1(o[0],clk,rst,q2);
  d_ff d2(o[1],clk,rst,q1);
  d_ff d3(o[2],clk,rst,q0);
  
endmodule
