function [xtrain, xvalidation, ytrain, yvalidation] = repartir2(xdatos, ydatos, porcentaje)
    % El parametro xdatos es un a matriz, porcentaje es un decimal
    % Retorna los un porcentaje del contenido de la matriz xdatos en xtrain, y el remanente en xvalidation
    reps = 40; % Asumo 40 repeticiones por muestra
    ntrain = floor(reps * porcentaje);
    %copy = xdatos;

    xtrain = [];
    xvalidation = [];
    ytrain = [];
    yvalidation = [];
    nsample = 0;
    for i=1:reps:height(xdatos)%-reps
        idxs = randperm(reps);
        idxs = idxs + (reps*nsample);
    
        % Separo de 40 en 40, 32 muestras en aleatorio
        xtrain = [xtrain; xdatos([idxs(1:ntrain)],:)];
        xvalidation = [xvalidation; xdatos([idxs(ntrain+1:end)], :)];

        ytrain = [ytrain; ydatos([idxs(1:ntrain)],:)];
        yvalidation = [yvalidation; ydatos([idxs(ntrain+1:end)], :)];
        nsample = nsample + 1;
    end
end