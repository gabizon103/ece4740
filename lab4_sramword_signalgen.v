// VerilogA signal generator for testing a single word of SRAM

`include "constants.vams"
`include "disciplines.vams"

`define WORD_BITS 8

module lab4_sramtop_signalgen(wordline, data_in, wen, clk);

// outputs from signalgen

output [`WORD_BITS-1:0] data_in;
output wordline;
output wen;
output clk;

voltage [`WORD_BITS-1:0] data_in;
voltage wordline;
voltage wen;
voltage clk;

localparam cp = 4000p;
localparam cp2 = 2000p;

// number of tests
localparam tb = 7;

// clk constants
real clk_sig;
parameter real clk_period = cp from (0:inf);
parameter real clk_period2 = cp2 from (0:inf);
parameter real trise = 20p from [0:inf];
parameter real tfall = 20p from [0:inf];

// voltage constants
parameter real v_high = 1.2;
parameter real v_low = 0.0;

// integer variables for signal gen outputs
integer data_in_cur;
integer wordline_cur;
integer wen_cur;

// track # of tests completed
integer cur_test_count = 0;

// loop counter
genvar j;

// analog desc
analog begin
    @(initial_step) begin
        wordline_cur = 0;
        data_in_cur = 8'd0;
        wen_cur = 0;
    end

    // oscillate clk signal
    @(timer(1n, clk_period2)) begin
        if (clk_sig == v_low) clk_sig = v_high;
        else clk_sig = v_low;
    end

    // set clk voltage
    V(clk) <+ transition(clk_sig, 0, trise, tfall);

    @(timer(0.5n, clk_period)) begin
        // test 1
        case (cur_test_count)
        // test 0: write 10101010
        0: begin
            wen_cur = 1;
            wordline_cur = 1;
            data_in_cur = 8'b10101010; 
        end
        // test 1: do a read
        1: begin
            wen_cur = 0;
            wordline_cur = 1;
            data_in_cur = 0;
        end
        // test 2: write 01010101
        2: begin
            wen_cur = 1;
            wordline_cur = 1;
            data_in_cur = 8'b01010101;
        end
        // test 3: do a read
        3: begin
            wen_cur = 0;
            wordline_cur = 1;
            data_in_cur = 0;
        end
        // test 4: write 11111111
        4: begin
            wen_cur = 1;
            wordline_cur = 1;
            data_in_cur = 8'b11111111;
        end
        // test 5; do a read
        5: begin
            wen_cur = 0;
            wordline_cur = 1;
            data_in_cur = 0;
        end
        // test 6: write 00000000
        6: begin
            wen_cur = 1;
            wordline_cur = 1;
            data_in_cur = 8'b00000000;
        end
        // test 7: read
        7: begin
            wen_cur = 0;
            wordline_cur = 1;
            data_in_cur = 0;
        end
        endcase
        cur_test_count = cur_test_count + 1;
    end

    for (j = 0; j < `WORD_BITS; j = j+1) begin
        V(data_in[j]) <+ transition(data_in_cur & (1<<j) ? v_high : v_low, 0, trise, tfall);
    end
    V(wen) <+ transition(wen_cur ? v_high : v_low, 0, trise, tfall);
    V(wordline) <+ transition(wordline_cur ? v_high : v_low, 0, trise, tfall);
end

endmodule