typedef enum {SINGLE, UNDEFINED, INCR4, WRAP4, INCR8, WRAP8, INCR16, WRAP16} burst_type;
burst_type btype;

typedef enum {IDL, BSY, NSEQ, SEQ} trans_type;
trans_type trtype;

typedef enum {Byt, SWORD, WORD} size_type;
size_type sztype;

class lastaddress;
rand bit[31:0] addr;
rand bit[31:0] low_addr;
constraint addr_range {addr > low_addr};

function new(bit[31:0] low_addr);
	this.low_addr = low_addr;  
endfunction
endclass: lastaddress


class Generator;

virtual my_interface.TEST myin_gen;
mailbox #(Transaction) genetodriv;

function new(mailbox genetodriv);
	this.myin_gen = myin_gen;
	this.genetodriv = genetodriv;
endfunction


task SINGLEREAD(integer numofbeats);
transac = new;
this.transac.HADDR=current_add;
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b000;
this.transac.HTRANS = 3'b010;
genetodriv.put(transac);
numofbeats = numofbeats - 1;
repeat(numofbeats)	
begin
transac=new;
this.transac.HWRITE = 0;
this.transac.HBURST = 3'b000;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
genetodriv.put(transac);	
current_add=current_add+trans_size ;
this.transac.HADDR = current_add;
end
endtask: SINGLEREAD

task SINGLEWRITE(integer numofbeats);
transac = new;
this.transac.HWRITE = 1;
this.transac.HWDATA=current_data;
this.transac.HADDR=current_add;
this.transac.HBURST = 3'b000;
this.transac.HTRANS = 3'b010;
genetodriv.put(transac);
numofbeats = numofbeats - 1;
repeat(numofbeats)	
begin
transac=new;
this.transac.HWRITE = 1;
this.transac.HWDATA=current_data;
this.transac.HBURST = 3'b000;
this.transac.HTRANS = 3'b011;
this.transac.HSIZE = 3'b010;
case(transac.HSIZE)
3'b000 : trans_size = 1;
3'b001 : trans_size = 2;
3'b010 : trans_size = 4;
endcase 
genetodriv.put(transac);	
current_add=current_add+trans_size ;
this.transac.HADDR = current_add;
end
endtask: SINGLEWRITE



task gen_read_burst;
Transaction transac;
case(btype)
SINGLE : 
begin
transac = new(b.start_addr);
genetodriv.put(transac);
end
INCR4 : 
begin
for(int i=0; i<=3;i++)
begin
transac = new(b.start_addr+(32*i));
genetodriv.put(transac);
end
end

WRAP4 :
begin
for(int i=0; i<=3;i++)
begin
if(b.start_addr+(32*i) == b.end_addr-32)
begin
transac = new(b.start_addr+(32*i));
genetodriv.put(transac);
if(i == 0)
begin
transac = new(b.end_addr-128);
genetodriv.put(transac);
transac = new(b.end_addr-96);
genetodriv.put(transac);
transac = new(b.end_addr-64);
genetodriv.put(transac); 
end
if(i == 1)
begin
transac = new(b.end_addr-128);
genetodriv.put(transac);
transac = new(b.end_addr-96);
genetodriv.put(transac);
end
if(i == 2)
begin
transac = new(b.end_addr-128);
genetodriv.put(transac);
end
end
else
begin
transac = new(b.start_addr+(32*i));
genetodriv.put(transac);
end
end
end

INCR8 :
begin 
for(int i=0; i<=7;i++)
begin
transac = new(b.start_addr+(32*i));
genetodriv.put(transac);
end
end

WRAP8 :
begin 
for(int i=0; i<=7;i++)
begin
if(b.start_addr+(32*i) == b.end_addr-32)
begin
transac = new(b.start_addr+(32*i));
genetodriv.put(transac);
if(i == 0)
begin
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
transac = new(b.end_addr-192);
genetodriv.put(transac);
transac = new(b.end_addr-160);
genetodriv.put(transac);
transac = new(b.end_addr-128);
genetodriv.put(transac);
transac = new(b.end_addr-96);
genetodriv.put(transac);
transac = new(b.end_addr-64);
genetodriv.put(transac); 
end
if(i == 1)
begin
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
transac = new(b.end_addr-192);
genetodriv.put(transac);
transac = new(b.end_addr-160);
genetodriv.put(transac);
transac = new(b.end_addr-128);
genetodriv.put(transac);
transac = new(b.end_addr-96);
genetodriv.put(transac);
end
if(i == 2)
begin
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
transac = new(b.end_addr-192);
genetodriv.put(transac);
transac = new(b.end_addr-160);
genetodriv.put(transac);
transac = new(b.end_addr-128);
genetodriv.put(transac);
end
if(i == 3)
begin
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
transac = new(b.end_addr-192);
genetodriv.put(transac);
transac = new(b.end_addr-160);
genetodriv.put(transac);
end
if(i == 4)
begin
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
transac = new(b.end_addr-192);
genetodriv.put(transac);
end
if(i == 5)
begin
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
end
if(i == 6)
begin
transac = new(b.end_addr-256);
genetodriv.put(transac);
end
end
else
begin
transac = new(b.start_addr+(32*i));
genetodriv.put(transac);
end
end
end

