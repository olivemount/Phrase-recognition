function [train, validation] = repartir(datos, porcentaje)
    % El parametro datos es un a matriz, porcentaje es un decimal
    % Retorna los un porcentaje del contenido de la matriz datos en train, y el remanente en validation
    copy = datos;
    N = width(copy);
    n_train = floor(N * porcentaje);
    repeat = zeros(1, n_train);
    train = [];
    for i=1:n_train
        N = width(copy);
        num = randi([1, N]);
        select = copy(:, num); % Copia columna seleccionada
        copy(:, num) = []; % Elimina columna
        train = [train, select]; % Agrega columna a conjunto de entrenamiento
        repeat(i) = num;
    end

    validation = copy;
end