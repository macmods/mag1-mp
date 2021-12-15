function [harvest, kelp] = harvest_crit(harvest,kelp,farm,gr_counter)
% Calculate harvest per frond and sum across area
% Output: harvest structure
%   Nf harvest per area (x, y)


global param

    % How much to remove

        temp_B = find_nan(kelp.B);
        sumB = trapz(farm.z_arr,temp_B); % g-dry

        harvest.canopyB(1,gr_counter) = sumB - 1.1875.*1e3;
        fracB = harvest.canopyB(1,gr_counter)/sumB;

        temp_Nf = find_nan(kelp.Nf);
        sumNf = trapz(farm.z_arr,temp_Nf); % g-dry
        harvest.canopyNf(1,gr_counter) = sumNf .* fracB;

        temp_Ns = find_nan(kelp.Ns);
        sumNs = trapz(farm.z_arr,temp_Ns); % g-dry
        harvest.canopyNs(1,gr_counter) = sumNs .* fracB;


    % convert X percent of fronds to senescence
    
        cut_i = find(kelp.fronds.status == 1);
        cut_s = ceil(length(cut_i).*0.5);
        kelp.fronds.status(min(cut_i):min(cut_i)+cut_s-1) = 2;
        
        % replace those designated as senescing with a NaN end age so that natural senescence no longer over-rides
        kelp.fronds.end_age(min(cut_i):min(cut_i)+cut_s-1) = 9999;
        clear cut_i cut_s

        
    % Take away what was harvested
    
        Nf_new = sumNf - harvest.canopyNf(1,gr_counter);
        Ns_new = sumNs - harvest.canopyNs(1,gr_counter);
        
        kelp.height = (param.Hmax .* Nf_new./param.Qmin./1e3 )./ (param.Kh + Nf_new./param.Qmin./1e3);
        kelp.b_per_m = make_Bm(kelp.height,farm);
    
        kelp.Nf = Nf_new .* kelp.b_per_m;
        kelp.Ns = Ns_new .* kelp.b_per_m;



end