function envt = loadenvt(roms,waves,m,n)
        
        % roms data
        envt.temp = squeeze(roms.temp(m,n,:,:));
        envt.NO3 = squeeze(roms.NO3(m,n,:,:));
        envt.NH4 = squeeze(roms.NH4(m,n,:,:));
        envt.DON = squeeze(roms.DON(m,n,:,:));
        envt.magu = squeeze(roms.magu(m,n,:,:));
        envt.chla = squeeze(roms.chla(m,n,:,:));
        
        envt.PAR = squeeze(roms.PAR(m,n,:)); % only surface input
        
        % wave data
        envt.Hs = squeeze(waves.Hs(m,n,:));
        envt.Tw = squeeze(waves.Tw(m,n,:));
        
        
end
        