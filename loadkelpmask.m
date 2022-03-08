function [romsgrid] = loadkelpmask(romsgrid,mindepth)
% Create a kelp mask for the ROMS Grid
% 0 = no kelp
% 1 = kelp

romsgrid.kelp_mask = zeros(size(romsgrid.lon_rho,1),size(romsgrid.lat_rho,2));
romsgrid.kelp_mask(romsgrid.h > mindepth) = 1;

% borders have PAR = 0
romsgrid.kelp_mask(1,:) = 0;
romsgrid.kelp_mask(:,1) = 0; %romsgrid.kelp_mask(:,1:200) = 0;
romsgrid.kelp_mask(end,:) = 0;
romsgrid.kelp_mask(:,end) = 0;

%romsgrid.kelp_mask([1:2:end],[2:2:end]) = 0;
%romsgrid.kelp_mask([2:2:end],[1:2:end]) = 0;

romsgrid.kelp_mask(romsgrid.mask_rho == 0) = 0;
romsgrid.kelp_mask = logical(romsgrid.kelp_mask);

end