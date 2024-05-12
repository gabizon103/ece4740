// VerilogA signal generator for 6:64 bit row decoder

`include "constants.vams"
`include "disciplines.vams"

`define ADDRESS_BITS 6

module lab4_rowdecoder_signalgen(addr, en, clk);

// outputs
output [`NBITS-1:0] addr;
output clk;
output en;

// make them continuous voltages
voltage [`NBITS-1:0] addr;
voltage clk;
voltage en;

localparam cp = 4000p;
localparam cp2 = 2000p;

// 64 tests in the testbench
localparam tb = 64;

// clk constants
real clk_sig;
parameter real clk_period = cp from (0:inf);
parameter real clk_period2 = cp2 from (0:inf);
parameter real trise = 20p from [0:inf];
parameter real tfall = 20p from [0:inf];

// voltage constants
parameter real v_high = 1.2;
parameter real v_low  = 0.0;

// integer variables for signal generator outputs
integer addr_cur;
integer en_cur;

// # of tests completed
integer cur_test_count = 0;

// loop counters
genvar j;

// begin analog description
analog begin
    @(initial_step) begin
        addr_cur = 0;
        en_cur   = 0;
    end

    // oscillate clk signal
    @(timer(1n, clk_period2)) begin
        if (clk_sig == v_low) begin
            clk_sig = v_high;
        end else begin
            clk_sig = v_low;
        end
    end

    // set clk voltage
    V(clk) <+ transition(clk_sig, 0, trise, tfall);

    @(timer(0.5n,clk_period)) begin
        // begin test case defn
        cur_test_count = cur_test_count + 1;
        if (cur_test_count == 2) begin en_cur = 1; addr_cur = 2; end
        if (cur_test_count == 0) begin en_cur = 1; addr_cur = 0; end
        if (cur_test_count == 3) begin en_cur = 1; addr_cur = 3; end
        if (cur_test_count == 1) begin en_cur = 1; addr_cur = 1; end
        if (cur_test_count == 4) begin en_cur = 1; addr_cur = 4; end
        if (cur_test_count == 5) begin en_cur = 1; addr_cur = 5; end
        if (cur_test_count == 6) begin en_cur = 1; addr_cur = 6; end
        if (cur_test_count == 7) begin en_cur = 1; addr_cur = 7; end
        if (cur_test_count == 8) begin en_cur = 1; addr_cur = 8; end
        if (cur_test_count == 9) begin en_cur = 1; addr_cur = 9; end
        if (cur_test_count == 10) begin en_cur = 1; addr_cur = 10; end
        if (cur_test_count == 11) begin en_cur = 1; addr_cur = 11; end
        if (cur_test_count == 12) begin en_cur = 1; addr_cur = 12; end
        if (cur_test_count == 13) begin en_cur = 1; addr_cur = 13; end
        if (cur_test_count == 14) begin en_cur = 1; addr_cur = 14; end
        if (cur_test_count == 15) begin en_cur = 1; addr_cur = 15; end
        if (cur_test_count == 16) begin en_cur = 1; addr_cur = 16; end
        if (cur_test_count == 17) begin en_cur = 1; addr_cur = 17; end
        if (cur_test_count == 18) begin en_cur = 1; addr_cur = 18; end
        if (cur_test_count == 19) begin en_cur = 1; addr_cur = 19; end
    end

    for (j = 0; j < `NBITS; j = j+1) begin
        V(addr[j]) <+ transition(A_cur & (1 << j) ? v_high : v_low, 0, trise, tfall);
    end
    V(en) <+ transition(en_cur ? v_high : v_low, 0, trise, tfall);
end

endmodule