INCR16 :
begin 
for(int i=0; i<=15;i++)
begin
transac = new(b.start_addr+(32*i));
genetodriv.put(transac);
end
end

WRAP16 :
begin 
for(int i=0; i<=15;i++)
begin
if(b.start_addr+(32*i) == b.end_addr-32)
begin
transac = new(b.start_addr+(32*i));
genetodriv.put(transac);
if(i == 0)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
transac = new(b.end_addr-384);
genetodriv.put(transac);
transac = new(b.end_addr-352);
genetodriv.put(transac);
transac = new(b.end_addr-320);
genetodriv.put(transac); 
transac = new(b.end_addr-288);
genetodriv.put(transac);
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
transac = new(b.end_addr-192);
genetodriv.put(transac);
transac = new(b.end_addr-160);
genetodriv.put(transac);
transac = new(b.end_addr-128);
genetodriv.put(transac);
transac = new(b.end_addr-96);
genetodriv.put(transac);
transac = new(b.end_addr-64);
genetodriv.put(transac);
end
if(i == 1)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
transac = new(b.end_addr-384);
genetodriv.put(transac);
transac = new(b.end_addr-352);
genetodriv.put(transac);
transac = new(b.end_addr-320);
genetodriv.put(transac); 
transac = new(b.end_addr-288);
genetodriv.put(transac);
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
transac = new(b.end_addr-192);
genetodriv.put(transac);
transac = new(b.end_addr-160);
genetodriv.put(transac);
transac = new(b.end_addr-128);
genetodriv.put(transac);
transac = new(b.end_addr-96);
genetodriv.put(transac);
end
if(i == 2)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
transac = new(b.end_addr-384);
genetodriv.put(transac);
transac = new(b.end_addr-352);
genetodriv.put(transac);
transac = new(b.end_addr-320);
genetodriv.put(transac); 
transac = new(b.end_addr-288);
genetodriv.put(transac);
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
transac = new(b.end_addr-192);
genetodriv.put(transac);
transac = new(b.end_addr-160);
genetodriv.put(transac);
transac = new(b.end_addr-128);
genetodriv.put(transac);
end
if(i == 3)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
transac = new(b.end_addr-384);
genetodriv.put(transac);
transac = new(b.end_addr-352);
genetodriv.put(transac);
transac = new(b.end_addr-320);
genetodriv.put(transac); 
transac = new(b.end_addr-288);
genetodriv.put(transac);
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
transac = new(b.end_addr-192);
genetodriv.put(transac);
transac = new(b.end_addr-160);
genetodriv.put(transac);
end
if(i == 4)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
transac = new(b.end_addr-384);
genetodriv.put(transac);
transac = new(b.end_addr-352);
genetodriv.put(transac);
transac = new(b.end_addr-320);
genetodriv.put(transac); 
transac = new(b.end_addr-288);
genetodriv.put(transac);
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
transac = new(b.end_addr-192);
genetodriv.put(transac);
end
if(i == 5)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
transac = new(b.end_addr-384);
genetodriv.put(transac);
transac = new(b.end_addr-352);
genetodriv.put(transac);
transac = new(b.end_addr-320);
genetodriv.put(transac); 
transac = new(b.end_addr-288);
genetodriv.put(transac);
transac = new(b.end_addr-256);
genetodriv.put(transac);
transac = new(b.end_addr-224);
genetodriv.put(transac);
end
if(i == 6)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
transac = new(b.end_addr-384);
genetodriv.put(transac);
transac = new(b.end_addr-352);
genetodriv.put(transac);
transac = new(b.end_addr-320);
genetodriv.put(transac); 
transac = new(b.end_addr-288);
genetodriv.put(transac);
transac = new(b.end_addr-256);
genetodriv.put(transac);
end
if(i == 7)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
transac = new(b.end_addr-384);
genetodriv.put(transac);
transac = new(b.end_addr-352);
genetodriv.put(transac);
transac = new(b.end_addr-320);
genetodriv.put(transac); 
transac = new(b.end_addr-288);
genetodriv.put(transac);
end
if(i == 8)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
transac = new(b.end_addr-384);
genetodriv.put(transac);
transac = new(b.end_addr-352);
genetodriv.put(transac);
transac = new(b.end_addr-320);
genetodriv.put(transac); 
end
if(i == 9)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
transac = new(b.end_addr-384);
genetodriv.put(transac);
transac = new(b.end_addr-352);
genetodriv.put(transac); 
end
if(i == 10)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
transac = new(b.end_addr-384);
genetodriv.put(transac);
end
if(i == 11)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
transac = new(b.end_addr-416);
genetodriv.put(transac);
end
if(i == 12)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
transac = new(b.end_addr-448);
genetodriv.put(transac);
end
if(i == 13)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
transac = new(b.end_addr-480);
genetodriv.put(transac);
end
if(i == 14)
begin
transac = new(b.end_addr-512);
genetodriv.put(transac);
end
end
else
begin
transac = new(b.start_addr+(32*i));
genetodriv.put(transac);
end
end
end
UNDEFINED: 
begin
transac = new(b.start_addr);
genetodriv.put(transac);
b.start_addr = b.start_addr+32;
end
endcase
endtask: read_burst


