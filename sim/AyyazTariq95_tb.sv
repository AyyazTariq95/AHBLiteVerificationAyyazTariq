import ahb3lite_pkg::*;
`include "AyyazTariq95Interface.sv"
`include "AyyazTariq95TestProg.sv"
module AyyazTariq95_tb;
  bit clk;
  bit reset;
  //reg curr_addr;
  //reg numofbeats;
  //clock generation
  always #5 clk = ~clk;
  my_interface my_intf(clk,reset);
  //my_intf.HADDR <= 32'hcafe_dada;
  Test t1(my_intf);
   ahb3lite_sram1rw DUT(	
				.HRESETn (my_intf.HRESETn),
				.HCLK	(my_intf.HCLK),
				.HSEL	(my_intf.HSEL),
				.HADDR	(my_intf.HADDR),
				.HWDATA	(my_intf.HWDATA),
				.HRDATA	(my_intf.HRDATA),
				.HWRITE	(my_intf.HWRITE),
				.HSIZE	(my_intf.HSIZE),
				.HBURST	(my_intf.HBURST),
				.HPROT	(my_intf.HPROT),
				.HTRANS	(my_intf.HTRANS),
				.HREADYOUT(my_intf.HREADYOUT),
				.HREADY	(my_intf.HREADY),
				.HRESP	(my_intf.HRESP)	
                               );
endmodule
