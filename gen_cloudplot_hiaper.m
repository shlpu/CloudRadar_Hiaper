function [] = gen_cloudplot_hiaper(filepath, plot_type, flightpath_flag)
%% Documentation Section
% Script:  gen_cloudplot_hiaper.m
% Author:  Laura Tomkins
% Version Date:  20 July 2017
% Purpose:  Plots cloud radar reflectivity and velocity data from Hiaper aircraft
% files are in cfrad format. Function inputs filepath and plot types, generates data arrays
% and plots the data and outputs figures 
% 
% Input Arguments: 
%        (a) filepath - path of file to plot
%        (b) plot_type - type of data to plot (can be 'ref', 'vel', or 'both')
%        (c) flightpath_flag - option to plot the track of the flight (can be 'on' or 'off')
%
% Output Arguments: 
%        depending on plot_type, and flightpath_flag, function will output
%        1-3 figures (reflectivity, velocity, flight path)
%
% Functions Used: gen_netcdfvariablenames.m
%                 gen_readnetcdf2array_v3.m
%                 LCH_Spiral.m
%                 Colormap_DV_BWR.m
%
% Required Paths: N/A
%
% Example usage: 
%       gen_cloudplot_hiaper(''/home/disk/molari1/neusarchive/hiapercloudradar/...
%           cfradial/moments/qcv1/10hz/20150202/cfrad.20150202_140000.121_to_...
%           20150202_140100.034_HCR_v0_s00_el-90.00_SUR.nc', 'both', 'on');


%   Written By: Laura Tomkins, July 2017

%%

addpath(genpath('/home/disk/zathras/ltomkins/matlab/c130'));

% file info
fields = get_netcdfvariablenames(filepath);
[PP_dimcell, PP_struct] = gen_readnetcdf2array_v3(filepath, fields{:,1} );

% time

radarStart = PP_struct(11).data(:);                                 % start time of data
radar.starttime = [radarStart(1),radarStart(2),radarStart(3),radarStart(4),radarStart(6),...
    radarStart(7),radarStart(9),radarStart(10),radarStart(12),radarStart(13),...
    radarStart(15),radarStart(16),radarStart(18),radarStart(19)];   % generate time string (there HAS to be an easier way)
radar.starttime = datenum(radar.starttime,'yyyymmddHHMMSS');        % date num of start time

timeSeconds = PP_struct(71).data;                                   % time since volume start [s]
timeSeconds = timeSeconds./86400;                                   % convert seconds to fraction of a day
radar.timelist = radar.starttime + timeSeconds;                     % add to data start time

% plane altitide

radar.altitude = PP_struct(90).data;                                % plane altitude [m]

% gate info

radar.firstgate = radar.altitude - PP_struct(72).attributes{4,2};   % first gate altitude
radar.range = PP_struct(72).data;                                   % distance between plane and center of gates [m]
radar.ngates = PP_dimcell{2,2};                                     % number of gates
radar.ntimes = PP_dimcell{1,2};
radar.gatespacing = PP_struct(72).attributes{5,2};                  % gate spacing [m]

% data

radar.reflectivity = double(PP_struct(103).data);                           % reflectivity data [dBZ]
radar.velocity = double(PP_struct(106).data);                               % velocity data [m/s]

radar.missingvalue = PP_struct(103).attributes{5,2};                % reflectivity missing value

radar.reflectivity(radar.reflectivity==radar.missingvalue)=NaN;
radar.velocity(radar.velocity==radar.missingvalue)=NaN;

% lat and lon lists for plotting flight track
radar.latlist = PP_struct(88).data;                                 % stores list of latitude points for flight track
radar.lonlist = PP_struct(89).data;                                 % stores list of longitude points for flight track

% make arrays for plotting
timedata = double((repmat(radar.timelist,1, radar.ngates))');               % repeat copies of time to make matrix same size as data

heightdata = (repmat(radar.firstgate,1,radar.ngates))';             % repeat copies of first gate height to make matrix same as data
heightdata = double(heightdata - repmat(radar.range, 1, radar.ntimes));     % add range to height of first gate

% remove data where altitude is less than 0
minAltLoc = min(find(heightdata<0));                                % find lowest index where altitude is below zero
heightdata(minAltLoc:end,:)=[];
timedata(minAltLoc:end,:)=[];

refdata = radar.reflectivity;
refdata(minAltLoc:end,:)=[];
veldata = radar.velocity;
veldata(minAltLoc:end,:)=[];


% Plotting

switch plot_type
    case 'ref'
    f1=figure;
    surf(timedata, heightdata, refdata, 'EdgeColor', 'none'); view(2); % sets view to xy plane
    % colorbar
    map1=colormap(LCH_Spiral(150,1,180,1)); % color scale for reflectivity
    map1=flipud(map1); % flips color scale
    colormap(map1); cbar1 = colorbar; caxis([-40 0]);
    cbTitle1 = get(cbar1, 'Title'); titleString = 'Reflectivity (dBZ)';
    set(cbTitle1, 'String', titleString); set(cbTitle1,'FontSize',16);
    set(f1, 'Position', [1262 -144 1920 963]); % automatically sets position
    set(gca,'FontSize',16);
    xlabel('HH:MM:SS GMT'); ylabel('Height(m)');
    title_start = datestr(radar.timelist(1)); title_end = datestr(radar.timelist(end));
    title([title_start, ' to ', title_end]);
    datetick('x','HH:MM:SS'); axis tight
    
    case 'vel'
    f2=figure;
    surf(timedata, heightdata, refdata, 'EdgeColor', 'none'); view(2); % sets view to xy plane
    % colorbar
    map2=colormap(Colormap_DV_BWR(50, 0.3, .9)); % color scale for velocity
    colormap(map2);  cbar2 = colorbar; caxis([-30 30]);
    cbTitle2 = get(cbar2, 'Title'); titleString = 'Velocity (m/s)';
    set(cbTitle2, 'String', titleString);  set(cbTitle2,'FontSize',16);
    set(f2, 'Position', [1262 -144 1920 963]); % automatically sets position
    set(gca,'FontSize',16);
    xlabel('HH:MM:SS GMT'); ylabel('Height(m)');
    title_start = datestr(radar.timelist(1)); title_end = datestr(radar.timelist(end));
    title([title_start, ' to ', title_end]);
    datetick('x','HH:MM:SS');  axis tight
    
    case 'both'
    f1=figure;
    surf(timedata, heightdata, refdata, 'EdgeColor', 'none'); view(2); % sets view to xy plane
    % colorbar
    map1=colormap(LCH_Spiral(150,1,180,1)); % color scale for reflectivity
    map1=flipud(map1); % flips color scale
    colormap(map1); cbar1 = colorbar; caxis([-40 0]);
    cbTitle1 = get(cbar1, 'Title'); titleString = 'Reflectivity (dBZ)';
    set(cbTitle1, 'String', titleString); set(cbTitle1,'FontSize',16);
    set(f1, 'Position', [1262 -144 1920 963]); % automatically sets position
    set(gca,'FontSize',16);
    xlabel('HH:MM:SS GMT'); ylabel('Height(m)');
    title_start = datestr(radar.timelist(1)); title_end = datestr(radar.timelist(end));
    title([title_start, ' to ', title_end]);
    datetick('x','HH:MM:SS'); axis tight
    
    f2=figure;
    surf(timedata, heightdata, refdata, 'EdgeColor', 'none'); view(2); % sets view to xy plane
    % colorbar
    map2=colormap(Colormap_DV_BWR(50, 0.3, .9)); % color scale for velocity
    colormap(map2);  cbar2 = colorbar; caxis([-30 30]);
    cbTitle2 = get(cbar2, 'Title'); titleString = 'Velocity (m/s)';
    set(cbTitle2, 'String', titleString);  set(cbTitle2,'FontSize',16);
    set(f2, 'Position', [1262 -144 1920 963]); % automatically sets position
    set(gca,'FontSize',16);
    xlabel('HH:MM:SS GMT'); ylabel('Height(m)');
    title_start = datestr(radar.timelist(1)); title_end = datestr(radar.timelist(end));
    title([title_start, ' to ', title_end]);
    datetick('x','HH:MM:SS');  axis tight
    otherwise
    print('Invalid plot type')
end

% plotting track of aircraft

if strcmp(flightpath_flag, 'on')
    f3=figure;
    set(f3,'color','w');
    set(f3, 'Position', [680 181 831 757]);
    ax3 = axesm('lambert', 'Frame','on','Grid','on','MapLatLimit',[41.75, 43.5],...
        'MapLonLimit',[-72, -69.75], 'MeridianLabel','on','ParallelLabel','on',...
        'MLineLocation',2,'PLineLocation',2,...
        'FontSize', 18); 
    set(ax3,'FontSize',16);   
    title(['Flight Path for ',title_start, ' to ', title_end]);

    axis off
    tightmap

    latlim = getm(ax3, 'maplatlimit');
    lonlim = getm(ax3, 'maplonlimit');

    states = shaperead('usastatehi', 'UseGeoCoords', true, 'BoundingBox', [lonlim', latlim']);
    hold on
    geoshow(gca, states, 'FaceColor', 'none')
    scatterm(radar.latlist, radar.lonlist, 10, 'r', 'LineWidth', 1)

elseif strcmp(flightpath_flag, 'off')
    
else
    warning('No defined flight track flag')
end


