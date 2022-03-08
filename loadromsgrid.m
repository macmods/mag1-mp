function romsgrid = loadromsgrid
% loads relevant variables from ROMS gridfile

    Simu = 2 ; % 1 for L2 , 0 for L0, 2 for L2-SCB
    [romsgrid.pm romsgrid.pn romsgrid.lon_rho romsgrid.lat_rho romsgrid.lon_psi romsgrid.lon_psi romsgrid.f romsgrid.mask_rho romsgrid.h romsgrid.angle romsgrid.NY romsgrid.NX romsgrid.NZ] = loadgrid(Simu);
        romsgrid.theta_s = 6.0;
        romsgrid.theta_b = 3.0;
        romsgrid.hc = 250;
        romsgrid.sc_type = 'new2012'; % for my zlevs4!!
    


end