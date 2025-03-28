function gaps = get_gaps(audiovector, thresh)
    audio_gt_th = abs(audiovector) > thresh;
    
    gaps = []; % Vector que filas de inicio, fin y tamaño del gap
    idx = 1; % Starting index of gap search in audio_gt_th
    while idx <= length(audiovector)
        gap = 0;
        while (idx <= length(audiovector)) & (audio_gt_th(idx) ~= 1) % Mientras que no haya llegado al final del audiovector y, mientras que la muestra sea menor al umbral
            gap = gap + 1; % Añadir 1 al gap que se encontró
            idx = idx + 1; % Desplazar el indice por 1
        end

        if gap ~= 0 % Si el gap es distinto a 0, registrarlo
            start = idx-gap-1;
            fin = start+gap;
            gaps = [gaps; start, fin, gap];
        else % De lo contrario, desplazar el indice por 1
            idx = idx + 1;
        end
    end
end