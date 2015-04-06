module DE1_SOC_Linux_Audio(
	//////////// ADC //////////
	inout						ADC_CS_N,
	output						ADC_DIN,
	input						ADC_DOUT,
	output						ADC_SCLK,

	//////////// Audio //////////
	input						AUD_ADCDAT,
	inout						AUD_ADCLRCK,
	inout						AUD_BCLK,
	output						AUD_DACDAT,
	inout						AUD_DACLRCK,
	output						AUD_XCK,

	//////////// CLOCK //////////
	input						CLOCK_50,
	input						CLOCK2_50,
	input						CLOCK3_50,
	input						CLOCK4_50,

	//////////// SDRAM //////////
	output			[12:0]		DRAM_ADDR,
	output			 [1:0]		DRAM_BA,
	output						DRAM_CAS_N,
	output						DRAM_CKE,
	output						DRAM_CLK,
	output						DRAM_CS_N,
	inout			[15:0]		DRAM_DQ,
	output						DRAM_LDQM,
	output						DRAM_RAS_N,
	output						DRAM_UDQM,
	output						DRAM_WE_N,

	///////// FAN /////////
	output						FAN_CTRL,

	//////////// I2C for Audio and Video-In //////////
	output						FPGA_I2C_SCLK,
	inout						FPGA_I2C_SDAT,

	//////////// SEG7 //////////
	output			 [6:0]		HEX0,
	output			 [6:0]		HEX1,
	output			 [6:0]		HEX2,
	output			 [6:0]		HEX3,
	output			 [6:0]		HEX4,
	output			 [6:0]		HEX5,

	//////////// IR //////////
	input						IRDA_RXD,
	output						IRDA_TXD,

	//////////// KEY //////////
	input			 [3:0]		KEY,

	//////////// LED //////////
	output			 [9:0]		LEDR,

	//////////// PS2 //////////
	inout						PS2_CLK,
	inout						PS2_CLK2,
	inout						PS2_DAT,
	inout						PS2_DAT2,

	//////////// SW //////////
	input			 [9:0]		SW,

	//////////// Video-In //////////
	input						TD_CLK27,
	input			 [7:0]		TD_DATA,
	input						TD_HS,
	output						TD_RESET_N,
	input						TD_VS,

	//////////// VGA //////////
	output			 [7:0]		VGA_B,
	output						VGA_BLANK_N,
	output						VGA_CLK,
	output			 [7:0]		VGA_G,
	output						VGA_HS,
	output			 [7:0]		VGA_R,
	output						VGA_SYNC_N,
	output						VGA_VS,

	//////////// HPS //////////
	inout						HPS_CONV_USB_N,
	output			[14:0]		HPS_DDR3_ADDR,
	output			 [2:0]		HPS_DDR3_BA,
	output						HPS_DDR3_CAS_N,
	output						HPS_DDR3_CK_N,
	output						HPS_DDR3_CK_P,
	output						HPS_DDR3_CKE,
	output						HPS_DDR3_CS_N,
	output			 [3:0]		HPS_DDR3_DM,
	inout			[31:0]		HPS_DDR3_DQ,
	inout			 [3:0]		HPS_DDR3_DQS_N,
	inout			 [3:0]		HPS_DDR3_DQS_P,
	output						HPS_DDR3_ODT,
	output						HPS_DDR3_RAS_N,
	output						HPS_DDR3_RESET_N,
	input						HPS_DDR3_RZQ,
	output						HPS_DDR3_WE_N,
	output						HPS_ENET_GTX_CLK,
	inout						HPS_ENET_INT_N,
	output						HPS_ENET_MDC,
	inout						HPS_ENET_MDIO,
	input						HPS_ENET_RX_CLK,
	input			 [3:0]		HPS_ENET_RX_DATA,
	input						HPS_ENET_RX_DV,
	output			 [3:0]		HPS_ENET_TX_DATA,
	output						HPS_ENET_TX_EN,
	inout			 [3:0]		HPS_FLASH_DATA,
	output						HPS_FLASH_DCLK,
	output						HPS_FLASH_NCSO,
	inout			 [1:0]		HPS_GPIO,
	inout						HPS_GSENSOR_INT,
	inout						HPS_I2C_CONTROL,
	inout						HPS_I2C1_SCLK,
	inout						HPS_I2C1_SDAT,
	inout						HPS_I2C2_SCLK,
	inout						HPS_I2C2_SDAT,
	inout						HPS_KEY,
	inout						HPS_LED,
	inout						HPS_LTC_GPIO,
	output						HPS_SD_CLK,
	inout						HPS_SD_CMD,
	inout			 [3:0]		HPS_SD_DATA,
	output						HPS_SPIM_CLK,
	input						HPS_SPIM_MISO,
	output						HPS_SPIM_MOSI,
	inout						HPS_SPIM_SS,
	input						HPS_UART_RX,
	output						HPS_UART_TX,
	input						HPS_USB_CLKOUT,
	inout			 [7:0]		HPS_USB_DATA,
	input						HPS_USB_DIR,
	input						HPS_USB_NXT,
	output						HPS_USB_STP,

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	inout			[35:0]		GPIO_0,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	inout			[35:0]		GPIO_1
);



