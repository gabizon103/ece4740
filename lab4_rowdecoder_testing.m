% set up cds_srr function
addpath('/opt/cadence/INNOVUS201/tools.lnx86/spectre/matlab/64bit');

% directory that contains the simulation outputs
directory = sprintf('%s/Cadence/ece4740/%s.psf', getenv('HOME'), '6_64_decoder_signals');

% set up basic parameters
Vdd = 1.2; % define vdd
addrBits = 6;
outBits = 64;
nTestBenches = 1;
%nTestCases = 8; % 2 for testing
nTestCases = 64;
startDelay = 1000;

% define period (in ps)
period_a = 4000; % A
period_clk = 4000; % CLK

% get input signals
addr_0 = cds_srr(directory, 'tran-tran', '/addr_in<0>', 0);

% extract en voltage

% convert time into ps
% t_ps is an array of times that has now been normalized
t_ps = addr_0.time*1e12;


% get output signals and put them together in a table where the i-th
% column corresponds to the 'Y(i-1)' output
y_vec = [];
addr_vec = [];
for i=1:outBits
%   Concatenate the name to access the right Y(i-1) output
    signal_name_y = ['/Y<', int2str(i-1), '>'];
    y = cds_srr(directory, 'tran-tran', signal_name_y, 0);
%   Append voltages to form y_mtx with [Y63 .. Y0]
    y_vec = [y.V y_vec];
end

for i = 1:addrBits
%   Do the same for input vector A across all 8 bits
    signal_name_addr = ['/addr_in<', int2str(i-1), '>'];
    addr = cds_srr(directory, 'tran-tran', signal_name_addr, 0);
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
digital_addr = (addr_vec > Vdd/2);
decimal_addr = bi2de(digital_addr, 'left-msb');
digital_y = (y_vec > Vdd/2);
decimal_y = bi2de(digital_y, 'left-msb');

exp_decimal_y = pow2(decimal_addr);

% Actual output
decoder_output = zeros(nTestCases);
% Expected decoder output
exp_decoder_output = zeros(nTestCases);

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
    decoder_output(i) = decimal_y(t_ps_idx_out);
    exp_decoder_output(i) = exp_decimal_y(t_ps_idx_out);

    if (sum(exp_decoder_output(i,:) ~= decoder_output(i,:)) > 0)
        disp(['Test ' num2str(i)...
            '/' num2str(nTestCases) ...
            ' WRONG -------'...
            'Expected output for input '...
            'addr=' num2str(decimal_addr(t_ps_idx_in)) ...  
            ' is y=' num2str(exp_decoder_output(i)) ...
            ' but measured output is y=' num2str(decoder_output(i))...
            ]) 
        err_flag  = err_flag + 1;
    else
        disp(['Test ' num2str(i)...
            '/' num2str(nTestCases) ...
            ' CORRECT -------'...
            'Expected output for input '...
            'addr=' num2str(decimal_addr(t_ps_idx_in)) ... 
            ' is y=' num2str(exp_decoder_output(i)) ...
            ' Measured output'...
            ' y=' num2str(decoder_output(i))...
            ]) 
    end
end
disp(['Correct cases: ' num2str(nTestCases - err_flag) '/' num2str(nTestCases)]);
if err_flag == 0
    disp('The decoder circuit has no errors :)')
end