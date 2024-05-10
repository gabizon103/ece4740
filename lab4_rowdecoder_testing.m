%% Before running, set up the testbench cell name on line 8
% your decoder outputs should be labeled as Y0,Y1,Y2,Y3, ..., Y63
% your decoder inputs should be labeled as A5, A4, A3, A2, A1, A0
%

% set up the name of your testbench cell
tb_name = 'testbench_directory';

% set up cds_srr function
addpath('/opt/cadence/INNOVUS201/tools.lnx86/spectre/matlab/64bit');

% directory that contains the simulation outputs
directory = sprintf('%s/Cadence/%s.psf', getenv('HOME'), tb_name);

% set up basic parameters
Vdd = 1.2; % define vdd

% define period (in ps)
period_a = 1000; % A
period_b =  500; % B

% get input signals
a = cds_srr(directory, 'tran-tran', '/A', 0);
b = cds_srr(directory, 'tran-tran', '/B', 0);

% convert time into ps
t_ps = a.time*1e12;

% extract voltages of signals
a = a.V;
b = b.V;

% get output signals and put them together in a table where the i-th
% column corresponds to the 'Y(i-1)' output
y_mtx = [];
for i=1:4
    signal_name = ['/Y',int2str(i-1)];
    y = cds_srr(directory, 'tran-tran', signal_name, 0);
    y_mtx = [y_mtx y.V];
end

exp_y_mtx = zeros(size(y_mtx));
sample_wvf = zeros(size(y_mtx));
mydecoder_output = zeros(4,4);
exp_decoder_output = zeros(4,4);

% we sample the inputs at the middle of a cycle
t_ps_sample_in = 6*period_a + period_b/2 + (0:3)*period_b;

% we sample the outputs 230ps after an input changes (each 500ps),
% during the fourth time the inputs repeat
t_ps_sample_out = 6*period_a + 10 + 230 + (0:3)*period_b;

%% decoder output

% create base for expected output waveform
a_bits = (a > Vdd/2);
b_bits = (b > Vdd/2);
vec_bits = [a_bits b_bits];
exp_dec = bi2de(vec_bits,'left-msb');