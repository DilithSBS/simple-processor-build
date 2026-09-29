/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

`timescale 1ns/100ps

module dcache (

    input   clock,
    input   reset,

    input               mem_busywait,       // busywait signal from main memory
    output  reg         busywait,           // busywait signal to CPU

    input               read,               // read signal from CPU
    output  reg         mem_read,           // read signal to main memory

    input               write,              // write signal from CPU
    output  reg         mem_write,          // write signal to main memory

    input       [7:0]   writedata,          // data to be written into cache
    output  reg [31:0]  mem_writedata,      // data to be written into main memory

    input       [31:0]  mem_readdata,       // data read from main memory
    output  wire [7:0]  readdata,           // data read from cache

    input       [7:0]   address,            // memory address from CPU
    output  reg [5:0]   mem_address         // memory address to main memory
);

    /*
    =================================================
        Extract information from memory address
    =================================================
    */

    wire [3:0]  tag_cpu     = address[7:4] ;    // tag      = 4 bits
    wire [1:0]  index_cpu   = address[3:2] ;    // index    = 2 bits
    wire [1:0]  offset_cpu  = address[1:0] ;    // offset   = 2 bits


    /*
    =================================================
                    Cache memory storage
    =================================================
    */
    
    reg  [31:0]  data_block_array   [3:0];  // 4 x 32-bit data blocks
    reg  [3:0]   tag_array          [3:0];  // 4 x 4-bit tags
    reg          valid_array        [3:0];  // 4 x 1-bit valid bits
    reg          dirty_array        [3:0];  // 4 x 1-bit dirty bits


    // Initializing valid and dirty bits to 0 when reset is high
    integer i;
    always @(posedge clock) begin
        if (reset) begin
            for (i = 0; i < 4; i = i + 1) begin
                valid_array[i] <= 0;
                dirty_array[i] <= 0;
            end
        end
    end



    /*
    ==============================================================================
        Combinational part for indexing, tag comparison for hit deciding, etc.
    ==============================================================================
    */

    wire [31:0]     cached_data_block;
    wire [3:0]      cached_tag;
    wire            cached_valid;
    wire            cached_dirty;

    // continuously assign values to wires based on index of address
    assign #1 cached_data_block = data_block_array[index_cpu];
    assign #1 cached_tag = tag_array[index_cpu];
    assign #1 cached_valid = valid_array[index_cpu];
    assign #1 cached_dirty = dirty_array[index_cpu];



    // Hit detection
    wire hit;
    assign #0.9 hit = ((tag_cpu == cached_tag) && (cached_valid == 1)) ? 1'b1 : 1'b0;


    // Data word selection if hit
    reg  [7:0] data_word;

    always @(*) begin
        case (offset_cpu)               // data word selection based on offset of address
            2'b00: data_word <= #1 cached_data_block[7:0];
            2'b01: data_word <= #1 cached_data_block[15:8];
            2'b10: data_word <= #1 cached_data_block[23:16];
            2'b11: data_word <= #1 cached_data_block[31:24];
            default: data_word <= #1 8'd0;
        endcase 
    end


    // Send back data word to CPU asynchronously
    assign readdata = (read == 1) ? data_word : 8'd0;




    // Comprehensive BUSYWAIT logic
    always @(*) begin
        if (read || write) begin
            if (hit && state == IDLE) 
                busywait = 1'b0; // De-assert on a hit while in IDLE
            else 
                busywait = 1'b1; // Assert immediately on request, and hold during FSM miss handling
        end 
        else begin
            busywait = 1'b0; // De-assert when CPU is not requesting anything
        end
    end



    /*
    ==============================================================================
        Synchronous sequential logic for cache block updating, etc.
    ==============================================================================
    */

    // If hit and write is high, the data from CPU is written into 
    // correct cache block using index and offset
    always @(posedge clock) begin
        if (hit && write && !read) begin
            case(offset_cpu)       // write into cache in one clock cycle  based on offset of address 
                2'b00: data_block_array[index_cpu][7:0] <= #1 writedata; 
                2'b01: data_block_array[index_cpu][15:8] <= #1 writedata; 
                2'b10: data_block_array[index_cpu][23:16] <= #1 writedata; 
                2'b11: data_block_array[index_cpu][31:24] <= #1 writedata; 
                default: data_block_array[index_cpu][7:0] <= #1 writedata; 
            endcase

            valid_array[index_cpu] <= 1'b1;    // Update valid bit = 1
            dirty_array[index_cpu] <= 1'b1;    // Update dirty bit = 1 since still main memory is not updated
            busywait = 0;
        end


    end

    /*
    ==================================================
                   Cache Controller FSM 
    ==================================================
    */

    // FSM states definitions
    parameter   IDLE        = 3'b000,   // Wait for CPU requests in IDLE state when there are no read or write signals
                MEM_READ    = 3'b001,   // Execute memory read operation
                MEM_WRITE   = 3'b010,   // Execute memory write operation if dirty bit is set
                UPDATE_CACHE= 3'b011;   // Update the cache

    // state and next state declaration
    reg [2:0] state, next_state;


    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !cached_dirty && !hit)       // if no dirty bit and no hit
                    next_state = MEM_READ;

                else if ((read || write) && cached_dirty && !hit)   // if dirty bit and no hit
                    next_state = MEM_WRITE;
                else                                                  // if no read or write
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait)                                  // if no busywait from main memory
                    next_state = UPDATE_CACHE;
                else    
                    next_state = MEM_READ;

            MEM_WRITE:
                if (!mem_busywait)                                  // if no busywait from main memory
                    next_state = MEM_READ;
                else    
                    next_state = MEM_WRITE;

            UPDATE_CACHE:
                next_state = IDLE;                                  // update the cache and go back to idle

            default:
                next_state = IDLE; 

        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)                         
            IDLE:                               
                begin                               // assign outputs in IDLE state
                    mem_read = 0;
                    mem_write = 0;
                    mem_address = 6'dx;
                    mem_writedata = 32'dx;
                    busywait = 0;                   // de-assert when cpu is not requesting anything
                end
            
            MEM_READ: 
                begin                               // assign outputs in MEM_READ state
                    mem_read = 1;
                    mem_write = 0;
                    mem_address = {tag_cpu, index_cpu};
                    mem_writedata = 32'dx;
                    busywait = 1;                   // assert during main memory access
                end
            
            MEM_WRITE:
                begin                               // assign outputs in MEM_WRITE state
                    mem_read = 0;
                    mem_write = 1;
                    mem_address = {cached_tag, index_cpu};
                    mem_writedata = cached_data_block;
                    busywait = 1;                   // assert during main memory access

                end
            
            UPDATE_CACHE:
                begin                               // assign outputs in UPDATE_CACHE state
                    mem_read = 0;
                    mem_write = 0;
                    mem_address = 6'dx;
                    mem_writedata = 32'dx;
                    busywait = 1;                   // assert during main memory access

                    #1                                              // artificial delay for cache update
                    data_block_array[index_cpu] = mem_readdata;     // update the cache with read data from memory
                    tag_array[index_cpu]        = tag_cpu;          // update the tag
                    valid_array[index_cpu]      = 1'b1;             // update the valid bit
                    dirty_array[index_cpu]      = 1'b0;             // update the dirty bit
                    
                    busywait = 0;

                end

        endcase
    end


    // sequential logic for state transitioning 
    always @(posedge clock)
    begin
        if(reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    /* Cache Controller FSM End */

endmodule