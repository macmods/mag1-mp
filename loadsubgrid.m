function romsgrid = loadsubgrid(romsgrid_full,subgrid,msplit)
% take the subsampled grid


        romsgrid.pm = romsgrid_full.pm(msplit(subgrid,1):msplit(subgrid,2),:);
        romsgrid.pn = romsgrid_full.pn(msplit(subgrid,1):msplit(subgrid,2),:);
        romsgrid.lon_rho = romsgrid_full.lon_rho(msplit(subgrid,1):msplit(subgrid,2),:);
        romsgrid.lat_rho = romsgrid_full.lat_rho(msplit(subgrid,1):msplit(subgrid,2),:);
        romsgrid.lon_psi = romsgrid_full.lon_psi(msplit(subgrid,1):msplit(subgrid,2),:);
        romsgrid.f = romsgrid_full.f(msplit(subgrid,1):msplit(subgrid,2),:);
        romsgrid.mask_rho = romsgrid_full.mask_rho(msplit(subgrid,1):msplit(subgrid,2),:);
        romsgrid.h = romsgrid_full.h(msplit(subgrid,1):msplit(subgrid,2),:);
        romsgrid.angle = romsgrid_full.angle(msplit(subgrid,1):msplit(subgrid,2),:);
        romsgrid.NY = msplit(subgrid,2) - msplit(subgrid,1) + 1;
        romsgrid.NX = romsgrid_full.NX;
        romsgrid.NZ = romsgrid_full.NZ;
        romsgrid.theta_s = romsgrid_full.theta_s;
        romsgrid.theta_b = romsgrid_full.theta_b;
        romsgrid.hc = romsgrid_full.hc;
        romsgrid.sc_type = romsgrid_full.sc_type;
        romsgrid.kelp_mask = romsgrid_full.kelp_mask(msplit(subgrid,1):msplit(subgrid,2),:);
        
        
end