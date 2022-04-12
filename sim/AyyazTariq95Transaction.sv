class Transaction;

rand bit[31:0] HADDR;
bit[31:0] HRDATA;
rand bit[31:0] HWDATA;
rand bit HWRITE; 
bit HREADY, HREADYOUT, HRESP;
rand bit[2:0] HSIZE, HBURST;
rand bit[3:0] HPROT;
rand bit[1:0] HSEL,HTRANS;

endclass: Transaction
