clear variables
load("data_descriptors.mat")

nombres_palabras = fieldnames(data_descriptors);
N_palabras = height(nombres_palabras);
%% Concateno bloques de descriptores por cada palabra, verticalmente

xtrain = [];
ytrain = zeros(40*N_palabras, N_palabras);
for i=1:height(nombres_palabras)
    palabra = nombres_palabras{i};
    palabra_descriptors = data_descriptors.(palabra).descriptors';
    xtrain = [xtrain; palabra_descriptors]; % Apilo 40 filas (muestras) de un tipo de palabra
    ytrain(40*(i-1)+1:i*40, :) = create_label(nombres_palabras, palabra, 40); % Genero etiquetas
end

%% Evaluo que descriptor/es usar
nbloque = 1;
ndescriptor = 1;
total_descriptors = 28; % Mfcc 13, Bark 32, Pitch 1, Erb 27
slice = xtrain(:, ndescriptor:total_descriptors:end);
plot(slice(:, nbloque))
title("Descriptor numero 1, del bloque numero 1")
xlabel("Muestras")
ylabel("Magnitud")

%% Mantengo descriptores utiles

ndescriptors = []; %[1:10:66];

% keep = [];
for i=1:length(ndescriptors)
    keep = [keep, xtrain(:, ndescriptors(i):total_descriptors:end)];
end
% xtrain = keep;

%% Reparto 80% train, 20% validation

% [xtrain, xval] = repartir(xtrain', 0.8);
% [ytrain, yval] = repartir(ytrain', 0.8);

[xtrain, xval, ytrain, yval] = repartir2(xtrain, ytrain, 0.8);

%% Entrenar neural net

net1 = patternnet(400);
net1.trainParam.epochs = 100;
net1 = train(net1, xtrain', ytrain');

%% Proceso de validacion

% Prediccion del dataset de training
red1_p = (net1(xtrain'));
perf1 = perform(net1, ytrain', red1_p);
figure(1);
plotconfusion(red1_p, ytrain');

% Prediccion del dataset de validation
red1_p = (net1(xval'));
perf1 = perform(net1, yval', red1_p);
figure(2);
plotconfusion(red1_p, yval');

save("nnetwork.mat", "net1")