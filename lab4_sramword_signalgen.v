// VerilogA for ece4740, lab4_write_driver_sigGen, veriloga

`include "constants.vams"
`include "disciplines.vams"

// Use macro to define adder's bit width
`define DATABITS 8

module lab4_write_driver_sigGen(WE, D_IN, word);
// Declare outputs
output WE;
output [`DATABITS-1:0] D_IN;
output word;


// Specify desired output type to be a continuous voltage signal
voltage WE;
voltage [`DATABITS-1:0] D_IN;
voltage word;


// Declare locally-scoped constants using localparam keyword
// Clock period for test cases
localparam cp = 4000p;
// Clock half-period for FF clock latch signal
localparam cp2 = 2000p;

// Number of testcases per testsuite
localparam tb1 = 2;
localparam tb2 = 2;
localparam tb3 = 2;
localparam tb4 = 2;
localparam tb5 = 2;
localparam tb6 = 2;

// Tracks clock signal high/low value
real			clk_sig;

// Constants for clock periods
parameter real	clk_period = cp from (0:inf);
parameter real	clk_period2 = cp2 from (0:inf);
parameter real	trise = 20p from [0:inf];
parameter real	tfall = 20p from [0:inf];

// Constants for voltage signal bounds
parameter real	v_high = 1.2;
parameter real	v_low = 0.0;

// Initialize integer variables for signal generator outputs
// A, B, Cin are inputs to the N-bit adder
integer 			WE_curr;
integer        	D_IN_curr;
integer			word_curr;

// Keeps track of how many testcases have completed
integer			curTestCount = 0;

// Initialize counters to be used in for-loop
// Cannot use integers as the for-loop used is a "generator construct"
genvar			j;


// Start analog description of module
analog begin

	// Initialize signal generator output values
	@(initial_step) begin
		WE_curr = 0;
		D_IN_curr = 0;
		word_curr = 0;
	end

/*
 	-------------------------------------------------
				TESTCASE DEFINITIONS
	-------------------------------------------------
*/

	// Timer block to run testcases
	@(timer(0.5n,clk_period)) begin

	// Testsuite 1: Write 1
		curTestCount = curTestCount + 1;
		if (curTestCount <= tb1) begin
			WE_curr = 1;
			D_IN_curr = 1;
			if (curTestCount == tb1)
				word_curr = 1;
		end

	// Testsuite 2: Read 1
		if (tb1 < curTestCount && curTestCount <= tb1 + tb2) begin
			word_curr = 0;
			WE_curr = 0;
			D_IN_curr = 0;
			if (curTestCount == tb1 + tb2)
				word_curr = 1;
		end

	// Testsuite 3: Write 0
		if (tb1 + tb2 < curTestCount && curTestCount <= tb1 + tb2 + tb3) begin
			word_curr = 0;
			WE_curr = 1;
			D_IN_curr = 0;
			if (curTestCount == tb1 + tb2 + tb3)
				word_curr = 1;
		end

	// Testsuite 4: Read 0
		if (tb1 + tb2 + tb3 < curTestCount && curTestCount <= tb1 + tb2 + tb3 + tb4) begin
			word_curr = 0;
			WE_curr = 0;
			D_IN_curr = 0;
			if (curTestCount == tb1 + tb2 + tb3 + tb4)
				word_curr = 1;
		end

	// Testsuite 5: Write 1
		if (tb1 + tb2 + tb3 + tb4 < curTestCount && curTestCount <= tb1 + tb2 + tb3 + tb4 + tb5) begin
			word_curr = 0;
			WE_curr = 1;
			D_IN_curr = 1;
			if (curTestCount == tb1 + tb2 + tb3 + tb4 + tb5)
				word_curr = 1;
		end

	// Testsuite 6: Read 1
		if (tb1 + tb2 + tb3 + tb4 + tb5 < curTestCount && curTestCount <= tb1 + tb2 + tb3 + tb4 + tb5 + tb6) begin
			WE_curr = 0;
			D_IN_curr = 0;
			word_curr = 0;
			if (curTestCount == tb1 + tb2 + tb3 + tb4 + tb5 + tb6)
				word_curr = 1;
		end
	end


	// Parse integer testcase inputs into binary,
	// write resultant binary to N-bit output pins
	V(WE) <+ transition(WE_curr ? v_high : v_low, 0, trise, tfall);
	V(D_IN) <+ transition(D_IN_curr ? v_high : v_low, 0, trise, tfall);
	V(word) <+ transition(word_curr ? v_high : v_low, 0, trise, tfall);

end

endmodule