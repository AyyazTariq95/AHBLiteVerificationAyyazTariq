import ahb3lite_pkg::*;
`include "MP2Interface.sv"
`include "MP2TestProg.sv"
module top_tb;
  bit clk;
  bit reset;
  //reg curr_addr;
  //reg numofbeats;
  
  //clock generation
  always #5 clk = ~clk;
  
  //reset Generation
  //initial begin
  //  reset = 1;
  //  #5 reset =0;
  //end
  
  
  //creatinng instance of interface, inorder to connect DUT and testcase
  my_interface my_intf(clk,reset);
  //my_intf.HADDR <= 32'hcafe_dada;
  //Testcase instance, interface handle is passed to test as an argument
  Test t1(my_intf);
  
  //DUT instance, interface signals are connected to the DUT ports
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

//initial begin
//numofbeats = 6;
//curr_addr = 10;
//my_intf.HWRITE = 1'b1;
//my_intf.HADDR = 32'hcafe_dada;
//my_intf.HWDATA = 32'h1234_5678;
//#2
//my_intf.HWRITE = 1'b0;
//end
endmodule
