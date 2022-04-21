import ahb3lite_pkg::*;
module ahb3lite_sram1rw #(
  parameter MEM_SIZE          = 0,   //Memory in Bytes
  parameter MEM_DEPTH         = 256, //Memory depth
  parameter HADDR_SIZE        = 8,
  parameter HDATA_SIZE        = 32,
  parameter TECHNOLOGY        = "GENERIC",
  parameter REGISTERED_OUTPUT = "NO",
  parameter INIT_FILE         = ""
)
(
  input                       HRESETn,
                              HCLK,

  //AHB Slave Interfaces (receive data from AHB Masters)
  //AHB Masters connect to these ports
  input                       HSEL,
  input      [HADDR_SIZE-1:0] HADDR,
  input      [HDATA_SIZE-1:0] HWDATA,
  output reg [HDATA_SIZE-1:0] HRDATA,
  input                       HWRITE,
  input                 [2:0] HSIZE,
  input                 [2:0] HBURST,
  input                 [3:0] HPROT,
  input                 [1:0] HTRANS,
  output reg                  HREADYOUT,
  input                       HREADY,
  output                      HRESP
);


  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //
  import ahb3lite_pkg::*;

  localparam BE_SIZE        = (HDATA_SIZE+7)/8;       

  localparam MEM_SIZE_DEPTH = 8*MEM_SIZE / HDATA_SIZE;
  localparam REAL_MEM_DEPTH = MEM_DEPTH > MEM_SIZE_DEPTH ? MEM_DEPTH : MEM_SIZE_DEPTH;       // the greater one between MEM_DEPTH and MEM_SIZE_DEPTH
  localparam MEM_ABITS      = $clog2(REAL_MEM_DEPTH);                                       // number of bits
  localparam MEM_ABITS_LSB  = $clog2(BE_SIZE);                                             // number of bits
  

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  logic                  ahb_write,
                         ahb_read,
                         ahb_noseq,
                         was_ahb_noseq;

  logic                  we;
  logic [BE_SIZE   -1:0] be;
  logic [MEM_ABITS -1:0] raddr,
                         waddr;

  logic [HADDR_SIZE-1:0] nxt_adr;

  logic                  contention,
                         use_local_dout;
  logic [HDATA_SIZE-1:0] dout,
                         dout_local;


  //////////////////////////////////////////////////////////////////
  //
  // Functions
  //
  function automatic logic [6:0] address_offset;
    //returns a mask for the lesser bits of the address
    //meaning bits [  0] for 16bit data
    //             [1:0] for 32bit data
    //             [2:0] for 64bit data
    //etc

    //default value, prevent warnings
    address_offset = 0;
	 
    //What are the lesser bits in HADDR?
    case (HDATA_SIZE)
          1024: address_offset = 7'b111_1111; 
           512: address_offset = 7'b011_1111;
           256: address_offset = 7'b001_1111;
           128: address_offset = 7'b000_1111;
            64: address_offset = 7'b000_0111;
            32: address_offset = 7'b000_0011;
            16: address_offset = 7'b000_0001;
       default: address_offset = 7'b000_0000;
    endcase
  endfunction : address_offset


  function automatic logic [BE_SIZE-1:0] gen_be;
    input            [2:0] hsize;
    input [HADDR_SIZE-1:0] haddr;

    logic [127:0] full_be;
    logic [  6:0] haddr_masked;

    //get number of active lanes for a 1024bit databus (max width) for this HSIZE
    case (hsize)
       HSIZE_B1024: full_be = {128{1'b1}};
       HSIZE_B512 : full_be = { 64{1'b1}};
       HSIZE_B256 : full_be = { 32{1'b1}};
       HSIZE_B128 : full_be = { 16{1'b1}};
       HSIZE_DWORD: full_be = {  8{1'b1}};
       HSIZE_WORD : full_be = {  4{1'b1}};
       HSIZE_HWORD: full_be = {  2{1'b1}};
       default    : full_be = {  1{1'b1}};
    endcase

    //generate masked address
    haddr_masked = haddr & address_offset();

    //create byte-enable
    gen_be = full_be[BE_SIZE-1:0] << haddr_masked;
  endfunction : gen_be


  function automatic logic [HADDR_SIZE-1:0] gen_nxt_adr_incr;
    //Returns the next address for an incrementing burst
    input [HADDR_SIZE-1:0] cur_adr;
    input [HSIZE_SIZE-1:0] hsize;

    case (hsize)
       HSIZE_B1024: gen_nxt_adr_incr = cur_adr + 'h128;
       HSIZE_B512 : gen_nxt_adr_incr = cur_adr + 'h 64;
       HSIZE_B256 : gen_nxt_adr_incr = cur_adr + 'h 32;
       HSIZE_B128 : gen_nxt_adr_incr = cur_adr + 'h 16;
       HSIZE_DWORD: gen_nxt_adr_incr = cur_adr + 'h 8;
       HSIZE_WORD : gen_nxt_adr_incr = cur_adr + 'h 4;
       HSIZE_HWORD: gen_nxt_adr_incr = cur_adr + 'h 2;
       default    : gen_nxt_adr_incr = cur_adr + 'h 1;
    endcase
  endfunction : gen_nxt_adr_incr;


  function automatic logic [HADDR_SIZE-1:0] gen_nxt_adr_wrap;
    //Returns the next address for a wrapping burst
    input [HADDR_SIZE -1:0] cur_adr;
    input [HSIZE_SIZE -1:0] hsize;
    input [HBURST_SIZE-1:0] hburst;

    logic [HADDR_SIZE-1:0] mask;

    //mask cur_adr
    case (hburst)
      HBURST_WRAP16: mask = { {HADDR_SIZE-4{1'b1}}, 4'h0};
      HBURST_WRAP8 : mask = { {HADDR_SIZE-3{1'b1}}, 3'h0};
      default      : mask = { {HADDR_SIZE-2{1'b1}}, 2'h0};
    endcase

    //mask depends on transfer size
    case (hsize)
       HSIZE_B1024: mask = mask << 64;
       HSIZE_B512 : mask = mask << 32;
       HSIZE_B256 : mask = mask << 16;
       HSIZE_B128 : mask = mask <<  8;
       HSIZE_DWORD: mask = mask <<  4;
       HSIZE_WORD : mask = mask <<  2;
       HSIZE_HWORD: mask = mask <<  1;
       default    : mask = mask <<  0;
    endcase

    //nxt wrapped address
    gen_nxt_adr_wrap = (cur_adr & mask) | (gen_nxt_adr_incr(cur_adr,hsize) & ~mask);
  endfunction : gen_nxt_adr_wrap;


  function automatic logic [HADDR_SIZE-1:0] gen_nxt_adr;
    //returns next expected address
    input [HADDR_SIZE -1:0] cur_adr;
    input [HSIZE_SIZE -1:0] hsize;
    input [HBURST_SIZE-1:0] hburst;

    case (hburst)
      HBURST_WRAP16: gen_nxt_adr = gen_nxt_adr_wrap(cur_adr, hsize, hburst);
      HBURST_WRAP8 : gen_nxt_adr = gen_nxt_adr_wrap(cur_adr, hsize, hburst);
      HBURST_WRAP4 : gen_nxt_adr = gen_nxt_adr_wrap(cur_adr, hsize, hburst);
      default      : gen_nxt_adr = gen_nxt_adr_incr(cur_adr, hsize);
    endcase

  endfunction : gen_nxt_adr;


  function automatic logic [HDATA_SIZE-1:0] gen_val;
    //Returns the new value for a register
    // if be[n] == '1' then gen_val[byte_n] = new_val[byte_n]
    // else                 gen_val[byte_n] = old_val[byte_n]
    input [HDATA_SIZE-1:0] old_val,
                           new_val;
    input [BE_SIZE   -1:0] be;

    for (int n=0; n < BE_SIZE; n++)
      gen_val[n*8 +: 8] = be[n] ? new_val[n*8 +: 8] : old_val[n*8 +: 8];
  endfunction : gen_val


  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //AHB read/write cycle...
  assign ahb_noseq = !HSEL || (HTRANS == HTRANS_IDLE) || (HTRANS == HTRANS_NONSEQ);
  assign ahb_write = HSEL &  HWRITE & (HTRANS != HTRANS_BUSY) & (HTRANS != HTRANS_IDLE);
  assign ahb_read  = HSEL & ~HWRITE & (HTRANS != HTRANS_BUSY) & (HTRANS != HTRANS_IDLE);

  always @(posedge HCLK, negedge HRESETn)
    if      (!HRESETn) was_ahb_noseq <= 1'b1;
    else               was_ahb_noseq <= ahb_noseq;


  //generate internal write signal
  //This causes read/write contention, which is handled by memory
  always @(posedge HCLK)
    if (HREADY) we <= ahb_write;
    else        we <= 1'b0;

  //decode Byte-Enables
  always @(posedge HCLK)
    if (HREADY) be <= gen_be(HSIZE,HADDR);

  //read address
  assign nxt_adr = gen_nxt_adr(HADDR, HSIZE, HBURST);
  assign raddr = !was_ahb_noseq && !ahb_noseq ? nxt_adr[MEM_ABITS_LSB +: MEM_ABITS] : HADDR[MEM_ABITS_LSB +: MEM_ABITS]; 

  //store write address
  always @(posedge HCLK)
    if (HREADY) waddr <= raddr;


  /*
   * Hookup Memory Wrapper
   * Use two-port memory, due to pipelined AHB bus;
   *   the actual write to memory is 1 cycle late, causing read/write overlap
   * This assumes there are input registers on the memory
   */
  rl_ram_1r1w #(
    .ABITS      ( MEM_ABITS  ),
    .DBITS      ( HDATA_SIZE ),
    .TECHNOLOGY ( TECHNOLOGY ),
    .INIT_FILE  ( INIT_FILE  ) )
  ram_inst (
    .rst_ni  ( HRESETn ),
    .clk_i   ( HCLK    ),

    .waddr_i ( waddr   ),
    .we_i    ( we      ),
    .be_i    ( be      ),
    .din_i   ( HWDATA  ),

    .re_i    ( HSEL    ),
    .raddr_i ( raddr   ),
    .dout_o  ( dout    )
  );

  /*
   * Handle Read/Write contention
   *
   * A write immediately followed by a read to the same address
   * in the next clock cycle causes read/write contention in the memory
   *
   * Handle that here by keeping a local copy of that addresses contents
   */

  //use the local copy during writing to the same address
  //otherwise take a fresh copy from the actual memory
  always @(posedge HCLK)
    use_local_dout <= we && (raddr == waddr);


  //keep a local copy of the memory contents and update it during a write cycle
  // -gen_val combines current content with write-content based on byte-enables
  // -either combine the memory's content with the new write data
  //  or update the local copy with new write data
  always @(posedge HCLK)
    if (we) dout_local <= gen_val( use_local_dout ? dout_local : dout,
                                   HWDATA,
                                   be);


  //Is there read/write contention on the memory?
  always @(posedge HCLK)
    contention <= ahb_read         & //current cycle is a read cycle
                  we               & //previous cycle was a write cycle
                  (raddr == waddr);  //read and write address are the same


  /*
   * AHB BUS Response
   */
  assign HRESP = HRESP_OKAY; //always OK

generate
  if (REGISTERED_OUTPUT == "NO")
  begin
      always_comb HREADYOUT <= 1'b1;

      always_comb HRDATA = contention ? dout_local : dout;
  end
  else
  begin
      always @(posedge HCLK,negedge HRESETn)
        if      (!HRESETn                          ) HREADYOUT <= 1'b1;
	else if ( ahb_noseq && ahb_read & HREADYOUT) HREADYOUT <= 1'b0;
        else                                         HREADYOUT <= 1'b1;

      always @(posedge HCLK)
        HRDATA <= contention ? dout_local : dout;
  end
endgenerate

endmodule

package ahb3lite_pkg;
  localparam       HTRANS_SIZE   = 2;
  localparam       HSIZE_SIZE    = 3;
  localparam       HBURST_SIZE   = 3;
  localparam       HPROT_SIZE    = 4;

  //HTRANS
  localparam [1:0] HTRANS_IDLE   = 2'b00,
                   HTRANS_BUSY   = 2'b01,
                   HTRANS_NONSEQ = 2'b10,
                   HTRANS_SEQ    = 2'b11;

  //HSIZE
  localparam [2:0] HSIZE_B8    = 3'b000,
                   HSIZE_B16   = 3'b001,
                   HSIZE_B32   = 3'b010,
                   HSIZE_B64   = 3'b011,
                   HSIZE_B128  = 3'b100, //4-word line
                   HSIZE_B256  = 3'b101, //8-word line
                   HSIZE_B512  = 3'b110,
                   HSIZE_B1024 = 3'b111,
                   HSIZE_BYTE  = HSIZE_B8,
                   HSIZE_HWORD = HSIZE_B16,
                   HSIZE_WORD  = HSIZE_B32,
                   HSIZE_DWORD = HSIZE_B64;

  //HBURST
  localparam [2:0] HBURST_SINGLE = 3'b000,
                   HBURST_INCR   = 3'b001,
                   HBURST_WRAP4  = 3'b010,
                   HBURST_INCR4  = 3'b011,
                   HBURST_WRAP8  = 3'b100,
                   HBURST_INCR8  = 3'b101,
                   HBURST_WRAP16 = 3'b110,
                   HBURST_INCR16 = 3'b111;

  //HPROT
  localparam [3:0] HPROT_OPCODE         = 4'b0000,
                   HPROT_DATA           = 4'b0001,
                   HPROT_USER           = 4'b0000,
                   HPROT_PRIVILEGED     = 4'b0010,
                   HPROT_NON_BUFFERABLE = 4'b0000,
                   HPROT_BUFFERABLE     = 4'b0100,
                   HPROT_NON_CACHEABLE  = 4'b0000,
                   HPROT_CACHEABLE      = 4'b1000;

  //HRESP
  localparam       HRESP_OKAY  = 1'b0,
                   HRESP_ERROR = 1'b1;

endpackage



/************************************************
 * AHB3 Lite Interface
 */
 `ifndef AHB3_INTERFACES
 `define AHB3_INTERFACES
interface ahb3lite_bus #(
  parameter HADDR_SIZE = 32,
  parameter HDATA_SIZE = 32
)
(
  input logic HCLK,HRESETn
);
  logic                   HSEL;
  logic [HADDR_SIZE -1:0] HADDR;
  logic [HDATA_SIZE -1:0] HWDATA;
  logic [HDATA_SIZE -1:0] HRDATA;
  logic                   HWRITE;
  logic [            2:0] HSIZE;
  logic [            2:0] HBURST;
  logic [            3:0] HPROT;
  logic [            1:0] HTRANS;
  logic                   HMASTLOCK;
  logic                   HREADY;
  logic                   HREADYOUT;
  logic                   HRESP;

`ifdef SIM
  // Master CB Interface Definitions
  clocking cb_master @(posedge HCLK);
      output HSEL;
      output HADDR;
      output HWDATA;
      input  HRDATA;
      output HWRITE;
      output HSIZE;
      output HBURST;
      output HPROT;
      output HTRANS;
      output HMASTLOCK;
      input  HREADY;
      input  HRESP;
  endclocking

  modport master_cb (
    clocking cb_master,
    input    HRESETn
  );

  // Slave Interface Definitions
  clocking cb_slave @(posedge HCLK);
      input  HSEL;
      input  HADDR;
      input  HWDATA;
      output HRDATA;
      input  HWRITE;
      input  HSIZE;
      input  HBURST;
      input  HPROT;
      input  HTRANS;
      input  HMASTLOCK;
      input  HREADY;
      output HREADYOUT;
      output HRESP;
  endclocking

  modport slave_cb (
      clocking cb_slave,
      input HRESETn
  );
`endif

  modport master (
      input  HRESETn,
      input  HCLK,
      output HSEL,
      output HADDR,
      output HWDATA,
      input  HRDATA,
      output HWRITE,
      output HSIZE,
      output HBURST,
      output HPROT,
      output HTRANS,
      output HMASTLOCK,
      input  HREADY,
      input  HRESP
  );

  modport slave (
      input  HRESETn,
      input  HCLK,
      input  HSEL,
      input  HADDR,
      input  HWDATA,
      output HRDATA,
      input  HWRITE,
      input  HSIZE,
      input  HBURST,
      input  HPROT,
      input  HTRANS,
      input  HMASTLOCK,
      input  HREADY,
      output HREADYOUT,
      output HRESP
  );
endinterface


/************************************************
 * APB Lite Interface
 */
interface apb_bus #(
    parameter PADDR_SIZE = 6,
    parameter PDATA_SIZE = 8
  )
  (
    input logic PCLK,PRESETn
  );
    logic                    PSEL;
    logic                    PENABLE;
    logic [             2:0] PPROT;
    logic                    PWRITE;
    logic [PDATA_SIZE/8-1:0] PSTRB;
    logic [PADDR_SIZE  -1:0] PADDR;
    logic [PDATA_SIZE  -1:0] PWDATA;
    logic [PDATA_SIZE  -1:0] PRDATA;
    logic                    PREADY;
    logic                    PSLVERR;

    modport master (
      input  PRESETn,
      input  PCLK,
      output PSEL,
      output PENABLE,
      output PPROT,
      output PADDR,
      output PWRITE,
      output PSTRB,
      output PWDATA,
      input  PRDATA,
      input  PREADY,
      input  PSLVERR
    );

    modport slave (
      import is_read, is_write,

      input  PRESETn,
      input  PCLK,
      input  PSEL,
      input  PENABLE,
      input  PPROT,
      input  PADDR,
      input  PWRITE,
      input  PSTRB,
      input  PWDATA,
      output PRDATA,
      output PREADY,
      output PSLVERR
    );

    //Is this a valid read access?
    function automatic is_read();
      return PSEL & PENABLE & ~PWRITE;
    endfunction

    //Is this a valid write access?
    function automatic is_write();
      return PSEL & PENABLE & PWRITE;
    endfunction

    //Is this a valid write to address 0x...?
    //Take 'address' as an argument
    function automatic is_write_to_adr(input integer bits, input [PADDR_SIZE-1:0] address);
      logic [$bits(PADDR)-1:0] mask;
		
      mask = -1 >> ($bits(PADDR) -bits); //only 'bits' LSBs should be '1'		
      return is_write() & ( (PADDR & mask) == (address & mask) );
    endfunction

    //What data is written?
    //- Handles PSTRB, takes previous register/data value as an argument
    function automatic [PDATA_SIZE-1:0] get_write_value (input [PDATA_SIZE-1:0] orig_val);
       for (int n=0; n < PDATA_SIZE/8; n++)
         get_write_value[n*8 +: 8] = PSTRB[n] ? PWDATA[n*8 +: 8] : orig_val[n*8 +: 8];
    endfunction


    //Is this the 'setup' phase of the transfer?
    function automatic is_setup_phase();
      return PSEL & ~PENABLE;
    endfunction


    //Negate PREADY, Negate PSLVERR
    task set_not_ready();
      PREADY  = 1'b0;
      PSLVERR = 1'b0;
    endtask

    //Assert PREADY, Negate PSLVERR
    task set_ready();
      PREADY  = 1'b1;
      PSLVERR = 1'b0;
    endtask

   //Assert PREADY, Assert PSLVERR
   task set_error();
     PREADY  = 1'b1;
     PSLVERR = 1'b1;
   endtask
endinterface
`endif



module rl_queue #(
  parameter DEPTH                  = 2,
  parameter DBITS                  = 32,
  parameter ALMOST_EMPTY_THRESHOLD = 0,
  parameter ALMOST_FULL_THRESHOLD  = DEPTH
)
(
  input  logic             rst_ni,         //asynchronous, active low reset
  input  logic             clk_i,          //rising edge triggered clock

  input  logic             clr_i,          //clear all queue entries (synchronous reset)
  input  logic             ena_i,          //clock enable

  //Queue Write
  input  logic             we_i,           //Queue write enable
  input  logic [DBITS-1:0] d_i,            //Queue write data

  //Queue Read
  input  logic             re_i,           //Queue read enable
  output logic [DBITS-1:0] q_o,            //Queue read data

  //Status signals
  output logic             empty_o,        //Queue is empty
                           full_o,         //Queue is full
                           almost_empty_o, //Programmable almost empty
                           almost_full_o   //Programmable almost full
);

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  localparam EMPTY_THRESHOLD = 1;
  localparam FULL_THRESHOLD  = DEPTH -2;
  localparam ALMOST_EMPTY_THRESHOLD_CHECK = ALMOST_EMPTY_THRESHOLD <= 0     ? EMPTY_THRESHOLD : ALMOST_EMPTY_THRESHOLD +1;
  localparam ALMOST_FULL_THRESHOLD_CHECK  = ALMOST_FULL_THRESHOLD  >= DEPTH ? FULL_THRESHOLD  : ALMOST_FULL_THRESHOLD -2;


  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  logic [DBITS        -1:0] queue_data[DEPTH];
  logic [$clog2(DEPTH)-1:0] queue_wadr;


  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //Write Address
  always @(posedge clk_i,negedge rst_ni)
    if      (!rst_ni) queue_wadr <= 'h0;
    else if ( clr_i ) queue_wadr <= 'h0;
    else if ( ena_i )
      unique case ({we_i,re_i})
         2'b01 : queue_wadr <= queue_wadr -1;
         2'b10 : queue_wadr <= queue_wadr +1;
         default: ;
      endcase


  //Queue Data
  always @(posedge clk_i,negedge rst_ni)
    if (!rst_ni)
      for (int n=0; n<DEPTH; n++) queue_data[n] <= 'h0;
    else if (clr_i)
      for (int n=0; n<DEPTH; n++) queue_data[n] <= 'h0;
    else if (ena_i)
    unique case ({we_i,re_i})
       2'b01  : begin
                    for (int n=0; n<DEPTH-1; n++)
                      queue_data[n] <= queue_data[n+1];

                    queue_data[DEPTH-1] <= 'h0;
                end

       2'b10  : begin
                    queue_data[queue_wadr] <= d_i;
                end

       2'b11  : begin
                    for (int n=0; n<DEPTH-1; n++)
                      queue_data[n] <= queue_data[n+1];

                    queue_data[DEPTH-1] <= 'h0;

                    queue_data[~|queue_wadr ? DEPTH-1 : queue_wadr-1] <= d_i;
                end

       default: ;
    endcase


  //Queue Almost Empty
  always @(posedge clk_i, negedge rst_ni)
    if      (!rst_ni) almost_empty_o <= 1'b1;
    else if ( clr_i ) almost_empty_o <= 1'b1;
    else if ( ena_i )
      unique case ({we_i,re_i})
         2'b01  : almost_empty_o <= (queue_wadr <= ALMOST_EMPTY_THRESHOLD_CHECK);
         2'b10  : almost_empty_o <=~(queue_wadr >  ALMOST_EMPTY_THRESHOLD_CHECK);
         default: ;
      endcase


  //Queue Empty
  always @(posedge clk_i, negedge rst_ni)
    if      (!rst_ni) empty_o <= 1'b1;
    else if ( clr_i ) empty_o <= 1'b1;
    else if ( ena_i )
      unique case ({we_i,re_i})
         2'b01  : empty_o <= (queue_wadr == EMPTY_THRESHOLD);
         2'b10  : empty_o <= 1'b0;
         default: ;
      endcase


  //Queue Almost Full
  always @(posedge clk_i, negedge rst_ni)
    if      (!rst_ni) almost_full_o <= 1'b0;
    else if ( clr_i ) almost_full_o <= 1'b0;
    else if ( ena_i )
      unique case ({we_i,re_i})
         2'b01  : almost_full_o <=~(queue_wadr <  ALMOST_FULL_THRESHOLD_CHECK);
         2'b10  : almost_full_o <= (queue_wadr >= ALMOST_FULL_THRESHOLD_CHECK);
         default: ;
      endcase


  //Queue Full
  always @(posedge clk_i, negedge rst_ni)
    if      (!rst_ni) full_o <= 1'b0;
    else if ( clr_i ) full_o <= 1'b0;
    else if ( ena_i )
      unique case ({we_i,re_i})
         2'b01  : full_o <= 1'b0;
         2'b10  : full_o <= (queue_wadr == FULL_THRESHOLD);
         default: ;
      endcase



  //Queue output data
  assign q_o = queue_data[0];


`ifdef RL_QUEUE_WARNINGS
  always @(posedge clk_i)
    begin
        if (empty_o && !we_i &&  re_i) $display("rl_queue (%m): underflow @%0t", $time);
        if (full_o  &&  we_i && !re_i) $display("rl_queue (%m): overflow @%0t", $time);
    end
`endif

endmodule



module rl_ram_1r1w #(
  parameter ABITS         = 10,
  parameter DBITS         = 32,
  parameter TECHNOLOGY    = "GENERIC",
  parameter INIT_FILE     = "",
  parameter RW_CONTENTION = "BYPASS"
)
(
  input                    rst_ni,
  input                    clk_i,
 
  //Write side
  input  [ ABITS     -1:0] waddr_i,
  input  [ DBITS     -1:0] din_i,
  input                    we_i,
  input  [(DBITS+7)/8-1:0] be_i,

  //Read side
  input  [ ABITS     -1:0] raddr_i,
  input                    re_i,
  output [ DBITS     -1:0] dout_o
);
  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  logic             contention,
                    contention_reg;
  logic [DBITS-1:0] mem_dout,
                    din_dly;


  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
generate
  if (TECHNOLOGY == "N3XS" ||
      TECHNOLOGY == "n3xs")
  begin
      /*
       * eASIC N3XS
       */
      rl_ram_1r1w_easic_n3xs #(
        .ABITS ( ABITS ),
        .DBITS ( DBITS ) )
      ram_inst (
        .rst_ni  ( rst_ni     ),
        .clk_i   ( clk_i      ),

        .waddr_i ( waddr_i    ),
        .din_i   ( din_i      ),
        .we_i    ( we_i       ),
        .be_i    ( be_i       ),

        .raddr_i ( raddr_i    ),
        .re_i    (~contention ),
        .dout_o  ( mem_dout   )
      );
  end
  else
  if (TECHNOLOGY == "N3X"  ||
      TECHNOLOGY == "n3x")
  begin
      /*
       * eASIC N3X
       */
      rl_ram_1r1w_easic_n3x #(
        .ABITS ( ABITS ),
        .DBITS ( DBITS ) )
      ram_inst (
        .rst_ni  ( rst_ni     ),
        .clk_i   ( clk_i      ),

        .waddr_i ( waddr_i    ),
        .din_i   ( din_i      ),
        .we_i    ( we_i       ),
        .be_i    ( be_i       ),

        .raddr_i ( raddr_i    ),
        .re_i    (~contention ),
        .dout_o  ( mem_dout   )
      );
  end
  else 
  if (TECHNOLOGY == "LATTICE_DPRAM")
  begin
	  
    rl_ram_1r1w_lattice #(
        .ABITS     ( ABITS    ),
        .DBITS     ( DBITS    ),
        .INIT_FILE ( INIT_FILE) )
      ram_inst (
        .rst_ni  ( rst_ni   ),
        .clk_i   ( clk_i    ),

        .waddr_i ( waddr_i  ),
        .din_i   ( din_i    ),
        .we_i    ( we_i     ),
        .be_i    ( be_i     ),

        .raddr_i ( raddr_i  ),
        .dout_o  ( mem_dout )
      );
	  
  end
  else // (TECHNOLOGY == "GENERIC")
  begin
      /*
       * GENERIC  -- inferrable memory
       */
      initial $display ("INFO   : No memory technology specified. Using generic inferred memory (%m)");

      rl_ram_1r1w_generic #(
        .ABITS     ( ABITS     ),
        .DBITS     ( DBITS     ),
        .INIT_FILE ( INIT_FILE ) )
      ram_inst (
        .rst_ni  ( rst_ni   ),
        .clk_i   ( clk_i    ),

        .waddr_i ( waddr_i  ),
        .din_i   ( din_i    ),
        .we_i    ( we_i     ),
        .be_i    ( be_i     ),

        .raddr_i ( raddr_i  ),
        .dout_o  ( mem_dout )
      );
  end
endgenerate


generate
if (RW_CONTENTION == "DONT_CARE")
begin
    assign dout_o = mem_dout;
end
else
begin
  //TODO Handle 'be' ... requires partial old, partial new data

  //now ... write-first; we'll still need some bypass logic
  assign contention = re_i & we_i & (raddr_i == waddr_i); //prevent 'x' from propagating from eASIC memories

  always @(posedge clk_i)
  begin
      contention_reg <= contention;
      din_dly        <= din_i;
  end

  assign dout_o = contention_reg ? din_dly : mem_dout;
end
endgenerate

endmodule





module rl_ram_1r1w_easic_n3x #(
  parameter ABITS      = 10,
  parameter DBITS      = 32
)
(
  input                        rst_ni,
  input                        clk_i,

  //Write side
  input      [ ABITS     -1:0] waddr_i,
  input      [ DBITS     -1:0] din_i,
  input                        we_i,
  input      [(DBITS+7)/8-1:0] be_i,

  //Read side
  input      [ ABITS     -1:0] raddr_i,
  input                        re_i,
  output reg [ DBITS     -1:0] dout_o
);

  logic [DBITS-1:0] biten;
  genvar i;


generate
  for (i=0;i<DBITS;i++)
  begin: gen_bitena
      assign biten[i] = be_i[i/8];
  end
endgenerate

  eip_n3x_bram_array #(
    .WIDTHA        ( DBITS    ),
    .WIDTHB        ( DBITS    ),
    .DEPTHA        ( 2**ABITS ),
    .DEPTHB        ( 2**ABITS ),
    .REG_OUTA      ( "NO"     ),
    .REG_OUTB      ( "NO"     ),
    .INIT_ON       ( "NO"     ),
    .NINE_BIT_MODE ( "AUTO"   ),
    .TARGET        ( "POWER"  ) )
  ram_inst (
    .CLKA   ( clk_i         ),
    .AA     ( raddr_i       ),
    .DA     ( {DBITS{1'b0}} ),
    .QA     ( dout_o        ),
    .MEA    ( re_i          ),
    .WEA    ( 1'b0          ),
    .BEA    ( {DBITS{1'b1}} ),
    .RSTA_N ( 1'b1          ),

    .CLKB   ( clk_i         ),
    .AB     ( waddr_i       ),
    .DB     ( din_i         ),
    .QB     (               ),
    .MEB    ( 1'b1          ),
    .WEB    ( we_i          ),
    .BEB    ( biten         ),
    .RSTB_N ( 1'b1          ),

    .SD     ( 1'b0          ),
    .DS     ( 1'b0          ),
    .LS     ( 1'b0          ) );
endmodule






module rl_ram_1r1w_easic_n3xs #(
  parameter ABITS      = 8,
  parameter DBITS      = 8
)
(
  input                        rst_ni,
  input                        clk_i,
 
  //Write side
  input      [ ABITS     -1:0] waddr_i,
  input      [ DBITS     -1:0] din_i,
  input                        we_i,
  input      [(DBITS+7)/8-1:0] be_i,

  //Read side
  input      [ ABITS     -1:0] raddr_i,
  input                        re_i,
  output reg [ DBITS     -1:0] dout_o
);

  localparam DEPTH = 2**ABITS;
  localparam WIDTH = DBITS;


  logic [DBITS-1:0] biten;
  genvar i;

generate
  for (i=0;i<DBITS;i++)
  begin: gen_bitena
      assign biten[i] = be_i[i/8];
  end
endgenerate

generate
  /*
   * Nextreme-3S supports two types of bRAMs
   * -bRAM18k
   * -bRAM2k (aka RF)
   *
   * Configurations
   * bRAM18K        bRAM2K
   * 16k x  1        2k x  1
   *  8k x  2        1k x  2
   *  4k x  4       512 x  4
   *  2k x  8       256 x  8
   *  1k x 16       128 x 16 (sdp_array)
   * 512 x 32
   *
   *  2k x  9
   *  1k x 18
   * 512 x 36
   */
  if (DEPTH * WIDTH <= 4096)
  begin
      //bRAM2k
      eip_n3xs_rfile_array #(
        .WIDTHA    ( DBITS    ),
        .WIDTHB    ( DBITS    ),
        .DEPTHA    ( 2**ABITS ),
        .DEPTHB    ( 2**ABITS ),
        .REG_OUTB  ( "NO"     ),
        .TARGET    ( "POWER"  ) )
      ram_inst (
        .CLKA   ( clk_i         ),
        .AA     ( raddr_i       ),
        .DA     ( {DBITS{1'b0}} ),
        .QA     ( dout_o        ),
        .MEA    ( re_i          ),
        .WEA    ( 1'b0          ),
        .BEA    ( {DBITS{1'b1}} ),
        .RSTA_N ( 1'b1          ),

        .CLKB   ( clk_i         ),
        .AB     ( waddr_i       ),
        .DB     ( din_i         ),
        .QB     (               ),
        .MEB    ( 1'b1          ),
        .WEB    ( we_i          ),
        .BEB    ( biten         ),
        .RSTB_N ( 1'b1          ),

        .SD     ( 1'b0          ),
        .DS     ( 1'b0          ),
        .LS     ( 1'b0          ) );
  end
  else
  begin
      //bRAM18k
      eip_n3xs_bram_array #(
        .WIDTHA    ( DBITS    ),
        .WIDTHB    ( DBITS    ),
        .DEPTHA    ( 2**ABITS ),
        .DEPTHB    ( 2**ABITS ),
        .REG_OUTB  ( "NO"     ),
        .TARGET    ( "POWER"  ) )
      ram_inst (
        .CLKA   ( clk_i         ),
        .AA     ( raddr_i       ),
        .DA     ( {DBITS{1'b0}} ),
        .QA     ( dout_o        ),
        .MEA    ( re_i          ),
        .WEA    ( 1'b0          ),
        .BEA    ( {DBITS{1'b1}} ),
        .RSTA_N ( 1'b1          ),

        .CLKB   ( clk_i         ),
        .AB     ( waddr_i       ),
        .DB     ( din_i         ),
        .QB     (               ),
        .MEB    ( 1'b1          ),
        .WEB    ( we_i          ),
        .BEB    ( biten         ),
        .RSTB_N ( 1'b1          ),

        .SD     ( 1'b0          ),
        .DS     ( 1'b0          ),
        .LS     ( 1'b0          ) );
end

endgenerate

endmodule





module rl_ram_1r1w_generic #(
  parameter ABITS      = 10,
  parameter DBITS      = 32,
  parameter INIT_FILE  = ""
)
(
  input                        rst_ni,
  input                        clk_i,

  //Write side
  input      [ ABITS     -1:0] waddr_i,
  input      [ DBITS     -1:0] din_i,
  input                        we_i,
  input      [(DBITS+7)/8-1:0] be_i,

  //Read side
  input      [ ABITS     -1:0] raddr_i,
  output reg [ DBITS     -1:0] dout_o
);

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  genvar i;

  logic [DBITS-1:0] mem_array [2**ABITS -1:0];  //memory array


  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //preload memory
  //This seems to be synthesizable in FPGAs
  initial
    if (INIT_FILE != "")
    begin
        $display ("INFO   : Loading %s (%m)", INIT_FILE);
        $readmemh(INIT_FILE, mem_array);
    end


  /*
   * write side
   */
generate
  for (i=0; i<(DBITS+7)/8; i++)
  begin: write
     if (i*8 +8 > DBITS)
     begin
         always @(posedge clk_i)
           if (we_i && be_i[i]) mem_array[ waddr_i ] [DBITS-1:i*8] <= din_i[DBITS-1:i*8];
     end
     else
     begin
         always @(posedge clk_i)
           if (we_i && be_i[i]) mem_array[ waddr_i ][i*8+:8] <= din_i[i*8+:8];
     end
  end
endgenerate

  /*
   * read side
   */
  //per Altera's recommendations. Prevents bypass logic
  always @(posedge clk_i)
    dout_o <= mem_array[ raddr_i ];
endmodule



module rl_ram_1r1w_lattice #(
  parameter ABITS      = 10,
  parameter DBITS      = 32,
  parameter INIT_FILE  = ""
)
(
  input                        rst_ni,
  input                        clk_i,

  //Write side
  input      [ ABITS     -1:0] waddr_i,
  input      [ DBITS     -1:0] din_i,
  input                        we_i,
  input      [(DBITS+7)/8-1:0] be_i,

  //Read side
  input      [ ABITS     -1:0] raddr_i,
  output     [ DBITS     -1:0] dout_o
);

  /*
   * Instantiate Lattice DPRAM PMI Module (with BE)
   */
  pmi_ram_dp_be #(
    .pmi_wr_addr_depth    ( 2**ABITS        ),
    .pmi_wr_addr_width    ( ABITS           ),
    .pmi_wr_data_width    ( DBITS           ),
    .pmi_rd_addr_depth    ( 2**ABITS        ),
    .pmi_rd_addr_width    ( ABITS           ),
    .pmi_rd_data_width    ( DBITS           ),
    .pmi_regmode          ( "noreg"         ),
    .pmi_gsr              ( "disable"       ),
    .pmi_resetmode        ( "sync"          ),
    .pmi_optimization     ( "speed"         ),
    .pmi_init_file        ( INIT_FILE       ),
    .pmi_init_file_format ( "hex"           ),
    .pmi_byte_size        ( 8               ),
    .pmi_family           ( "ECP5"          ),
    .module_type          ( "pmi_ram_dp_be" ) )
  ram_inst (
    .Reset                ( 1'b0            ),
    .WrClock              ( clk_i           ),
    .WrClockEn            ( 1'b1            ),
    .WrAddress            ( waddr_i         ),
    .WE                   ( we_i            ),
    .ByteEn               ( be_i            ),
    .Data                 ( din_i           ),

    .RdClock              ( clk_i           ),
    .RdClockEn            ( 1'b1            ),
    .RdAddress            ( raddr_i         ),
    .Q                    ( dout_o          ) );
 
endmodule



/* Technlogy Specific Implementation for Lattice
 * This allows changing RAM contents without recompiling RTL
 */
module pmi_ram_dp_be #(
  parameter pmi_wr_addr_depth    = 512,
  parameter pmi_wr_addr_width    = 9,
  parameter pmi_wr_data_width    = 18,
  parameter pmi_rd_addr_depth    = 512,
  parameter pmi_rd_addr_width    = 9,
  parameter pmi_rd_data_width    = 18,
  parameter pmi_regmode          = "reg",
  parameter pmi_gsr              = "disable",
  parameter pmi_resetmode        = "sync",
  parameter pmi_optimization     = "speed",
  parameter pmi_init_file        = "none",
  parameter pmi_init_file_format = "binary",
  parameter pmi_byte_size        = 9,
  parameter pmi_family           = "ECP2",
  parameter module_type          = "pmi_ram_dp_be",

  localparam byteen_width        = (pmi_wr_data_width + pmi_byte_size -1)/pmi_byte_size
)
(
  input [pmi_wr_data_width -1:0] Data,
  input [pmi_wr_addr_width -1:0] WrAddress,
  input [pmi_rd_addr_width -1:0] RdAddress,
  input                          WrClock,
  input                          RdClock,
  input                          WrClockEn,
  input                          RdClockEn,
  input                          WE,
  input                          Reset,
  input  [    byteen_width -1:0] ByteEn,
  output [pmi_rd_data_width-1:0] Q) /*synthesis syn_black_box*/;
endmodule // pmi_ram_dp




module rl_ram_1rw #(
  parameter ABITS      = 10,
  parameter DBITS      = 32,
  parameter TECHNOLOGY = "GENERIC",
  parameter INIT_FILE  = ""
)
(
  input                    rst_ni,
  input                    clk_i,

  input  [ ABITS     -1:0] addr_i,
  input                    we_i,
  input  [(DBITS+7)/8-1:0] be_i,
  input  [ DBITS     -1:0] din_i,
  output [ DBITS     -1:0] dout_o
);
  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
generate

  if (TECHNOLOGY == "N3X" ||
      TECHNOLOGY == "n3x" )
  begin
      /*
       * eASIC N3X
       */
      rl_ram_1rw_easic_n3x #(
        .ABITS ( ABITS ),
        .DBITS ( DBITS ) )
      ram_inst (
        .rst_ni ( rst_ni ),
        .clk_i  ( clk_i  ),

        .addr_i ( addr_i ),
        .we_i   ( we_i   ),
        .be_i   ( be_i   ),
        .din_i  ( din_i  ),
        .dout_o ( dout_o )
      );
  end
  else // (TECHNOLOGY == "GENERIC")
  begin
      /*
       * GENERIC  -- inferrable memory
       */
      initial $display ("INFO   : No memory technology specified. Using generic inferred memory (%m)");

      rl_ram_1rw_generic #(
        .ABITS     ( ABITS    ),
        .DBITS     ( DBITS    ),
        .INIT_FILE ( INIT_FILE) )
      ram_inst (
        .rst_ni ( rst_ni ),
        .clk_i  ( clk_i  ),

        .addr_i ( addr_i ),
        .we_i   ( we_i   ),
        .be_i   ( be_i   ),
        .din_i  ( din_i  ),
        .dout_o ( dout_o )
      );
  end

endgenerate

endmodule




module rl_ram_1rw_easic_n3x #(
  parameter ABITS      = 10,
  parameter DBITS      = 32
)
(
  input                    rst_ni,
  input                    clk_i,

  input  [ ABITS     -1:0] addr_i,
  input                    we_i,
  input  [(DBITS+7)/8-1:0] be_i,
  input  [ DBITS     -1:0] din_i,
  output [ DBITS     -1:0] dout_o
);

  eip_n3x_bram_sp_array #(
    .WIDTH         ( DBITS    ),
    .DEPTH         ( 2**ABITS ),
    .REG_OUT       ( "NO"     ),
    .INIT_ON       ( "NO"     ),
    .NINE_BIT_MODE ( "AUTO"   ),
    .TARGET        ( "POWER"  ) )
  ram_inst (
    .CLK    ( clk_i         ),
    .A      ( addr_i        ),
    .D      ( din_i         ),
    .Q      ( dout_o        ),
    .ME     ( 1'b1          ),
    .WE     ( we_i          ),
    .BE     ( {DBITS{1'b1}} ),
    .RST_N  ( 1'b1          ),

    .SD     ( 1'b0          ),
    .DS     ( 1'b0          ),
    .LS     ( 1'b0          ) );
endmodule



module rl_ram_1rw_generic #(
  parameter ABITS      = 10,
  parameter DBITS      = 32,
  parameter INIT_FILE  = ""
)
(
  input                        rst_ni,
  input                        clk_i,

  input      [ ABITS     -1:0] addr_i,
  input                        we_i,
  input      [(DBITS+7)/8-1:0] be_i,
  input      [ DBITS     -1:0] din_i,
  output reg [ DBITS     -1:0] dout_o
);

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  genvar i;

  reg [DBITS-1:0] mem_array [2**ABITS -1:0];  //memory array
  reg [ABITS-1:0] addr_reg;                   //latched read address


  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //preload memory
  //This seems to be synthesizable in FPGAs
  initial
    if (INIT_FILE != "")
    begin
        $display ("INFO   : Loading %s (%m)", INIT_FILE);
        $readmemh(INIT_FILE, mem_array);
    end


  //write side
generate
  for (i=0; i<(DBITS+7)/8; i++)
  begin: write
     if (i*8 +8 > DBITS)
     begin
         always @(posedge clk_i)
           if (we_i && be_i[i]) mem_array[ addr_i ] [DBITS-1:i*8] <= din_i[DBITS-1:i*8];
     end
     else
     begin
         always @(posedge clk_i)
           if (we_i && be_i[i]) mem_array[ addr_i ][i*8+:8] <= din_i[i*8+:8];
     end
  end
endgenerate

  //read side
  //per Altera's recommendations; avoids bypass logic
  always @(posedge clk_i)
    dout_o <= mem_array[ addr_i ];
endmodule