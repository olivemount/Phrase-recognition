function [pts, trimmed_audios] = remove_gaps(audiovector, gap_matrix, gapsize, thresh)
    trimmed_audios = {};
    pts = [];

    start = true;
    for i=1:height(gap_matrix)
        gap = gap_matrix(i, 3);
        if gap < gapsize && start
            start_audio = gap_matrix(i,2);
            start = false;
        elseif gap >= gapsize && ~start
            end_audio = gap_matrix(i,1);

            segment = audiovector(start_audio:end_audio); % Pedazo de audio que tiene espacios menor a gapsize consecutivamente
            bool_segment =  segment >= thresh; % El mismo audio de arriba, pero umbralificado¿
            if sum(bool_segment) >= 400 %Si el pedazo de audio umbralificado es muy pequeño (<400), descartar
                trimmed_audios{end+1} = segment; % Append el segmento de audio
                pts = [pts; start_audio end_audio]; %Puntos de inicio y final de cada segmento detectado
            end
            start = true;
        end
    end
end