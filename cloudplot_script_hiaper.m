%% Documentation Section
% Script:  cloudplot_script_hiaper.m
% Author:  Laura Tomkins
% Version Date:  20 July 2017
% Purpose:  Plots cloud radar reflectivity and velocity data from Hiaper aircraft
% files are in cfrad format. Script sets up filepath and plot types and gen_cloudplot plots
% the data and outputs figures which are then saved in the script. See gen_cloudplot for more
% information
% 
% Input Arguments: starttime, endtime, plot_type, flighttrack_flag 
%
% Output Arguments: ***************
% Functions Used: gen_makefilelist_withoutput_cfrad.m
%                 gen_cloudplot_hiaper.m
%
% Required Paths: N/A
%
%


%   Written By: Laura Tomkins, July 2017

%% Working 

clear, clc

addpath(genpath('/home/disk/zathras/ltomkins/matlab/c130'));

% file info

starttime = '20150202140001';   % CHANGE
endtime   = '20150202140100';   % CHANGE
plot_type = 'ref';              % CHANGE (can be 'ref', 'vel', or 'both')
flighttrack_flag = 'on';        % CHANGE (can be 'on' or 'off')

inpath = '/home/disk/molari1/neusarchive/hiapercloudradar/cfradial/moments/qcv1/10hz/20150202/';
listdir = '/home/disk/molari1/neusarchive/filelists';
savedir = '/home/disk/zathras/ltomkins/matlab/c130/test_images/';

list_path = gen_makefilelist_withoutput_cfrad(inpath, listdir, 'append', 'hiaper', 'time', starttime, endtime);

for i = 1:length(list_path{1,2})
    
    gen_cloudplot_hiaper(cell2mat(list_path{1,2}(i,1)), plot_type, flighttrack_flag);
    
    keyboard        % put this in to check images before saving them
    
    switch plot_type
        case 'both'
        f1=figure(1); f2=figure(2); f3=figure(3);        
        saveas(f1, [savedir, starttime, '_ref.png'])
        saveas(f2, [savedir, starttime, '_vel.png'])
        saveas(f3, [savedir, starttime, '_path.png'])
        close all
        
        case 'ref'
        f1=figure(1); f2=figure(2);        
        saveas(f1, [savedir, starttime, '_ref.png'])
        saveas(f2, [savedir, starttime, '_path.png'])
        close all
        
        case 'vel'
        f1=figure(1); f2=figure(2);        
        saveas(f1, [savedir, starttime, '_vel.png'])
        saveas(f2, [savedir, starttime, '_path.png'])
        close all
        
        otherwise
        warning('No images saved')
    end
    
end

% filepath = cell2mat(list_path{1,2}(i,1));