//=======================================================
//  REG/WIRE declarations
//=======================================================
	wire				clock_bridge_0_out_clk_clk;
	wire				hps_0_h2f_reset_reset_n;
	wire				hps_0_f2h_dma_req0_dma_req;
	wire				hps_0_f2h_dma_req0_dma_single;
	wire				hps_0_f2h_dma_req0_dma_ack;
	wire				hps_0_f2h_dma_req1_dma_req;
	wire				hps_0_f2h_dma_req1_dma_single;
	wire				hps_0_f2h_dma_req1_dma_ack;
	wire				hps_0_f2h_dma_req2_dma_req;
	wire				hps_0_f2h_dma_req2_dma_single;
	wire				hps_0_f2h_dma_req2_dma_ack;
	wire				hps_0_f2h_dma_req3_dma_req;
	wire				hps_0_f2h_dma_req3_dma_single;
	wire				hps_0_f2h_dma_req3_dma_ack;
	wire	[63:0]		i2s_output_apb_0_playback_fifo_data;
	wire				i2s_output_apb_0_playback_fifo_read;
	wire				i2s_output_apb_0_playback_fifo_empty;
	wire				i2s_output_apb_0_playback_fifo_full;
	wire				i2s_output_apb_0_playback_fifo_clk;
	wire				i2s_output_apb_0_playback_dma_enable;
	wire				i2s_playback_enable;
	wire	[63:0]		i2s_output_apb_0_capture_fifo_data;
	wire				i2s_output_apb_0_capture_fifo_write;
	wire				i2s_output_apb_0_capture_fifo_empty;
	wire				i2s_output_apb_0_capture_fifo_full;
	wire				i2s_output_apb_0_capture_fifo_clk;
	wire				i2s_output_apb_0_capture_dma_enable;
	wire				i2s_capture_enable;
	wire				i2s_clkctrl_apb_0_ext_bclk;
	wire				i2s_clkctrl_apb_0_ext_playback_lrclk;
	wire				i2s_clkctrl_apb_0_ext_capture_lrclk;
	wire				i2s_clkctrl_apb_0_conduit_master_slave_mode;
	wire				i2s_clkctrl_apb_0_conduit_clk_sel_48_44;
	wire				i2s_clkctrl_apb_0_conduit_bclk;
	wire				i2s_clkctrl_apb_0_conduit_playback_lrclk;
	wire				i2s_clkctrl_apb_0_conduit_capture_lrclk;
	wire				i2s_clkctrl_apb_0_mclk_clk;
	wire				clock_bridge_48_out_clk_clk;
	wire				clock_bridge_44_out_clk_clk;

