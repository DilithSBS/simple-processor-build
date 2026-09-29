`timescale 1ns/100ps

module instruction_cache (

    // CPU ports
    input           clock,
    input           reset,
    input   [31:0]  PC,
    output  [31:0]  inst_read,
    output  reg     busywait,
    input           read,
    
    // memory ports
    output  [5:0]   imem_address,
    input   [127:0] imem_readdata,
    output  reg     imem_read,
    input           imem_busywait
    
);

    // Since the instruction memory is only 256 instructions (1024 bytes), we only need to consider 10 bits of the address
    wire [9:0] address_10bit = PC[9:0];


    /*
    =================================================
              Instruction Cache memory storage
    =================================================
    */
    reg [127:0]  data_array    [7:0];
    reg [2:0]    tag_array     [7:0];
    reg          valid_array   [7:0];
    
    /*
    ==============================================================
        Extract information from instruction memory address
    ==============================================================
    */

    // last 2 bits of the address are always 00 - because word size is 4 bytes
    wire [2:0] tag_cpu         = address_10bit[9:7];   // tag
    wire [2:0] index_cpu       = address_10bit[6:4];   // index
    wire [1:0] word_select_cpu = address_10bit[3:2];   // word select 


    // cached data is extracted using address index, tag and valid bit
    wire [127:0] cached_data_block;
    wire [2:0]   cached_tag;
    wire         cached_valid;

    // Extract cache block, tag and valid bit from cache memory
    assign #1 cached_data_block = data_array[index_cpu];
    assign #1 cached_tag = tag_array[index_cpu];
    assign #1 cached_valid = valid_array[index_cpu];

    
    // hit ditection
    wire hit;
    assign #0.9 hit = (cached_tag == tag_cpu) && (cached_valid);


    // Selecting correct instruction word based on offset
    reg [31:0] inst_word;

    always @(*) begin
        case (word_select_cpu)
            2'b00: inst_word <= #1 cached_data_block[31:0];      //selecting first instruction (word 0)
            2'b01: inst_word <= #1 cached_data_block[63:32];     //selecting second instruction (word 1)
            2'b10: inst_word <= #1 cached_data_block[95:64];     //selecting third instruction (word 2)
            2'b11: inst_word <= #1 cached_data_block[127:96];    //selecting fourth instruction (word 3)
        endcase
    end

    
    // Sending read instruction to CPU asynchronously
    assign inst_read = ((hit == 1) && (read == 1)) ? inst_word : 32'hxxxxxxxx;


    parameter   IDLE_STATE      = 2'b00,
                IMEM_READ_STATE = 2'b01;
                
    reg [2:0] state, next_state;


    always @(*) begin
        case (state)
            IDLE_STATE:
                if (hit)
                    next_state = IDLE_STATE;
                else
                    next_state = IMEM_READ_STATE;

            IMEM_READ_STATE:
                if (imem_busywait)
                    next_state = IMEM_READ_STATE;
                else
                    next_state = IDLE_STATE;
        endcase
        
    end 



    /*
    ==============================================================
                Instruction cache busywait and control
    ==============================================================
    */

    always @(*) begin
        
        if (read && (!hit || state != IDLE_STATE))
            busywait = 1'b1;    // Assert busywait immediately if CPU is reading and there is a miss
        // else
        //     busywait = 1'b0;    // Otherwise de-assert busywait

        // Assert memory read signal when the FSM is in the memory read state
        imem_read = (state == IMEM_READ_STATE) ? 1'b1 : 1'b0;

    end

    always @(posedge clock) begin
        if (!(read && (!hit || state != IDLE_STATE)))
            busywait = 1'b0;    // De-assert busywait in the next positive clock edge if CPU is not reading or there is a hit
        
    end




    // Sending address to instruction memory
    assign imem_address = {tag_cpu, index_cpu};



    
    integer i;
    always @(posedge clock) begin
        if (reset) begin                        // Reset cache memory and FSM on reset
            
            // reset state
            state <= IDLE_STATE;    

            // reset cache memory
            for (i = 0; i < 8; i = i + 1) begin
                valid_array[i] <= 1'b0;
                tag_array[i] <= 3'b000;
                data_array[i] <= 128'b0;
            end
        end
        else begin                              // Update cache memory and FSM on positive clock edge
            
            // update state
            state <= next_state;

            // update cache memory with instruction data from instruction memory
            if (state == IMEM_READ_STATE && !imem_busywait) begin
                
                #1;             // Artificial delay of 1 time unit for cache update
                data_array[index_cpu] <= imem_readdata;
                tag_array[index_cpu]  <= tag_cpu;
                valid_array[index_cpu]<= 1'b1;
            
            end
        end

    end
endmodule