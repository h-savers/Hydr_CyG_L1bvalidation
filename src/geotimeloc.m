function [best_dist_matched, idx1_matched, idx2_matched] = geotimeloc( ...
    T1, lat1, lon1, ...
    T2, lat2, lon2, Tmax, D)

% ---- Colonne ----
T1  = T1(:);
T2  = T2(:);
 [T1, idx1] = sort(T1);
 [T2, idx2] = sort(T2);
 idx1=uint32(idx1) ; 
 idx2=uint32(idx2) ; 

% ---- Radianti ----
lat1 = deg2rad(lat1(idx1));
lon1 = deg2rad(lon1(idx1));
lat2 = deg2rad(lat2(idx2));
lon2 = deg2rad(lon2(idx2));

cos_lat1 = cos(lat1);
cos_lat2 = cos(lat2);

n1 = length(T1);
n2 = length(T2);

best_match = zeros(n1,1,'uint32');
best_dist  = inf(n1,1);

R = 6371000;
ang_max = D / R;

j_left  = 1;
j_right = 1;

for i = 1:n1
disp(['Progress: i=' char(string(i)) ' of ' char(string(n1))])

% ---- Finestra temporale ----
    lower = T1(i) - Tmax;
    upper = T1(i) + Tmax;
    
    while j_left <= n2 && T2(j_left) < lower
        j_left = j_left + 1;
    end
    
    if j_right < j_left
        j_right = j_left;
    end
    
    while j_right <= n2 && T2(j_right) <= upper
        j_right = j_right + 1;
    end
    
    if j_right <= j_left
        continue
    end
    
    idx = j_left:j_right-1;
    
    % =============================
    % 1) FILTRO LATITUDINE (molto veloce)
    % =============================
    dlat = abs(lat2(idx) - lat1(i));
    mask = dlat <= ang_max;
    
    if ~any(mask)
        continue
    end
    
    idx = idx(mask);
    
    % =============================
    % 2) FILTRO LONGITUDINE
    % =============================
    dlon = abs(lon2(idx) - lon1(i));
    dlon = min(dlon, 2*pi - dlon);   % wrap globale
    
    lon_thresh = ang_max / max(cos_lat1(i),1e-12);
    mask = dlon <= lon_thresh;
    
    if ~any(mask)
        continue
    end
    
    idx = idx(mask);
    
    % =============================
    % 3) HAVERSINE SOLO SU POCHI
    % =============================
    dlat = lat2(idx) - lat1(i);
    dlon = lon2(idx) - lon1(i);
    
    a = sin(dlat*0.5).^2 + ...
        cos_lat1(i) .* cos_lat2(idx) .* ...
        sin(dlon*0.5).^2;
    
    a = max(0, min(1, a));
    
    % soglia equivalente in termini di a
    a_max = sin(ang_max/2)^2;
    
    mask = a <= a_max;
    
    if ~any(mask)
        continue
    end
    
    idx = idx(mask);
    a   = a(mask);
    
    % minimo
    [min_a, k] = min(a);
    
    best_match(i) = idx(k);
    best_dist(i)  = 2 * R * asin(sqrt(min_a));
    
end
best_match_reord(idx1)=best_match ;
idx1_matched=find(best_match_reord>0) ; 
idx2_matched=idx2(best_match_reord(best_match_reord>0)) ; 
best_dist_matched(idx1)=best_dist ;
best_dist_matched=best_dist_matched(best_match_reord>0) ;
% best_match(idx1)=best_match ; best_dist(idx1)=best_dist ; 
end
