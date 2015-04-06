module i2s_clkctrl_apb (
	input				clk, // Interface clock
	input				reset_n, // asynchronous, active low
	// APB
	input		[4:0]	paddr, // apb address
	input				penable, // apb enable
	input				pwrite,	// apb write strobe
	input 		[31:0]	pwdata, // apb data in
	input				psel, // apb select
	output reg	[31:0]	prdata, // apb data out
	output				pready, // apb ready
	// Clock inputs, synthesized in PLL or external TCXOs
	input				clk_48, // this clock, divided by mclk_devisor, should be 22.
	input				clk_44,
	// In slave mode, an external master makes the clocks
	input				ext_bclk,
	input				ext_playback_lrclk,
	input				ext_capture_lrclk,
	output				master_slave_mode, // 1 = master, 0 (default) = slave
	// Clock derived outputs
	output				clk_sel_48_44, // 1 = mclk derived from 44, 0 (default) mclk derived from 48
	output				mclk,
	output				bclk,
	output				playback_lrclk,
	output				capture_lrclk
);
/*
 * Example: Input clock is 24.5760MHz
 * mclk_divisor = 0 (divide by (0+1)*2=2) => mclk = 12.288MHz
 * bclk_divisor = 3 (divide by (3+1)*2=8) => bclk = 3.072MHz
 * lrclk_divisor = 15 (divide by (15*16+15+1)*2=512) => lrclk = 0.048MHz
 *
 * Example: Input clock is 33.8688MHz
 * mclk_divisor = 0 (divide by (0+1)*2=2) => mclk = 16.9344MHz
 * bclk_divisor = 5 (divide by (5+1)*2=12) => bclk = 2.8224MHz
 * lrclk_divisor = 23 (divide by (23*16+15+1)*2=768 => lrclk = 0.0441MHz
*/

	reg [31:0]		cmd_reg1;
	wire			cmd_sel1 = psel && (paddr == 0);
	reg [31:0]		cmd_reg2;
	wire			cmd_sel2 = psel && (paddr == 4);
	assign 			master_slave_mode = cmd_reg1[0]; // 1 = master, 0 (default) = slave
	assign			clk_sel_48_44 = cmd_reg1[1]; // 1 = mclk derived from 44, 0 (default) mclk derived from 48
	wire			cmd_reg2_wr = cmd_sel2 & pwrite & penable;
	// Register access
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			cmd_reg1 <= 0;
			cmd_reg2 <= 0;
		end
		else
		begin
			if (cmd_sel1 & pwrite & penable) // write cmd
				cmd_reg1 <= pwdata;
			else if (cmd_sel1 & ~pwrite & ~penable) // cmd readback
				prdata <= cmd_reg1;
			if (cmd_reg2_wr) // write cmd
				cmd_reg2 <= pwdata;
			else if (cmd_sel2 & ~pwrite & ~penable) // cmd readback
				prdata <= cmd_reg2;
		end
	end

	wire mclk48;
	wire bclk48;
	wire playback_lrclk48;
	wire capture_lrclk48;
	audio_clock_generator playback_gen48 (
		.clk		(clk_48),
		.reset_n	(reset_n),
		.cmd_reg1	(cmd_reg1),
		.cmd_reg2	(cmd_reg2),
		.mclk		(mclk48),
		.bclk		(bclk48),
		.lrclk_clear(cmd_reg2_wr),
		.lrclk1		(playback_lrclk48),
		.lrclk2		(capture_lrclk48)
	);
	wire mclk44;
	wire bclk44;
	wire playback_lrclk44;
	wire capture_lrclk44;
	audio_clock_generator playback_gen44 (
		.clk		(clk_44),
		.reset_n	(reset_n & ~cmd_reg2_wr),
		.cmd_reg1	(cmd_reg1),
		.cmd_reg2	(cmd_reg2),
		.mclk		(mclk44),
		.bclk		(bclk44),
		.lrclk_clear(cmd_reg2_wr),
		.lrclk1		(playback_lrclk44),
		.lrclk2		(capture_lrclk44)
	);
	
	// Output muxes
	assign mclk = clk_sel_48_44 ? mclk44 : mclk48;
	assign bclk = master_slave_mode
		? (clk_sel_48_44 ? bclk44 : bclk48)
		: ext_bclk;
	assign playback_lrclk = master_slave_mode
		? (clk_sel_48_44 ? playback_lrclk44 : playback_lrclk48)
		: ext_playback_lrclk;
	assign capture_lrclk = master_slave_mode
		? (clk_sel_48_44 ? capture_lrclk44 : capture_lrclk48)
		: ext_capture_lrclk;

	// APB
	assign pready = penable; // always ready (no wait states)

endmodule

module audio_clock_generator (
	input			clk,
	input			reset_n,
	input	[31:0]	cmd_reg1,
	input	[31:0]	cmd_reg2,
	output			mclk,
	output			bclk,
	input			lrclk_clear,
	output			lrclk1,
	output			lrclk2
);

	wire [7:0]		mclk_divisor = cmd_reg1[31:24]; // divide by (n + 1)*2
	wire [7:0]		bclk_divisor = cmd_reg1[23:16]; // divide by (n + 1)*2
	wire [7:0]		lrclk1_divisor = cmd_reg2[15:8]; // divide by (n + 1)*2*16
	wire [7:0]		lrclk2_divisor = cmd_reg2[7:0]; // divide by (n + 1)*2*16

	clk_divider #(.N(8)) mclk_divider (
		.clk		(clk),
		.reset_n	(reset_n),
		.max_count	(mclk_divisor),
		.q			(mclk)
	);
	clk_divider #(.N(8)) bclk_divider (
		.clk		(clk),
		.reset_n	(reset_n),
		.max_count	(bclk_divisor),
		.q			(bclk)
	);
	clk_divider #(.N(12)) lrclk1_divider (
		.clk		(clk),
		.reset_n	(reset_n & ~lrclk),
		.max_count	({lrclk1_divisor, 4'b1111}),
		.q			(lrclk1)
	);
	clk_divider #(.N(12)) lrclk2_divider (
		.clk		(clk),
		.reset_n	(reset_n & ~lrclk_clear),
		.max_count	({lrclk2_divisor, 4'b1111}),
		.q			(lrclk2)
	);
endmodule

module clk_divider #(parameter N = 8) (
	input			clk,
	input			reset_n,
	input	[N-1:0]	max_count,
	output reg		q
);
	reg [N-1:0] counter;
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			q <= 0;
			counter <= 0;
		end
		else
		begin
			if (counter == max_count)
			begin
				counter <= 0;
				q <= ~q;
			end
			else
				counter <= counter + 1;
		end
	end
endmodule

