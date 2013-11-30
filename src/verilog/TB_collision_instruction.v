
module TB_collision_instruction;
  
    reg clk;
    reg clk_en;
    reg reset;
    reg start;
    reg [31:0] dataa;
    reg [31:0] datab;
    reg n;
    wire done;
    wire [31:0] result; 
  
    CollisionInstruction U1(
        clk, clk_en, reset, start,  // Execution inputs
        dataa, datab,               // Data inputs
        n,                          // Instruction selection inputs
        done, result                // Instruction outputs
    );
    
    initial begin
        clk = 0;
        clk_en = 1;
        reset = 1;
        start = 0;
        dataa = 32'd0;
        datab = 32'd0;
        n = 0;
    end
    
    always #100 clk = ~clk;
    
    // For testing purposes, using instructed base message in testbench
    // "XXXX Keep your FPGA spinning!", which is 232 bits (29 bytes x 8)    
    
    parameter WORD_SIZE = 32;
    parameter TOTAL_WORDS = 16;
    parameter BASE_MESSAGE = "XXXX Keep your FPGA spinning!";
    parameter [WORD_SIZE*TOTAL_WORDS-1:0] MESSAGE = 
        {BASE_MESSAGE,152'h0,4'h8,60'h0,32'h00000000,32'h00000180};
    
    integer i,j;
    
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            for (j = 0; j < TOTAL_WORDS; j = j + 2) begin
                #200 reset = 0;
                start = 1;
                dataa = MESSAGE[((WORD_SIZE*TOTAL_WORDS-1)-(j*WORD_SIZE))-:WORD_SIZE];
                datab = MESSAGE[((WORD_SIZE*TOTAL_WORDS-1)-((j+1)*WORD_SIZE))-:WORD_SIZE];
                n = 0;
                
                #200 start = 0;
                
                wait (done);
            end
            
            // Execute given target out of 32
            #200 reset = 0;
                 start = 1;
                 dataa = i;
                 datab = 32'h00000000;
                 n     = 1;
            #200 reset = 0;
                 start = 0;
                 dataa = i;
                 datab = 32'h00000000;
                 n     = 1;
                 
            wait (done) begin
                $display("(Target is %d) Collision at %h", i, result);
            end
        end
    end
  
endmodule