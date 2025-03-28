% Inicializo ambiente
clear variables;
close all;
clc;

%% Audio y datos de entrada
Tc = 10;
fs = 8000;
r = 24;
ID = 2;
threshold = 0.005;
gaps = 100;
recobj = grabar_audio(Tc, fs, r, ID);
raw = getaudiodata(recobj)';
audiowrite('Celta_1_5.wav', raw, fs);
t = 0:1/fs:Tc - 1/fs;

%% Get gaps

raw_gaps = get_gaps(raw, threshold);
[pts, segments]= remove_gaps(raw, raw_gaps, gaps, threshold);
%% Write segments

for i=1:width(segments)
    audioname = sprintf('Celta%d.wav', i);
    audiowrite(audioname, segments{:,i}, fs);
end