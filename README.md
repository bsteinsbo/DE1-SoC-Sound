This project contains IP cores and Linux ALSA SOC device drivers to play
sound on Altera's DE1-SoC development board.

The long-term goal of the project is to connect multiple external audio DACs
to the DE1-SoC, connect the outputs of the DACs to multiple power amplifiers,
and implement a digital sound processor with FIR filters in the FPGA.

As a first step towards this goal, the project interfaces the built-in WM8731
codec to an i2s interface.

In parallel with the hardware development, Linux drivers for the ALSA SOC
framework has also been developed.

Random notes:

The DMA interface between the FPGA and the ARM PLC330 DMA controller must be
brought out of reset for DMA to work.  This can either be done by creating a
new SPL, or by software setting the right registers after Linux has booted.

I don't use the Altera workflow to create the DTS (device tree), instead the
standard Linux DTS has been copied and modified to support the design.  Please
see "socfpga_cyclone5_DE1-SoC.dts" for my current DTS.

Only Linux kernel 3.17 has been used, from the rocketboard socfpga-3.17 branch.
I intend to upgrade to 4.0 when that is available.  The wm8731.c driver has no
support for 32-bit word lengths.  Until this has been merged, please apply
"wm8731-add-support-for-32-bit-word-length.patch". The patch is based on 3.17.
Please find my current Linux configuration in "Linux-config"  

The hardware I intend to connect to the DE1-SoC board includes high-precision
oscillators which can produce the necessary clocks for 48/96kHz and
44.1/88.2kHz sample rates without using a PLL.  For testing purposes, a PLL
has been synthesized with outputs similar to the TCXOs that I intend to use.

The cores have an APB interface, making them easier to integrate in a Xilinx
Zynq FPGA design.

Be careful when driving the i2c bus for controlling the codec. I reduced
drive strength and enabled the internal pullup to make it work.  I'm not
sure if only one of these measures would have been enough, but it has been
stable with the current pin assignments. 

Development is much easier when running from NFS.  The SD card contains SPL
and u-boot, but the linux kernel, FPGA configuration data and the root file
system are all accessed over the network.  I'm using Linaro Ubuntu rootfs,
see e.g. http://elinux.org/Parallella_NFS_rootfs_Setup for setup instructions.