task write_burst(Burst b,data);
WriteTransaction transact;
case(b.btype)
SINGLE : 
begin
transact = new(b.start_addr,data);
genetodriv.put(transact);
end

INCR4 : 
begin
for(int i=0; i<=3;i++)
begin
transact = new(b.start_addr+(32*i),data);
genetodriv.put(transact);
end
end

WRAP4 :
begin
for(int i=0; i<=3;i++)
begin
if(b.start_addr+(32*i) == b.end_addr-32)
begin
transact = new(b.start_addr+(32*i),data);
genetodriv.put(transact);
if(i == 0)
begin
transact = new(b.end_addr-128,data);
genetodriv.put(transact);
transact = new(b.end_addr-96,data);
genetodriv.put(transact);
transact = new(b.end_addr-64,data);
genetodriv.put(transact); 
end
if(i == 1)
begin
transact = new(b.end_addr-128,data);
genetodriv.put(transact);
transact = new(b.end_addr-96,data);
genetodriv.put(transact);
end
if(i == 2)
begin
transact = new(b.end_addr-128,data);
genetodriv.put(transact);
end
else
begin
transact = new(b.start_addr+(32*i),data);
genetodriv.put(transact);
end
end
end

INCR8 :
begin 
for(int i=0; i<=7;i++)
begin
transact = new(b.start_addr+(32*i),data);
genetodriv.put(transact);
end
end

WRAP8 :
begin 
for(int i=0; i<=7;i++)
begin
if(b.start_addr+(32*i) == b.end_addr-32)
begin
transact = new(b.start_addr+(32*i),data);
genetodriv.put(transact);
if(i == 0)
begin
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
transact = new(b.end_addr-192,data);
genetodriv.put(transact);
transact = new(b.end_addr-160,data);
genetodriv.put(transact);
transact = new(b.end_addr-128,data);
genetodriv.put(transact);
transact = new(b.end_addr-96,data);
genetodriv.put(transact);
transact = new(b.end_addr-64,data);
genetodriv.put(transact); 
end
if(i == 1)
begin
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
transact = new(b.end_addr-192,data);
genetodriv.put(transact);
transact = new(b.end_addr-160,data);
genetodriv.put(transact);
transact = new(b.end_addr-128,data);
genetodriv.put(transact);
transact = new(b.end_addr-96,data);
genetodriv.put(transact);
end
if(i == 2)
begin
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
transact = new(b.end_addr-192,data);
genetodriv.put(transact);
transact = new(b.end_addr-160,data);
genetodriv.put(transact);
transact = new(b.end_addr-128,data);
genetodriv.put(transact);
end
if(i == 3)
begin
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
transact = new(b.end_addr-192,data);
genetodriv.put(transact);
transact = new(b.end_addr-160,data);
genetodriv.put(transact);
end
if(i == 4)
begin
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
transact = new(b.end_addr-192,data);
genetodriv.put(transact);
end
if(i == 5)
begin
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
end
if(i == 6)
begin
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
end
else
begin
transact = new(b.start_addr+(32*i),data);
genetodriv.put(transact);
end
end
end

INCR16 :
begin 
for(int i=0; i<=15;i++)
begin
transact = new(b.start_addr+(32*i),data);
genetodriv.put(transact);
end
end

