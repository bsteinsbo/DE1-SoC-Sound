/*
 * I2S shift out function.  Data interface is a FIFO, with fall-through
 * function.  Strobing the fifo_ack makes a new left/right data value available
 * on the input.  FIFO is assumed to be dual-clock.
 * Output is zero if not enabled.
 * New values will be read from FIFO only when fifo_ready.  If enabled, but not ready,
 * the last data sample will be repeated.
 */
module i2s_shift_out (
	input				clk,				// Master clock, should be synchronous with bclk/lrclk
	input				reset_n,			// Asynchronous reset
	input		[31:0]	fifo_right_data,	// Fifo interface, right channel
	input		[31:0]	fifo_left_data,		// Fifo interface, left channel
	input				fifo_ready,			// Fifo ready (not empty)
	output reg			fifo_ack,			// Fifo read ack

	input				enable,				// Software enable
	input				bclk,				// I2S bclk
	input				lrclk,				// I2S lrclk (word clock)
	output				data_out			// Data out to DAC
);

	// bclk edges
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

	// I2S is one bclk delayed, so we wait for first bclk after each lrclk edge
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
			else if (first_bclk_falling_after_lrclk_rising)
				shift_register <= fifo_right_data;
			else if (first_bclk_falling_after_lrclk_falling)
				shift_register <= fifo_left_data;
			else if (bclk_falling_edge)
				shift_register <= {shift_register[30:0], 1'b0};
		end
	end
	assign data_out = shift_register[31];

	// fifo ack, one clock after right channel has been loaded to shift register
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			fifo_ack <= 0;
		end
		else
		begin
			if (~enable | ~fifo_ready)
				fifo_ack <= 0;
			else
				fifo_ack <= first_bclk_falling_after_lrclk_rising;
		end
	end

endmodule
