`include "AyyazTariq95Transaction.sv"
class Generator;

int transac_count;
bit [31:0]current_add,current_data,end_addr;
int numofbeats;
bit rand_me;
int tc = 1;
mailbox gene_to_driv;
Transaction transac;

function new(mailbox gene_to_driv);
	this.gene_to_driv = gene_to_driv;
endfunction


task SINGLEREAD(input bit [31:0]current_add, bit rand_me);
//$display("Generator asked for SINGLE READ\n");
bit [2:0] trans_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 0; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b0;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS = 2'b10;
rand_che = transac.randomize();	
gene_to_driv.put(transac);
$display("Single Burst sent to driver\n");
/*case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
transac = new;
this.transac.HADDR=current_add;
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b000;
this.transac.HTRANS = 3'b010;
gene_to_driv.put(transac);
$display("Address:0x%0h sent to driver\n",transac.HADDR);
numofbeats = numofbeats - 1;
repeat(numofbeats)	
begin
transac=new;
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b000;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to driver\n",transac.HADDR);	
current_add=current_add+trans_size ;
this.transac.HADDR = current_add;
end*/
endtask: SINGLEREAD

task SINGLEWRITE(input bit [31:0]current_add,bit[31:0] current_data,input bit rand_me);
//$display("Generator asked for SINGLE WRITE\n");
bit [2:0] trans_size;
bit rand_che;
transac = new;

if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
this.transac.HWDATA.rand_mode(0);
this.transac.HWDATA = current_data;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 1; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b0;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS = 2'b10;
rand_che = transac.randomize();	
gene_to_driv.put(transac);
$display("Single Burst sent to driver\n");
/*case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
transac = new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 1;
this.transac.HWDATA=current_data;
this.transac.HADDR=current_add;
this.transac.HBURST = 3'b000;
this.transac.HTRANS = 3'b010;
gene_to_driv.put(transac);
numofbeats = numofbeats - 1;
repeat(numofbeats)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 1;
this.transac.HWDATA=current_data;
this.transac.HBURST = 3'b000;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase
gene_to_driv.put(transac);
$display("Address:0x%0h and data:0x%0h\n",transac.HADDR,transac.HWDATA);	
current_add=current_add+trans_size ;
this.transac.HADDR = current_add;
end*/
endtask: SINGLEWRITE




task INCR4READ(input bit [31:0]current_add,input bit rand_me);
//$display("Generator asked for INCR4 READ\n");
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 0; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(3)	
begin
transac=new;
this.transac.HADDR.rand_mode(0);
this.transac.HADDR=current_add;	
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 0; 			
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HSIZE.rand_mode(0);
this.transac.HSIZE = addr_size; 
rand_che=transac.randomize();
current_add=current_add+trans_size;
this.transac.HADDR = current_add;
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
end
/*case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
transac = new;
//if (rand_me) transac.randomize();
this.transac.HADDR=current_add;
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b010;
gene_to_driv.put(transac);
$display("Address:0x%0h sent to driver\n",transac.HADDR);
repeat(3)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
current_add=current_add+trans_size ;
this.transac.HADDR = current_add;	
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end*/
endtask: INCR4READ




task INCR4WRITE(input bit [31:0]current_add,bit [31:0]current_data,input bit rand_me);
//$display("Generator asked for INCR4 WRITE\n");
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
this.transac.HWDATA.rand_mode(0);
this.transac.HWDATA = current_data;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 1; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(3)	
begin
transac=new;
this.transac.HADDR.rand_mode(0);
this.transac.HADDR=current_add;	
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 1; 			
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HSIZE.rand_mode(0);
this.transac.HSIZE = addr_size; 
rand_che=transac.randomize();
current_add=current_add+trans_size;
this.transac.HADDR = current_add;
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
end
/*case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
transac = new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 1;
this.transac.HWDATA=current_data;
this.transac.HADDR=current_add;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b010;
gene_to_driv.put(transac);
repeat(3)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 1;
this.transac.HWDATA=current_data;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);	
current_add=current_add+trans_size ;
this.transac.HADDR = current_add;
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end*/
endtask: INCR4WRITE


task INCR8READ(input bit [31:0]current_add,input bit rand_me);
//$display("Generator asked for INCR8 READ\n");
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 0; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b101;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(7)	
begin
transac=new;
this.transac.HADDR.rand_mode(0);
this.transac.HADDR=current_add;	
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 0; 			
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b101;
this.transac.HSIZE.rand_mode(0);
this.transac.HSIZE = addr_size; 
rand_che=transac.randomize();
current_add=current_add+trans_size;
this.transac.HADDR = current_add;
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
end
/*case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
transac = new;
//if (rand_me) transac.randomize();
this.transac.HADDR=current_add;
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b010;
gene_to_driv.put(transac);
$display("Address:0x%0h sent to driver\n",transac.HADDR);
repeat(7)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
current_add=current_add+trans_size ;
this.transac.HADDR = current_add;	
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end*/
endtask: INCR8READ






task INCR8WRITE(input bit [31:0]current_add,bit [31:0]current_data,input bit rand_me);
//$display("Generator asked for INCR8 WRITE\n");
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
this.transac.HWDATA.rand_mode(0);
this.transac.HWDATA = current_data;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 1; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b101;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(7)	
begin
transac=new;
this.transac.HADDR.rand_mode(0);
this.transac.HADDR=current_add;	
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 1; 			
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HSIZE.rand_mode(0);
this.transac.HSIZE = addr_size; 
rand_che=transac.randomize();
current_add=current_add+trans_size;
this.transac.HADDR = current_add;
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
end
/*case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
transac = new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 1;
this.transac.HWDATA=current_data;
this.transac.HADDR=current_add;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b010;
gene_to_driv.put(transac);
repeat(7)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 1;
this.transac.HWDATA=current_data;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);	
current_add=current_add+trans_size ;
this.transac.HADDR = current_add;
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end*/
endtask: INCR8WRITE




task INCR16READ(input bit [31:0]current_add,input bit rand_me);
//$display("Generator asked for INCR16 READ\n");
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 0; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b111;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(15)	
begin
transac=new;
this.transac.HADDR.rand_mode(0);
this.transac.HADDR=current_add;	
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 0; 			
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HSIZE.rand_mode(0);
this.transac.HSIZE = addr_size; 
rand_che=transac.randomize();
current_add=current_add+trans_size;
this.transac.HADDR = current_add;
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
end
/*case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
transac = new;
//if (rand_me) transac.randomize();
this.transac.HADDR=current_add;
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b010;
gene_to_driv.put(transac);
$display("Address:0x%0h sent to driver\n",transac.HADDR);
repeat(15)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
current_add=current_add+trans_size ;
this.transac.HADDR = current_add;	
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end*/
endtask: INCR16READ



task INCR16WRITE(input bit [31:0]current_add,bit [31:0]current_data,input bit rand_me);
//$display("Generator asked for INCR16 WRITE\n");
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
this.transac.HWDATA.rand_mode(0);
this.transac.HWDATA = current_data;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 1; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b101;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(15)	
begin
transac=new;
this.transac.HADDR.rand_mode(0);
this.transac.HADDR=current_add;	
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 1; 			
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HSIZE.rand_mode(0);
this.transac.HSIZE = addr_size; 
rand_che=transac.randomize();
current_add=current_add+trans_size;
this.transac.HADDR = current_add;
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
end
/*case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
transac = new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 1;
this.transac.HWDATA=current_data;
this.transac.HADDR=current_add;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b010;
gene_to_driv.put(transac);
repeat(15)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 1;
this.transac.HWDATA=current_data;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);	
current_add=current_add+trans_size ;
this.transac.HADDR = current_add;
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end*/
endtask: INCR16WRITE




task WRAP4READ(input bit [31:0]current_add, bit[31:0]end_addr);
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 0; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(3)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
current_add=current_add+trans_size ;
if(current_add >= end_addr)
begin
current_add = end_addr - (trans_size*3);
end
this.transac.HADDR = current_add;	
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end
endtask: WRAP4READ



task WRAP4WRITE(input bit [31:0]current_add, bit[31:0]end_addr,bit [31:0]current_data);
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
this.transac.HWDATA.rand_mode(0);
this.transac.HWDATA = current_data;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 1; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(3)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 1;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
current_add=current_add+trans_size ;
if(current_add >= end_addr)
begin
current_add = end_addr - (trans_size*3);
end
this.transac.HADDR = current_add;	
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end
endtask: WRAP4WRITE






task WRAP8READ(input bit [31:0]current_add, bit[31:0]end_addr);
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 0; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(7)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
current_add=current_add+trans_size ;
if(current_add >= end_addr)
begin
current_add = end_addr - (trans_size*3);
end
this.transac.HADDR = current_add;	
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end
endtask: WRAP8READ



task WRAP8WRITE(input bit [31:0]current_add, bit[31:0]end_addr,bit [31:0]current_data);
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
this.transac.HWDATA.rand_mode(0);
this.transac.HWDATA = current_data;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 1; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(7)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 1;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
current_add=current_add+trans_size ;
if(current_add >= end_addr)
begin
current_add = end_addr - (trans_size*3);
end
this.transac.HADDR = current_add;	
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end
endtask: WRAP8WRITE



task WRAP16READ(input bit [31:0]current_add, bit[31:0]end_addr);
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 0; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(15)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
current_add=current_add+trans_size ;
if(current_add >= end_addr)
begin
current_add = end_addr - (trans_size*3);
end
this.transac.HADDR = current_add;	
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end
endtask: WRAP16READ



task WRAP16WRITE(input bit [31:0]current_add, bit[31:0]end_addr,bit [31:0]current_data);
bit [2:0] trans_size,addr_size;
bit rand_che;
transac = new;
if (!rand_me)
begin
this.transac.HADDR.rand_mode(0);
this.transac.HADDR = current_add;
this.transac.HWDATA.rand_mode(0);
this.transac.HWDATA = current_data;
end
this.transac.HWRITE.rand_mode(0);
this.transac.HWRITE = 1; 
this.transac.HBURST.rand_mode(0);
this.transac.HBURST = 3'b011;
this.transac.HTRANS.rand_mode(0);
this.transac.HTRANS= 2'b10;
rand_che = transac.randomize();	
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
$display("Address:0x%0h sent to mailbox",transac.HADDR);
addr_size=this.transac.HSIZE;
current_add=this.transac.HADDR;
current_add=current_add+trans_size;
repeat(15)	
begin
transac=new;
//if (rand_me) transac.randomize();
this.transac.HWRITE = 1;
this.transac.HBURST = 3'b011;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
0 : trans_size = 1;
1 : trans_size = 2;
2 : trans_size = 4;
endcase 
gene_to_driv.put(transac);
current_add=current_add+trans_size ;
if(current_add >= end_addr)
begin
current_add = end_addr - (trans_size*3);
end
this.transac.HADDR = current_add;	
$display("Address:0x%0h sent to driver\n",transac.HADDR);
end
endtask: WRAP16WRITE



  task run_Gen(input bit [31:0]current_add,input bit [31:0]end_addr,input bit [31:0]current_data, input bit rand_me);
 repeat(transac_count) 
    begin 
    $display(" Generator says: This is my transaction number %0d",tc);
    gene_to_driv.put(transac);
    if(transac.HWRITE)
    begin
    case(transac.HTRANS)
    0:SINGLEWRITE(current_add,current_data,rand_me);
    1:SINGLEWRITE(current_add,current_data,rand_me);
    2:WRAP4WRITE(current_add,end_addr,current_data);
    3:INCR4WRITE(current_add,current_data,rand_me);
    4:WRAP8WRITE(current_add,end_addr,current_data);
    5:INCR8WRITE(current_add,current_data,rand_me);
    6:WRAP16WRITE(current_add,end_addr,current_data);
    7:INCR16WRITE(current_add,current_data,rand_me);
    endcase
    end
    if(!transac.HWRITE) 
    begin
    case(transac.HTRANS)
    0:SINGLEREAD(current_add,rand_me);
    1:SINGLEREAD(current_add,rand_me);
    2:WRAP4READ(current_add,end_addr);
    3:INCR4READ(current_add,rand_me);
    4:WRAP8READ(current_add,end_addr);
    5:INCR8READ(current_add,rand_me);
    6:WRAP16READ(current_add,end_addr);
    7:INCR16READ(current_add,rand_me);
    endcase
    end
    tc++;
    end
  endtask
`ifdef DEBUG
  `undef DEBUG
`endif
endclass: Generator