//=======================================================
//  Structural coding
//=======================================================


    soc_system u0 (
		.clk_clk							(CLOCK_50),
		.reset_reset_n						(hps_0_h2f_reset_reset_n),
		.clock_bridge_0_out_clk_clk			(clock_bridge_0_out_clk_clk),

		.memory_mem_a						(HPS_DDR3_ADDR),
		.memory_mem_ba						(HPS_DDR3_BA),
		.memory_mem_ck						(HPS_DDR3_CK_P),
		.memory_mem_ck_n					(HPS_DDR3_CK_N),
		.memory_mem_cke						(HPS_DDR3_CKE),
		.memory_mem_cs_n					(HPS_DDR3_CS_N),
		.memory_mem_ras_n					(HPS_DDR3_RAS_N),
		.memory_mem_cas_n					(HPS_DDR3_CAS_N),
		.memory_mem_we_n					(HPS_DDR3_WE_N),
		.memory_mem_reset_n					(HPS_DDR3_RESET_N),
		.memory_mem_dq						(HPS_DDR3_DQ),
		.memory_mem_dqs						(HPS_DDR3_DQS_P),
		.memory_mem_dqs_n					(HPS_DDR3_DQS_N),
		.memory_mem_odt						(HPS_DDR3_ODT),
		.memory_mem_dm						(HPS_DDR3_DM),
		.memory_oct_rzqin					(HPS_DDR3_RZQ),

		.hps_0_f2h_dma_req0_dma_req			(hps_0_f2h_dma_req0_dma_req),
		.hps_0_f2h_dma_req0_dma_single		(hps_0_f2h_dma_req0_dma_single),
		.hps_0_f2h_dma_req0_dma_ack			(hps_0_f2h_dma_req0_dma_ack),
		.hps_0_f2h_dma_req1_dma_req			(hps_0_f2h_dma_req1_dma_req),
		.hps_0_f2h_dma_req1_dma_single		(hps_0_f2h_dma_req1_dma_single),
		.hps_0_f2h_dma_req1_dma_ack			(hps_0_f2h_dma_req1_dma_ack),
		.hps_0_f2h_dma_req2_dma_req			(hps_0_f2h_dma_req2_dma_req),
		.hps_0_f2h_dma_req2_dma_single		(hps_0_f2h_dma_req2_dma_single),
		.hps_0_f2h_dma_req2_dma_ack			(hps_0_f2h_dma_req2_dma_ack),
		.hps_0_f2h_dma_req3_dma_req			(hps_0_f2h_dma_req3_dma_req),
		.hps_0_f2h_dma_req3_dma_single		(hps_0_f2h_dma_req3_dma_single),
		.hps_0_f2h_dma_req3_dma_ack			(hps_0_f2h_dma_req3_dma_ack),

		.hps_io_hps_io_emac1_inst_TX_CLK	(HPS_ENET_GTX_CLK),
		.hps_io_hps_io_emac1_inst_TXD0		(HPS_ENET_TX_DATA[0]),
		.hps_io_hps_io_emac1_inst_TXD1		(HPS_ENET_TX_DATA[1]),
		.hps_io_hps_io_emac1_inst_TXD2		(HPS_ENET_TX_DATA[2]),
		.hps_io_hps_io_emac1_inst_TXD3		(HPS_ENET_TX_DATA[3]),
		.hps_io_hps_io_emac1_inst_MDIO		(HPS_ENET_MDIO),
		.hps_io_hps_io_emac1_inst_MDC		(HPS_ENET_MDC),
		.hps_io_hps_io_emac1_inst_RX_CTL	(HPS_ENET_RX_DV),
		.hps_io_hps_io_emac1_inst_TX_CTL	(HPS_ENET_TX_EN),
		.hps_io_hps_io_emac1_inst_RX_CLK	(HPS_ENET_RX_CLK),
		.hps_io_hps_io_emac1_inst_RXD0		(HPS_ENET_RX_DATA[0]),
		.hps_io_hps_io_emac1_inst_RXD1		(HPS_ENET_RX_DATA[1]),
		.hps_io_hps_io_emac1_inst_RXD2		(HPS_ENET_RX_DATA[2]),
		.hps_io_hps_io_emac1_inst_RXD3		(HPS_ENET_RX_DATA[3]),

		.hps_io_hps_io_qspi_inst_IO0		(HPS_FLASH_DATA[0]),
		.hps_io_hps_io_qspi_inst_IO1		(HPS_FLASH_DATA[1]),
		.hps_io_hps_io_qspi_inst_IO2		(HPS_FLASH_DATA[2]),
		.hps_io_hps_io_qspi_inst_IO3		(HPS_FLASH_DATA[3]),
		.hps_io_hps_io_qspi_inst_SS0		(HPS_FLASH_NCSO),
		.hps_io_hps_io_qspi_inst_CLK		(HPS_FLASH_DCLK),


		.hps_io_hps_io_sdio_inst_CMD		(HPS_SD_CMD),
		.hps_io_hps_io_sdio_inst_D0			(HPS_SD_DATA[0]),
		.hps_io_hps_io_sdio_inst_D1			(HPS_SD_DATA[1]),
		.hps_io_hps_io_sdio_inst_D2			(HPS_SD_DATA[2]),
		.hps_io_hps_io_sdio_inst_D3			(HPS_SD_DATA[3]),
		.hps_io_hps_io_sdio_inst_CLK		(HPS_SD_CLK),

		.hps_io_hps_io_usb1_inst_D0			(HPS_USB_DATA[0]),
		.hps_io_hps_io_usb1_inst_D1			(HPS_USB_DATA[1]),
		.hps_io_hps_io_usb1_inst_D2			(HPS_USB_DATA[2]),
		.hps_io_hps_io_usb1_inst_D3			(HPS_USB_DATA[3]),
		.hps_io_hps_io_usb1_inst_D4			(HPS_USB_DATA[4]),
		.hps_io_hps_io_usb1_inst_D5			(HPS_USB_DATA[5]),
		.hps_io_hps_io_usb1_inst_D6			(HPS_USB_DATA[6]),
		.hps_io_hps_io_usb1_inst_D7			(HPS_USB_DATA[7]),
		.hps_io_hps_io_usb1_inst_CLK		(HPS_USB_CLKOUT),
		.hps_io_hps_io_usb1_inst_STP		(HPS_USB_STP),
		.hps_io_hps_io_usb1_inst_DIR		(HPS_USB_DIR),
		.hps_io_hps_io_usb1_inst_NXT		(HPS_USB_NXT),

		.hps_io_hps_io_spim1_inst_CLK		(HPS_SPIM_CLK),
		.hps_io_hps_io_spim1_inst_MOSI		(HPS_SPIM_MOSI),
		.hps_io_hps_io_spim1_inst_MISO		(HPS_SPIM_MISO),
		.hps_io_hps_io_spim1_inst_SS0		(HPS_SPIM_SS),

		.hps_io_hps_io_uart0_inst_RX		(HPS_UART_RX),
		.hps_io_hps_io_uart0_inst_TX		(HPS_UART_TX),

		.hps_io_hps_io_i2c0_inst_SDA		(HPS_I2C1_SDAT),
		.hps_io_hps_io_i2c0_inst_SCL		(HPS_I2C1_SCLK),

		.hps_io_hps_io_i2c1_inst_SDA		(HPS_I2C2_SDAT),
		.hps_io_hps_io_i2c1_inst_SCL		(HPS_I2C2_SCLK),

		.hps_io_hps_io_gpio_inst_GPIO09		(HPS_CONV_USB_N),
		.hps_io_hps_io_gpio_inst_GPIO35		(HPS_ENET_INT_N),
		.hps_io_hps_io_gpio_inst_GPIO40		(HPS_LTC_GPIO),
		.hps_io_hps_io_gpio_inst_GPIO48		(HPS_I2C_CONTROL),
		.hps_io_hps_io_gpio_inst_GPIO53		(HPS_LED),
		.hps_io_hps_io_gpio_inst_GPIO54		(HPS_KEY),
		.hps_io_hps_io_gpio_inst_GPIO61		(HPS_GSENSOR_INT),

        .hps_0_h2f_reset_reset_n			(hps_0_h2f_reset_reset_n),

		.i2s_output_apb_0_playback_fifo_data(i2s_output_apb_0_playback_fifo_data),
		.i2s_output_apb_0_playback_fifo_read(i2s_output_apb_0_playback_fifo_read),
		.i2s_output_apb_0_playback_fifo_empty(i2s_output_apb_0_playback_fifo_empty),
		.i2s_output_apb_0_playback_fifo_full(i2s_output_apb_0_playback_fifo_full),
		.i2s_output_apb_0_playback_fifo_clk	(i2s_output_apb_0_playback_fifo_clk),
		.i2s_output_apb_0_playback_dma_req	(hps_0_f2h_dma_req0_dma_single),
		.i2s_output_apb_0_playback_dma_ack	(hps_0_f2h_dma_req0_dma_ack),
		.i2s_output_apb_0_playback_dma_enable(i2s_output_apb_0_playback_dma_enable),
		.i2s_output_apb_0_capture_fifo_data	(i2s_output_apb_0_capture_fifo_data),
		.i2s_output_apb_0_capture_fifo_write(i2s_output_apb_0_capture_fifo_write),
		.i2s_output_apb_0_capture_fifo_empty(i2s_output_apb_0_capture_fifo_empty),
		.i2s_output_apb_0_capture_fifo_full	(i2s_output_apb_0_capture_fifo_full),
		.i2s_output_apb_0_capture_fifo_clk	(i2s_output_apb_0_capture_fifo_clk),
		.i2s_output_apb_0_capture_dma_req	(hps_0_f2h_dma_req1_dma_single),
		.i2s_output_apb_0_capture_dma_ack	(hps_0_f2h_dma_req1_dma_ack),
		.i2s_output_apb_0_capture_dma_enable(i2s_output_apb_0_capture_dma_enable),

		.i2s_clkctrl_apb_0_ext_bclk			(i2s_clkctrl_apb_0_ext_bclk),
		.i2s_clkctrl_apb_0_ext_playback_lrclk(i2s_clkctrl_apb_0_ext_playback_lrclk),
		.i2s_clkctrl_apb_0_ext_capture_lrclk(i2s_clkctrl_apb_0_ext_capture_lrclk),
		.i2s_clkctrl_apb_0_conduit_master_slave_mode(i2s_clkctrl_apb_0_conduit_master_slave_mode),
		.i2s_clkctrl_apb_0_conduit_clk_sel_48_44(i2s_clkctrl_apb_0_conduit_clk_sel_48_44),
		.i2s_clkctrl_apb_0_conduit_bclk		(i2s_clkctrl_apb_0_conduit_bclk),
		.i2s_clkctrl_apb_0_conduit_playback_lrclk(i2s_clkctrl_apb_0_conduit_playback_lrclk),
		.i2s_clkctrl_apb_0_conduit_capture_lrclk(i2s_clkctrl_apb_0_conduit_capture_lrclk),
		.i2s_clkctrl_apb_0_mclk_clk			(i2s_clkctrl_apb_0_mclk_clk),

		.clock_bridge_48_out_clk_clk		(clock_bridge_48_out_clk_clk),
		.clock_bridge_44_out_clk_clk		(clock_bridge_44_out_clk_clk),
 
	);

	wire i2s_playback_fifo_ack48;
	wire i2s_data_out48;
	i2s_shift_out i2s_shift_out48(
		.reset_n							(hps_0_h2f_reset_reset_n),
		.clk								(clock_bridge_48_out_clk_clk),
		
		.fifo_right_data					(i2s_output_apb_0_playback_fifo_data[63:32]),
		.fifo_left_data						(i2s_output_apb_0_playback_fifo_data[31:0]),
		.fifo_ready							(~i2s_output_apb_0_playback_fifo_empty),
		.fifo_ack							(i2s_playback_fifo_ack48),
  
		.enable								(i2s_playback_enable),
		.bclk								(i2s_clkctrl_apb_0_conduit_bclk),
		.lrclk								(i2s_clkctrl_apb_0_conduit_playback_lrclk),
		.data_out							(i2s_data_out48)
	);
	wire i2s_playback_fifo_ack44;
	wire i2s_data_out44;
	i2s_shift_out i2s_shift_out44(
		.reset_n							(hps_0_h2f_reset_reset_n),
		.clk								(clock_bridge_44_out_clk_clk),
		
		.fifo_right_data					(i2s_output_apb_0_playback_fifo_data[63:32]),
		.fifo_left_data						(i2s_output_apb_0_playback_fifo_data[31:0]),
		.fifo_ready							(~i2s_output_apb_0_playback_fifo_empty),
		.fifo_ack							(i2s_playback_fifo_ack44),
  
		.enable								(i2s_playback_enable),
		.bclk								(i2s_clkctrl_apb_0_conduit_bclk),
		.lrclk								(i2s_clkctrl_apb_0_conduit_playback_lrclk),
		.data_out							(i2s_data_out44)
	);

	wire i2s_capture_fifo_write48;
	wire i2s_data_in48;
	wire [63:0] i2s_capture_fifo_data48;
	i2s_shift_in i2s_shift_in48(
		.reset_n							(hps_0_h2f_reset_reset_n),
		.clk								(clock_bridge_48_out_clk_clk),
		
		.fifo_right_data					(i2s_capture_fifo_data48[63:32]),
		.fifo_left_data						(i2s_capture_fifo_data48[31:0]),
		.fifo_ready							(~i2s_output_apb_0_capture_fifo_full),
		.fifo_write							(i2s_capture_fifo_write48),
  
		.enable								(i2s_capture_enable),
		.bclk								(i2s_clkctrl_apb_0_conduit_bclk),
		.lrclk								(i2s_clkctrl_apb_0_conduit_capture_lrclk),
		.data_in							(i2s_data_in48)
	);
	wire i2s_capture_fifo_write44;
	wire i2s_data_in44;
	wire [63:0] i2s_capture_fifo_data44;
	i2s_shift_in i2s_shift_in44(
		.reset_n							(hps_0_h2f_reset_reset_n),
		.clk								(clock_bridge_44_out_clk_clk),
		
		.fifo_right_data					(i2s_capture_fifo_data44[63:32]),
		.fifo_left_data						(i2s_capture_fifo_data44[31:0]),
		.fifo_ready							(~i2s_output_apb_0_capture_fifo_full),
		.fifo_write							(i2s_capture_fifo_write44),
  
		.enable								(i2s_capture_enable),
		.bclk								(i2s_clkctrl_apb_0_conduit_bclk),
		.lrclk								(i2s_clkctrl_apb_0_conduit_capture_lrclk),
		.data_in							(i2s_data_in44)
	);

	// Combinatorics
	assign AUD_XCK = i2s_clkctrl_apb_0_mclk_clk;
	assign i2s_playback_enable = i2s_output_apb_0_playback_dma_enable & ~i2s_output_apb_0_playback_fifo_empty;
	assign i2s_capture_enable = i2s_output_apb_0_capture_dma_enable & ~i2s_output_apb_0_capture_fifo_full;

	// Mux and sync fifo read ack
	reg [2:0] i2s_playback_fifo_ack_synchro;
	assign i2s_playback_fifo_ack = i2s_clkctrl_apb_0_conduit_clk_sel_48_44 ?
		i2s_playback_fifo_ack44 : i2s_playback_fifo_ack48;
	always @(posedge clock_bridge_0_out_clk_clk or negedge hps_0_h2f_reset_reset_n)
		if (~hps_0_h2f_reset_reset_n)
			i2s_playback_fifo_ack_synchro <= 0;
		else
			i2s_playback_fifo_ack_synchro <= {i2s_playback_fifo_ack_synchro[1:0], i2s_playback_fifo_ack};
	assign i2s_output_apb_0_playback_fifo_read = i2s_playback_fifo_ack_synchro[2] & ~i2s_playback_fifo_ack_synchro[1];
	assign i2s_output_apb_0_playback_fifo_clk = clock_bridge_0_out_clk_clk;

	// Mux and sync fifo write
	reg [2:0] i2s_capture_fifo_write_synchro;
	assign i2s_capture_fifo_write = i2s_clkctrl_apb_0_conduit_clk_sel_48_44 ?
		i2s_capture_fifo_write44 : i2s_capture_fifo_write48;
	always @(posedge clock_bridge_0_out_clk_clk or negedge hps_0_h2f_reset_reset_n)
		if (~hps_0_h2f_reset_reset_n)
			i2s_capture_fifo_write_synchro <= 0;
		else
			i2s_capture_fifo_write_synchro <= {i2s_capture_fifo_write_synchro[1:0], i2s_capture_fifo_write};
	assign i2s_output_apb_0_capture_fifo_write = i2s_capture_fifo_write_synchro[2] & ~i2s_capture_fifo_write_synchro[1];
	assign i2s_output_apb_0_capture_fifo_clk = clock_bridge_0_out_clk_clk;

	// Mux capture data
	assign i2s_output_apb_0_capture_fifo_data = i2s_clkctrl_apb_0_conduit_clk_sel_48_44 ?
		i2s_capture_fifo_data48 : i2s_capture_fifo_data44;

	// Mux out
	assign AUD_DACDAT = i2s_clkctrl_apb_0_conduit_clk_sel_48_44 ? i2s_data_out44 : i2s_data_out48;

	// Audio input
	assign i2s_data_in44 = AUD_ADCDAT;
	assign i2s_data_in48 = AUD_ADCDAT;
	//assign i2s_data_in44 = i2s_data_out44; // Loopback for testing
	//assign i2s_data_in48 = i2s_data_out48; // Loopback for testing
	
	// Audio clocks inouts
	assign AUD_BCLK = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_bclk : 1'bZ;
	assign AUD_DACLRCK = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_playback_lrclk : 1'bZ;
	assign AUD_ADCLRCK = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_capture_lrclk : 1'bZ;

	assign i2s_clkctrl_apb_0_ext_bclk = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_bclk : AUD_BCLK;
	assign i2s_clkctrl_apb_0_ext_playback_lrclk = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_playback_lrclk : AUD_DACLRCK;
	assign i2s_clkctrl_apb_0_ext_capture_lrclk = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_capture_lrclk : AUD_DACLRCK;
endmodule
