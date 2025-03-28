function weights = nn_predecir()
load("input_descriptors_predict.mat", "input_descriptors")
load("nnetwork.mat", "net1")

nombres_palabras = fieldnames(input_descriptors);
N_palabras = height(nombres_palabras);
%% Concateno bloques de descriptores por cada palabra, verticalmente

xtrain = [];
%ytrain = zeros(40*N_palabras, N_palabras);
for i=1:height(nombres_palabras)
    palabra = nombres_palabras{i};
    palabra_descriptors = input_descriptors.(palabra).descriptors';
    xtrain = [xtrain; palabra_descriptors]; % Apilo 40 filas (muestras) de un tipo de palabra
    %ytrain(40*(i-1)+1:i*40, :) = create_label(nombres_palabras, palabra, 40); % Genero etiquetas
end

%% Evaluo que descriptor/es usar
nbloque = 1;
ndescriptor = 1;
total_descriptors = 60; % Mfcc 13, Bark 32, Pitch 1, Erb 27
slice = xtrain(:, ndescriptor:total_descriptors:end);
%plot(slice(:, nbloque))

%% Mantengo descriptores utiles

% ndescriptors = []; %[1:10:66];
% 
% keep = [];
% for i=1:length(ndescriptors)
%     keep = [keep, xtrain(:, ndescriptors(i):total_descriptors:end)];
% end
% xtrain = keep;

%% Proceso de predicción

% Prediccion del input dataset
weights = (net1(xtrain'));

end