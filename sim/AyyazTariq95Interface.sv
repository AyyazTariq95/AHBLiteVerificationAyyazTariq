interface my_interface(input logic HCLK, HRESETn);
logic HWRITE, HREADY, HREADYOUT, HRESP, HMASTLOCK;
logic[31:0] HADDR, HWDATA, HRDATA;
logic[2:0] HSIZE, HBURST;
logic[3:0] HPROT;
logic[1:0] HSEL,HTRANS;

modport dut(
      	input  		HRESETn,
      	input  		HCLK,
      	input   	HSEL,
  	input   	HADDR,
 	input   	HWDATA,
  	output 		HRDATA,
  	input           HWRITE,
  	input       	HSIZE,
  	input       	HBURST,
  	input       	HPROT,
  	input       	HTRANS,
        input           HMASTLOCK,
  	output 		HREADYOUT,
  	input           HREADY,
  	output          HRESP
  );
 modport driver(
      	input  	        HRESETn,
      	input  	        HCLK,
      	output   	HSEL,
  	output   	HADDR,
 	output   	HWDATA,
  	output          HWRITE,
  	output       	HSIZE,
  	output       	HBURST,
  	output       	HPROT,
  	output       	HTRANS,
  	input           HREADY,
        output          HMASTLOCK,
	input           HRDATA,
	input           HRESP
  );

 modport monitor(
	input  		HRESETn,
      	input  		HCLK,
      	input   	HSEL,
  	input   	HADDR,
 	input   	HWDATA,
  	input           HWRITE,
  	input       	HSIZE,
  	input       	HBURST,
  	input       	HPROT,
  	input       	HTRANS,
        input           HMASTLOCK,
  	input           HREADY,	
	input 		HRDATA,
	input 		HREADYOUT,
	input          HRESP);

endinterface

