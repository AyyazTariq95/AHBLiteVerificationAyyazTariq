interface wrap_my_interface (input bit HCLK, HRESETn);

logic HWRITE, HREADY, HREADYOUT, HRESP;
logic[31:0] HADDR, HWDATA, HRDATA;
logic[2:0] HSIZE, HBURST;
logic[3:0] HPROT;
logic[1:0] HSEL,HTRANS;

endinterface

module wrap_for_DUT (wif, mif);

wrap_my_interface wif;
my_interface mif;

assign wif.HCLK = mif.HCLK;
assign wif.RESETn = mif.RESETn;
assign wif.HWRITE = mif.HWRITE;
assign wif.HREADY = mif.HREADY;
assign wif.HREADYOUT = mif.HREADYOUT;
assign wif.HRESP = mif.HRESP;
assign wif.HADDR = mif.HADDR;
assign wif.HWDATA = mif.HWDATA;
assign wif.HRDATA = mif.HRDATA;
assign wif.HSIZE = mif.HSIZE;
assign wif.HBURST = mif.HBURST;
assign wif.HPROT = mif.HPROT;
assign wif.HSEL = mif.HSEL;
assign wif.HTRANS = mif.HTRANS;

endmodule