WRAP16 :
begin 
for(int i=0; i<=15;i++)
begin
if(b.start_addr+(32*i) == b.end_addr-32)
begin
transact = new(b.start_addr+(32*i),data);
genetodriv.put(transact);
if(i == 0)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
transact = new(b.end_addr-384,data);
genetodriv.put(transact);
transact = new(b.end_addr-352,data);
genetodriv.put(transact);
transact = new(b.end_addr-320,data);
genetodriv.put(transact); 
transact = new(b.end_addr-288,data);
genetodriv.put(transact);
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
transact = new(b.end_addr-192,data);
genetodriv.put(transact);
transact = new(b.end_addr-160,data);
genetodriv.put(transact);
transact = new(b.end_addr-128,data);
genetodriv.put(transact);
transact = new(b.end_addr-96,data);
genetodriv.put(transact);
transact = new(b.end_addr-64,data);
genetodriv.put(transact);
end
if(i == 1)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
transact = new(b.end_addr-384,data);
genetodriv.put(transact);
transact = new(b.end_addr-352,data);
genetodriv.put(transact);
transact = new(b.end_addr-320,data);
genetodriv.put(transact); 
transact = new(b.end_addr-288,data);
genetodriv.put(transact);
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
transact = new(b.end_addr-192,data);
genetodriv.put(transact);
transact = new(b.end_addr-160,data);
genetodriv.put(transact);
transact = new(b.end_addr-128,data);
genetodriv.put(transact);
transact = new(b.end_addr-96,data);
genetodriv.put(transact);
end
if(i == 2)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
transact = new(b.end_addr-384,data);
genetodriv.put(transact);
transact = new(b.end_addr-352,data);
genetodriv.put(transact);
transact = new(b.end_addr-320,data);
genetodriv.put(transact); 
transact = new(b.end_addr-288,data);
genetodriv.put(transact);
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
transact = new(b.end_addr-192,data);
genetodriv.put(transact);
transact = new(b.end_addr-160,data);
genetodriv.put(transact);
transact = new(b.end_addr-128,data);
genetodriv.put(transact);
end
if(i == 3)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
transact = new(b.end_addr-384,data);
genetodriv.put(transact);
transact = new(b.end_addr-352,data);
genetodriv.put(transact);
transact = new(b.end_addr-320,data);
genetodriv.put(transact); 
transact = new(b.end_addr-288,data);
genetodriv.put(transact);
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
transact = new(b.end_addr-192,data);
genetodriv.put(transact);
transact = new(b.end_addr-160,data);
genetodriv.put(transact);
end
if(i == 4)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
transact = new(b.end_addr-384,data);
genetodriv.put(transact);
transact = new(b.end_addr-352,data);
genetodriv.put(transact);
transact = new(b.end_addr-320,data);
genetodriv.put(transact); 
transact = new(b.end_addr-288,data);
genetodriv.put(transact);
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
transact = new(b.end_addr-192,data);
genetodriv.put(transact);
end
if(i == 5)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
transact = new(b.end_addr-384,data);
genetodriv.put(transact);
transact = new(b.end_addr-352,data);
genetodriv.put(transact);
transact = new(b.end_addr-320,data);
genetodriv.put(transact); 
transact = new(b.end_addr-288,data);
genetodriv.put(transact);
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
transact = new(b.end_addr-224,data);
genetodriv.put(transact);
end
if(i == 6)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
transact = new(b.end_addr-384,data);
genetodriv.put(transact);
transact = new(b.end_addr-352,data);
genetodriv.put(transact);
transact = new(b.end_addr-320,data);
genetodriv.put(transact); 
transact = new(b.end_addr-288,data);
genetodriv.put(transact);
transact = new(b.end_addr-256,data);
genetodriv.put(transact);
end
if(i == 7)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
transact = new(b.end_addr-384,data);
genetodriv.put(transact);
transact = new(b.end_addr-352,data);
genetodriv.put(transact);
transact = new(b.end_addr-320,data);
genetodriv.put(transact); 
transact = new(b.end_addr-288,data);
genetodriv.put(transact);
end
if(i == 8)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
transact = new(b.end_addr-384,data);
genetodriv.put(transact);
transact = new(b.end_addr-352,data);
genetodriv.put(transact);
transact = new(b.end_addr-320,data);
genetodriv.put(transact); 
end
if(i == 9)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
transact = new(b.end_addr-384,data);
genetodriv.put(transact);
transact = new(b.end_addr-352,data);
genetodriv.put(transact); 
end
if(i == 10)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
transact = new(b.end_addr-384,data);
genetodriv.put(transact);
end
if(i == 11)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
transact = new(b.end_addr-416,data);
genetodriv.put(transact);
end
if(i == 12)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
transact = new(b.end_addr-448,data);
genetodriv.put(transact);
end
if(i == 13)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
transact = new(b.end_addr-480,data);
genetodriv.put(transact);
end
if(i == 14)
begin
transact = new(b.end_addr-512,data);
genetodriv.put(transact);
end
else
begin
transact = new(b.start_addr+(32*i),data);
genetodriv.put(transact);
end
end
end

UNDEFINED: 
begin
transact = new(b.start_addr,data);
genetodriv.put(transact);
end
endcase 
endtask
endclass
