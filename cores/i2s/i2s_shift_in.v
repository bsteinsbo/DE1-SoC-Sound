/*
 * I2S shift in function.  Data interface is a FIFO.  FIFO is assumed to be dual-clock.
 * There will be no writes if not enabled.
 * New values will be written to FIFO only when fifo_ready.  If enabled, but not ready,
 * the last data sample will be dropped.
 */
module i2s_shift_in (
	input				clk,				// Master clock, should be synchronous with bclk/lrclk
	input				reset_n,			// Asynchronous reset
	output reg	[31:0]	fifo_right_data,	// Fifo interface, right channel
	output reg	[31:0]	fifo_left_data,		// Fifo interface, left channel
	input				fifo_ready,			// Fifo ready (not full)
	output reg			fifo_write,			// Fifo write strobe, write only when l+r received

	input				enable,				// Software enable
	input				bclk,				// I2S bclk
	input				lrclk,				// I2S lrclk (word clock)
	input				data_in				// Data in from ADC
);

	// bclk edge
	reg bclk_delayed;
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			bclk_delayed <= 0;
		end
		else
		begin
			bclk_delayed <= bclk;
		end
	end
	wire bclk_rising_edge = bclk & ~bclk_delayed;
	wire bclk_falling_edge = ~bclk & bclk_delayed;
		
	// lrclk edges
	reg lrclk_delayed;
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			lrclk_delayed <= 0;
		end
		else
		begin
			lrclk_delayed <= lrclk;
		end
	end
	wire lrclk_rising_edge = lrclk & ~lrclk_delayed;
	wire lrclk_falling_edge = ~lrclk & lrclk_delayed;

	// I2S is one bclk delayed, so detect falling egde of first (complete) bclk after each lrclk edge
	reg [1:0] first_bclk_falling_after_lrclk_rising_r;
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			first_bclk_falling_after_lrclk_rising_r <= 0;
		end
		else
		begin
			if (lrclk_rising_edge)
				first_bclk_falling_after_lrclk_rising_r <= 2'b01;
			else if (first_bclk_falling_after_lrclk_rising_r == 2'b01 && bclk_rising_edge)
				first_bclk_falling_after_lrclk_rising_r <= 2'b10;
			else if (first_bclk_falling_after_lrclk_rising_r == 2'b10 && bclk_falling_edge)
				first_bclk_falling_after_lrclk_rising_r <= 2'b11;
			else if (first_bclk_falling_after_lrclk_rising_r == 2'b11)
				first_bclk_falling_after_lrclk_rising_r <= 2'b00;
		end
	end
	wire first_bclk_falling_after_lrclk_rising = first_bclk_falling_after_lrclk_rising_r == 2'b11;
	
	reg [1:0] first_bclk_falling_after_lrclk_falling_r;
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			first_bclk_falling_after_lrclk_falling_r <= 0;
		end
		else
		begin
			if (lrclk_falling_edge)
				first_bclk_falling_after_lrclk_falling_r <= 2'b01;
			else if (first_bclk_falling_after_lrclk_falling_r == 2'b01 && bclk_rising_edge)
				first_bclk_falling_after_lrclk_falling_r <= 2'b10;
			else if (first_bclk_falling_after_lrclk_falling_r == 2'b10 && bclk_falling_edge)
				first_bclk_falling_after_lrclk_falling_r <= 2'b11;
			else if (first_bclk_falling_after_lrclk_falling_r == 2'b11)
				first_bclk_falling_after_lrclk_falling_r <= 2'b00;
		end
	end
	wire first_bclk_falling_after_lrclk_falling = first_bclk_falling_after_lrclk_falling_r == 2'b11;
	
	// shift-register
	reg [31:0] shift_register;
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			shift_register <= 0;
		end
		else
		begin
			if (~enable)
				shift_register <= 0;
			else if (bclk_rising_edge)
				shift_register <= {shift_register[30:0], data_in};
		end
	end

	// Load output register
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			fifo_right_data <= 0;
			fifo_left_data <= 0;
		end
		else
		begin
			if (~enable)
			begin
				fifo_right_data <= 0;
				fifo_left_data <= 0;
			end
			else if (first_bclk_falling_after_lrclk_rising)
				fifo_left_data <= shift_register;
			else if (first_bclk_falling_after_lrclk_falling)
				fifo_right_data <= shift_register;
		end				
	end

	// fifo write strobe, one clock after right channel has been loaded to output register
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			fifo_write <= 0;
		end
		else
		begin
			if (~enable | ~fifo_ready)
				fifo_write <= 0;
			else
				fifo_write <= first_bclk_falling_after_lrclk_falling;
		end
	end

endmodule
