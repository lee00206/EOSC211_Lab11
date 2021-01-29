%  Updated CLJ 11/2018

clear; 
close all;

load lab11_data

% Southern Vancouver Island (SVI) Grid of lats/lons
load SouthVI.mat

% Put South VI grid into easier variables
lonMap = SouthVI.lon;    % longitude vector for the SVI map
latMap = SouthVI.lat;    % latitude vector for the SVI map
zMap = -SouthVI.depth;   % 2D array of depths: 
                         % d=0 is the coastline, we will be interested in d=200m
clear SouthVI;           % don't need this any more

%% Temperature, salinity, density, and pressure for first half of 
% % leg E of FK009A cruise, August 2013

load FK009A_demo.mat

%%  Do some preliminary calcs and make a nice plot

% Calculate a smooth version of the 200 m contour. 
[lon200 lat200] = calc200contour(lonMap, latMap, zMap); 

% Compute shortest distance of each ship point with data from the smoothed 200m depth contour
dist200 = shortest_dist(lon, lat, lon200, lat200);

% Get the indices for individual tracks. Output variable is a cell array.
inds=setupInds;


%% Make scatter plots to show temperature as function of distance and depth

% -----------------------
% MAKE SURE YOU UNDERSTAND WHAT meshgrid AND scatter do.  We saw meshgrid
% earlier in the term
% -----------------------
% just extract the shallowest 90m of depth and salinity arrays because 
% there are measurements at these depths on all tracks
saln=saln(1:91,:);       
depths=depths(1:91);

%Plotting the original figure for salinity
figure(1); clf; k=0;


for j=10:-1:1
    %pause;
    
    % extract temps and distances
    ii=inds{j};
    subsal=saln(:,ii);     
    xx=dist200(ii);
    
    % we want to have a (dist,depth) pair for every temp measurement
    [mx,my]=meshgrid(xx,depths);
    
    %This is where we do the actual plotting - this uses the built-in function scatter 
    % scatter needs to be passed 1D arrays as arguments so we must flatten mx, my
    k=k+1; 
    figure(1);         %ADD TO LOOP TO CHOOSE CORRECT FIGURE ACTIVE - not essential here but important in lab
    makeScatterPlot(mx(:),my(:),subsal(:),j,k);
    colorbar;   
    caxis([31 34]);    % add after plotting once to see range of salinities      
    xlim([-20 45]);  
    ylabel('Depth (z)');  title(['Track' num2str(j) ' Temperature']) 
        
    %We only want the xlabel on the bottom row of subplots
    if k==9 | k==10 
        xlabel('Distance from Shelf Break (km)')
    else
        set(gca,'xticklabel', [])
    end

end


% now make a plot that has profiles only where there are data to show
% uneven distribution of casts
figure(2); clf; k=0;


for j=10:-1:1
    %pause;
    
    % extract temps and distances
    ii=inds{j};
    subsal=saln(:,ii);     
    xx=dist200(ii);
    
    % we want to have a (dist,depth) pair for every temp measurement
    [mx,my]=meshgrid(xx,depths);
    
    %This is where we do the actual plotting - this uses the built-in function scatter 
    % scatter needs to be passed 1D arrays as arguments so we must flatten mx, my
    k=k+1; 
    figure(2);         %ADD TO LOOP TO CHOOSE CORRECT FIGURE ACTIVE - not essential here but important in lab
    [x y] = meshgrid(-20:0.5:40,depths);
    Vq = interp2(mx,my,subsal,x,y,'linear');
    nn = ~isnan(Vq);
    makeScatterPlot(x(nn),y(nn),Vq(nn),j,k);
    colorbar;   
    caxis([31 34]);    % add after plotting once to see range of salinities      
    xlim([-20 45]);  
    ylabel('Depth (z)');  title(['Track' num2str(j) ' Temperature']) 
    
    % store values at 0km 
    sal10_pro(:,k) = Vq(x==0);
    
    %store values at 20km
    sal20_pro(:,k) = Vq(x==20);

    
    %We only want the xlabel on the bottom row of subplots
    if k==9 | k==10 
        xlabel('Distance from Shelf Break (km)')
    else
        set(gca,'xticklabel', [])
    end
 
end

 %mean 0-km salinity and standard deviation
    msal10_pro = nanmean(sal10_pro,2);
    sdsal10_pro = nanstd(sal10_pro,[],2);
    mpsdsal10_pro = msal10_pro+sdsal10_pro;
    mmsdsal10_pro = msal10_pro-sdsal10_pro;
    
    %mean 20-km salinity and standard deviation
    msal20_pro = nanmean(sal20_pro,2);
    sdsal20_pro = nanstd(sal20_pro,[],2);
    mpsdsal20_pro = msal20_pro+sdsal20_pro;
    mmsdsal20_pro = msal20_pro-sdsal20_pro;
    
    figure(3)
    
    subplot(1,3,1);
    plot(sal10_pro,depths);
    set(gca,'Ydir','reverse');
    xlabel('Salinity/(g/kg)');
    ylabel('Depth(m)');
    title('a)0km');
    
    subplot(1,3,2);
    plot(sal20_pro,depths);
    set(gca,'Ydir','reverse'); 
    xlabel('Salinity/(g/kg)');
    ylabel('Depth(m)');
    title('b)20km');
    
    subplot(1,3,3);
    hold on;
    plot(msal10_pro,depths,'-k','LineWidth',2);
    plot(mpsdsal10_pro,depths,'-k');
    plot(mmsdsal10_pro,depths,'-k');
    plot(msal20_pro,depths,'-r','LineWidth',2);
    plot(mpsdsal20_pro,depths,'--r');
    plot(mmsdsal20_pro,depths,'--r');
    set(gca,'Ydir','reverse');
    xlabel('Salinity/(g/kg)');
    ylabel('Depth(m)');
    title('c)');
    
    set(gca,'tickdir','out');
    
    answer = 'Yes, the mean profiles from the two locations different by more than the standard deviation in the data because the black line with the mean+std(X=0km) does not overlap with the red line with the mean-std(X=20km) except at 8km depth';
    fprintf(answer)

    % partner.name = 'Christopher Ng';
    % Time_spent = 06;