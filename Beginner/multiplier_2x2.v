// ha

module halfadder(a,b,s,cr);
  input a,b;
  output wire s,cr;
  
  	assign s= (a& ~b)| (~a &b);
  	assign cr= a&b;
  
endmodule

//2x2 multiplier ckt

module mul_2x2(a,b,out);
  input [1:0] a,b;
  output [3:0]out;
  wire [3:0]m;
  wire [3:0]n;
  
  and a1(m[0],a[0],b[0]);
 
  and a2(n[0],a[0],b[1]);
  and a3(n[1],a[1],b[0]);
  halfadder h1(n[0],n[1],m[1],n[3]);
  
  and a4(n[2],a[1],b[1]);
  halfadder h2(n[3],n[2],m[2],m[3]);
  
  assign out={m[3],m[2],m[1],m[0]};
  
  
endmodule
