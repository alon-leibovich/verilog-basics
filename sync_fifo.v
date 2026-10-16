//=============================================================================
// sync_fifo.v  -  synchronous FIFO (circular buffer) with full/empty flags
//
// A FIFO is a queue in hardware. One side writes, the other side reads, and
// data comes out in the order it went in. It is the standard way to connect
// two blocks that do not run at the same rate.
//
//-----------------------------------------------------------------------------
// HOW IT WORKS
//
// A block of memory plus two pointers moving around it in a circle:
//
//        wr_ptr                    rd_ptr
//          |                         |
//          v                         v
//   +----+----+----+----+----+----+----+----+
//   |    | D3 | D2 | D1 |    |    |    |    |
//   +----+----+----+----+----+----+----+----+
//     0    1    2    3    4    5    6    7
//
//   write -> store at wr_ptr, then wr_ptr++
//   read  -> return mem[rd_ptr], then rd_ptr++
//   both pointers wrap around at DEPTH
//
//-----------------------------------------------------------------------------
// FULL VS. EMPTY
//
// Empty means wr_ptr == rd_ptr.
// Full also means wr_ptr == rd_ptr, because the write pointer has lapped the
// read pointer exactly once. Same condition, opposite meaning.
//
// The fix: both pointers are one bit wider than the address needs.
//
//   equal address bits + equal MSB       -> EMPTY
//   equal address bits + different MSB   -> FULL   (wr lapped rd)
//
// The extra bit counts laps. It never addresses memory.
//
//=============================================================================

`timescale 1ns / 1ps
`default_nettype none

module sync_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 8,                 // must be a power of two
    parameter PTR_W = $clog2(DEPTH)      // derived - do not override
)(
    input  wire             clk,
    input  wire             rst,     // synchronous, active high

    input  wire             wr_en,   // request a write
    input  wire [WIDTH-1:0] wr_data,

    input  wire             rd_en,   // request a read
    output wire [WIDTH-1:0] rd_data,

    output wire             full,
    output wire             empty,
    output wire [PTR_W:0]   count    // number of entries stored
);

    // storage
    reg [WIDTH-1:0] mem [0:DEPTH-1];

    // pointers are PTR_W+1 bits wide: PTR_W address bits plus one lap bit
    reg [PTR_W:0]   wr_ptr;
    reg [PTR_W:0]   rd_ptr;


    // =====================================================================
    //  Status
    //
    // empty: same address, same lap.
    // full:  same address, different lap - the writer is exactly one full
    //        loop ahead of the reader.
    // count: a plain subtraction. Modular arithmetic on the PTR_W+1-bit
    //        pointers handles the wraparound with no special case.
    // =====================================================================
    assign empty = ( wr_ptr[PTR_W:0] == rd_ptr[PTR_W:0] );

    assign full  = ( wr_ptr[PTR_W]     != rd_ptr[PTR_W]     ) &&
                   ( wr_ptr[PTR_W-1:0] == rd_ptr[PTR_W-1:0] );

    assign count = wr_ptr - rd_ptr;


    // =====================================================================
    //  Read data
    //
    // Memory is addressed with the LOW bits of rd_ptr only. The lap bit is
    // not part of the address.
    // =====================================================================
    assign rd_data = mem[rd_ptr[PTR_W-1:0]];


    // =====================================================================
    //  Pointers and memory write
    //
    // Two independent if statements, NOT if/else. A read and a write in the
    // same cycle is legal and common - that is how a FIFO sustains
    // throughput at constant occupancy.
    //
    // The "&& !full" and "&& !empty" guards make a write to a full FIFO, or
    // a read from an empty one, a safe no-op instead of corrupting data.
    // =====================================================================
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr[PTR_W-1:0]] <= wr_data;
                wr_ptr <= wr_ptr + 1'b1;
            end
            if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1'b1;
            end
        end
    end

endmodule

`default_nettype wire
