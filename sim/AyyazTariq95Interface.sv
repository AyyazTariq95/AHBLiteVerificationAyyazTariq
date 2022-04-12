interface my_interface(input bit HCLK, HRESETn);
logic HWRITE, HREADY, HREADYOUT, HRESP;
logic[31:0] HADDR, HWDATA, HRDATA;
logic[2:0] HSIZE, HBURST;
logic[3:0] HPROT;
logic[1:0] HSEL,HTRANS;

modport DUT(input HCLK, HRESETn, HSEL, HADDR, HWDATA, HWRITE, HSIZE, HBURST, HPROT, HTRANS, HREADY,
            output HRDATA, HREADYOUT, HRESP);

modport TEST(input HCLK, HRESETn, HRDATA, HREADYOUT, HRESP,
             output HSEL, HADDR, HRDATA, HWRITE, HSIZE, HBURST, HPROT, HTRANS, HREADY);

modport MON(input HCLK, HRDATA, HREADYOUT, HRESP);

endinterface
