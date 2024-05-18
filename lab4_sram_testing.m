% set up cds_srr function
addpath('/opt/cadence/INNOVUS201/tools.lnx86/spectre/matlab/64bit');

% directory that contains the simulation outputs
directory = 'lab4_sram_testing.psf';

% set up basic parameters
Vdd = 1.2; % define vdd
numBits = 8;
% numBits = 4;
nTestBenches = 6;
%nTestCases = 8; % 2 for testing
nTestCases = 12;
startDelay = 1000;

% define period (in ps)
period_a = 4000; % A
period_clk = 4000; % CLK

% get input signals
we = cds_srr(directory, 'tran-tran', '/WE', 0);
% Extract voltage for Cin

we = we.V;
% convert time into ps
% t_ps is an array of times that has now been normalized
t_ps = bit_0.time*1e12;

% extract voltages of signals
% a = a.V;
% b = b.V;

% get output signals and put them together in a table where the i-th
% column corresponds to the 'Y(i-1)' output
d_in_vec = [];
d_out_vec=[];
addr_vec = [];

for i=1:numBits

%   Do the same for input vector A across all 8 bits
    signal_name = ['/data_in<', int2str(i-1), '>'];
    d_in = cds_srr(directory, 'tran-tran', signal_name, 0);
%     Append to form [A7 .. A0]
    d_in_vec = [d_in.V d_in_vec];

    signal_name = ['/DATA_out<', int2str(i-1), '>'];
    d_out = cds_srr(directory, 'tran-tran', signal_name, 0);
%     Append to form [A7 .. A0]
    d_out_vec = [d_out.V d_out_vec];

    signal_name = ['/addr<', int2str(i-1), '>'];
    addr = cds_srr(directory, 'tran-tran', signal_name, 0);
%     Append to form [A7 .. A0]
    addr_vec = [addr.V addr_vec];

end

% Expected output
% exp_y_vec = zeros(size(s_vec));
% exp_cout_vec = zeros(size(s_vec, 1));
% sample_wvf = zeros(size(s_vec));decimal_cin = (cin > Vdd/2);

% we sample the inputs from FF at the middle of a cycle
%t_ps_sample_in = startDelay + period_a/2 + (0:nTestCases)*period_a;
t_ps_sample_in = startDelay + period_clk/2 + (0:nTestCases)*period_clk;

% we sample the outputs midway after an input changes (each 2000ps),
t_ps_sample_out = startDelay + period_clk*0.75 + (0:nTestCases)*period_clk;

%% adder output

% Convert the analog output into digital signals and then into decimal numbers in an array
digital_d_in = (d_in_vec > Vdd/2);
decimal_d_in = bi2de(digital_d_in,'left-msb');

digital_d_out = (d_out_vec > Vdd/2);
decimal_d_out = bi2de(digital_d_out, 'left-msb');

digital_addr = (addr_vec > Vdd/2);
decimal_addr = bi2de(digital_addr, 'left-msb');

digital_WE = (we > Vdd/2);
decimal_WE = bi2de(digital_WE, 'left-msb');


% Actual output
mydriver_output = zeros(nTestCases);
% Expected decoder output
exp_driver_output = zeros(nTestCases);
% Actual cout
mydriver_WE = zeros(nTestCases);
exp_driver_output = [170, 85];



%Check each one of the sampling points
err_flag = 0;
for i=1:nTestCases
    % find t_ps closest (from the right) to the t_ps_sample_in and _out
%     What does this do?
%     t_ps_idx_in get the first index corresponding to \geq sample time
    t_ps_idx_in  = find(t_ps-t_ps_sample_in(i)>=0,1);
%     t_ps_idx_out get the first actual recorded output time that is more than the sample time
    t_ps_idx_out = find(t_ps-t_ps_sample_out(i)>=0,1);
    
    % measure the outputs and declare 1 if it is greater than Vdd/2    
    mydriver_output(i) = decimal_bit(t_ps_idx_out);

    
    mydriver_WE(i) = digital_WE(t_ps_idx_out);

    if ((mydriver_WE(i) ~= 1 && i==4 && mydriver_output(i) == 170) || (mydriver_WE(i) ~= 1 && i==6 && mydriver_output(i) == 85))
        disp(['Test ' num2str(i)...
            '/' num2str(nTestCases) ...
            ' WRONG -------'...
            'Expected output for input '...
            ' is bit=' num2str(exp_driver_output(i)) ...
            ' and WE=' num2str(mydriver_WE(i)) ...
            ' but measured output is bit=' num2str(mydriver_output(i))...
            ' and WE=' num2str(mydriver_WE(i))...
            ]) 
        err_flag  = err_flag + 1;
    else
        disp(['Test ' num2str(i)...
            '/' num2str(nTestCases) ...
            ' CORRECT -------'...
            'Expected output for input is'...
            'bit=' num2str(decimal_bit(t_ps_idx_in)) ...
            ' is D_in=' num2str(exp_driver_output(i)) ...
            ' and WE=' num2str(mydriver_WE(i)) ...
            ' Measured output'...
            ' bit =' num2str(mydriver_output(i))...
            ' and WE=' num2str(mydriver_WE(i))...
            ]) 
    end
end
disp(['Correct cases: ' num2str(nTestCases - err_flag) '/' num2str(nTestCases)]);
if err_flag == 0
    disp('The driver circuit has no errors :)')
end