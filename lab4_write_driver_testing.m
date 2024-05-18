% set up cds_srr function
addpath('/opt/cadence/INNOVUS201/tools.lnx86/spectre/matlab/64bit');

% directory that contains the simulation outputs
directory = 'lab4_8_write_driver.psf';

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
bit_0 = cds_srr(directory, 'tran-tran', '/bit0', 0);
bit0 = cds_srr(directory, 'tran-tran', '/bit0', 0);
bit1 = cds_srr(directory, 'tran-tran', '/bit1', 0);
bit2 = cds_srr(directory, 'tran-tran', '/bit2', 0);
bit3 = cds_srr(directory, 'tran-tran', '/bit3', 0);
bit4 = cds_srr(directory, 'tran-tran', '/bit4', 0);
bit5 = cds_srr(directory, 'tran-tran', '/bit5', 0);
bit6 = cds_srr(directory, 'tran-tran', '/bit6', 0);
bit7 = cds_srr(directory, 'tran-tran', '/bit7', 0);
bit0_b = cds_srr(directory, 'tran-tran', '/bit0_b', 0);
bit1_b = cds_srr(directory, 'tran-tran', '/bit1_b', 0);
bit2_b = cds_srr(directory, 'tran-tran', '/bit2_b', 0);
bit3_b = cds_srr(directory, 'tran-tran', '/bit3_b', 0);
bit4_b = cds_srr(directory, 'tran-tran', '/bit4_b', 0);
bit5_b = cds_srr(directory, 'tran-tran', '/bit5_b', 0);
bit6_b = cds_srr(directory, 'tran-tran', '/bit6_b', 0);
bit7_b = cds_srr(directory, 'tran-tran', '/bit7_b', 0);
we = cds_srr(directory, 'tran-tran', '/net1', 0);
% Extract voltage for Cin
bit0 = bit0.V;
bit0_b = bit0_b.V;
bit1 = bit1.V;
bit1_b = bit1_b.V;
bit2 = bit2.V;
bit2_b = bit2_b.V;
bit3 = bit3.V;
bit3_b = bit3_b.V;
bit4 = bit4.V;
bit4_b = bit4_b.V;
bit5 = bit5.V;
bit5_b = bit5_b.V;
bit6 = bit6.V;
bit6_b = bit6_b.V;
bit7 = bit7.V;
bit7_b = bit7_b.V;
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
bit_vec = [bit0 bit1 bit2 bit3 bit4 bit5 bit6 bit7];
bit_b_vec = [bit0_b bit1_b bit2_b bit3_b bit4_b bit5_b bit6_b bit7_b];

for i=1:numBits

%   Do the same for input vector A across all 8 bits
    signal_name = ['/D_IN<', int2str(i-1), '>'];
    d_in = cds_srr(directory, 'tran-tran', signal_name, 0);
%     Append to form [A7 .. A0]
    d_in_vec = [d_in.V d_in_vec];
    

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

digital_bit = (bit_vec > Vdd/2);
decimal_bit = bi2de(digital_bit, 'left-msb');

digital_bit_b = (bit_b_vec > Vdd/2);
decimal_bit_b = bi2de(digital_bit_b, 'left-msb');

digital_WE = (we > Vdd/2);
decimal_WE = bi2de(digital_WE, 'left-msb');


% Actual output
mydriver_output = zeros(nTestCases);
% Expected decoder output
exp_driver_output = zeros(nTestCases);
% Actual cout
mydriver_WE = zeros(nTestCases);


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
    mydriver_output(i) = digital_bit(t_ps_idx_out);
    exp_driver_output(i) = digital_d_in(t_ps_idx_out);
    
    mydriver_WE(i) = digital_WE(t_ps_idx_out);


    if ((exp_driver_output(i) ~= (mydriver_output(i)) | (exp_driver_output(i,:) ~= (mydriver_output(i,:)))) & mydriver_WE(i) & i>2)
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