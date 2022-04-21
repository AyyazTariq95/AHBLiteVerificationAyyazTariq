interface my_wrapper (input bit HCLK,HRESETn);
   logic [31:0] HADDR;
   logic [31:0] HRDATA;
   logic [31:0] HWDATA;
   logic [3:0] HPROT;
   logic [2:0] HSIZE;
   logic [2:0] HBURST;
   logic [1:0] HTRANS, HSEL;
   logic HREADY, HREADYOUT, HRESP, HWRITE;
endinterface : my_wrapper

module my_interfacewrapper (w_if, i_if);
    my_wrapper w_if;
    my_interface i_if;
    assign w_if.HADDR = i_if.HADDR;
    assign w_if.HRDATA = i_if.HRDATA;
    assign w_if.HWDATA = i_if.HWDATA;
    assign w_if.HPROT = i_if.HPROT;
    assign w_if.HSIZE = i_if.HSIZE;
    assign w_if.HBURST = i_if.HBURST;
    assign w_if.HTRANS = i_if.HTRANS;
    assign w_if.HSEL = i_if.HSEL;
    assign w_if.HREADY = i_if.HREADY;
    assign w_if.HREADYOUT = i_if.HREADYOUT;
    assign w_if.HRESP = i_if.HRESP;
    assign w_if.HWRITE = i_if.HWRITE;
    assign w_if.HCLK = i_if.HCLK;
    assign w_if.HRESETn = i_if.HRESETn;
endmodule: my_interfacewrapper
