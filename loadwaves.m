function envt = loadwaves(wavefilename,year,subgrid,msplit)
        
% Which file based on day of year
    VAR = {'ssh' 'wep'};
    for vv=1:length(VAR)
        file = strcat(wavefilename,VAR(vv),'_',num2str(year),'.nc');
        file = char(file);
        waves.(string(VAR(vv))) = squeeze(ncread(file,char(VAR(vv))));
    end
    envt.Hs = waves.ssh(msplit(subgrid,1):msplit(subgrid,2),:,:); 
    envt.Tw = waves.wep(msplit(subgrid,1):msplit(subgrid,2),:,:);

end
