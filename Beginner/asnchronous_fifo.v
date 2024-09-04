module async_fifo(wr_clk, rd_clk, rst, wr_en_i, wdata_i, full_o, rd_en_i, rdata_o, empty_o, error_o);

	parameter WIDTH=8;
	parameter DEPTH=16;
	parameter PTR_WIDTH=4;
	
	input wr_clk, rd_clk, rst, wr_en_i, rd_en_i;
	input [WIDTH-1:0] wdata_i;
	
	output reg [WIDTH-1:0] rdata_o;
	output reg empty_o, full_o, error_o;
	
	reg [WIDTH-1:0] mem [DEPTH-1:0];
	reg [PTR_WIDTH-1:0] wr_ptr, rd_ptr;

	reg [PTR_WIDTH-1:0] wr_ptr_gray, rd_ptr_gray;
	reg [PTR_WIDTH-1:0] wr_ptr_gray_rd_clk, rd_ptr_gray_wr_clk;

	reg wr_toggle_f, rd_toggle_f;
	reg wr_toggle_f_rd_clk, rd_toggle_f_wr_clk;
	integer i;
	
	//write related logic
	always @(posedge wr_clk) begin
		if (rst == 1) begin
			//reset all reg
			empty_o = 1;
			full_o = 0;
			error_o = 0;
			rdata_o = 0;
			wr_ptr = 0;
			rd_ptr = 0;
			wr_ptr_gray = 0;
			wr_ptr_gray_rd_clk = 0;
			rd_ptr_gray = 0;
			rd_ptr_gray_wr_clk = 0;
			wr_toggle_f_rd_clk = 0;
			rd_toggle_f_wr_clk = 0;
			wr_toggle_f = 0;
			rd_toggle_f = 0;
			for (i = 0; i < DEPTH; i=i+1) begin
				mem[i] = 0;
			end
		end
		else begin
			error_o = 0;
			if (wr_en_i == 1) begin
				if (full_o == 1) begin
					$display("ERROR: Writing to FULL FIFO");
					error_o = 1;
				end
				else begin
					mem[wr_ptr] = wdata_i; //Writing in to FIFO
					if (wr_ptr == DEPTH-1) begin //we have reached last location
						wr_toggle_f = ~wr_toggle_f; //toggling the flag
						wr_ptr = 0; //going back to beginning location
					end
					else begin
						wr_ptr = wr_ptr + 1; //5 -> 6
					end
					wr_ptr_gray = bin2gray(wr_ptr);
				end
			end
		end
	end
	
	//read related logic
	always @(posedge rd_clk) begin
		if (rst == 0) begin //if reset is not applied
			error_o = 0;
			if (rd_en_i == 1) begin
				if (empty_o == 1) begin
					$display("ERROR: Reading from EMPTY FIFO");
					error_o = 1;
				end
				else begin
					rdata_o = mem[rd_ptr];
					if (rd_ptr == DEPTH-1) begin
						rd_toggle_f = ~rd_toggle_f;
						rd_ptr = 0;
					end
					else begin
						rd_ptr = rd_ptr + 1;
					end
					rd_ptr_gray = bin2gray(rd_ptr);
				end
			end
		end
	end
	
	function reg [WIDTH-1:0] bin2gray(input reg [WIDTH-1:0] bin);
	reg [WIDTH-1:0] gray;
	integer i;
	begin
		gray[WIDTH-1] = bin[WIDTH-1]; //3:3
		for (i = WIDTH-2; i >= 0; i=i-1) begin
			gray[i] = bin[i+1]^bin[i];
		end
		bin2gray = gray;
	end
	endfunction
	
	always @(posedge wr_clk) begin
		rd_ptr_gray_wr_clk <= rd_ptr_gray; //called as 1 stage synchronizer
			//rd_ptr_wr_clk is synchronized w.r.t to wr_clk domain => now it can be directly compared with wr_ptr
		rd_toggle_f_wr_clk <= rd_toggle_f;
	end
	
	always @(posedge rd_clk) begin
		wr_ptr_gray_rd_clk <= wr_ptr_gray; //called as 1 stage synchronizer
		wr_toggle_f_rd_clk <= wr_toggle_f;
	end
	
	//empty_o and full_o conditions are generated asynchronosly
	//Generating full and empty conditions
	always @(wr_ptr_gray or wr_ptr_gray_rd_clk or rd_ptr_gray_wr_clk or rd_ptr_gray) begin
	full_o = 0;
	empty_o = 0;
	if (wr_ptr_gray_rd_clk == rd_ptr_gray && wr_toggle_f_rd_clk == rd_toggle_f) begin //EMPTY
		empty_o = 1;
	end
	if (wr_ptr_gray == rd_ptr_gray_wr_clk && wr_toggle_f != rd_toggle_f_wr_clk) begin //FULL
		full_o = 1;
	end
	end

endmodule
