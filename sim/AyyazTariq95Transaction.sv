class Transaction;

	rand bit   [31:0] HWDATA; 
 	rand bit   [31:0] HADDR; 	
	rand bit   [2:0]  HSIZE;	  
	rand bit   [2:0]  HBURST;  
	rand bit   [1:0]  HTRANS;  
  rand bit   [3:0]  HPROT;  
	rand bit          HWRITE; 
	rand bit 	  HSEL; 
	bit	   [31:0] HRDATA;   
	bit 	   	  HRESP; 
	bit	          HREADY;
	bit		  HREADYOUT;

endclass: Transaction
