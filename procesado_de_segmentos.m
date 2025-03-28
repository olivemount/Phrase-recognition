clear variables
blocks = 20;
nsamples = 4800;
t_ventana = 0.03; % 30ms
muestras_ventana = nsamples / blocks;
ventana = hamming(muestras_ventana);
fs = 8000;
threshold = 0.005;
gaps = 100;
%palabras = ["Madrid", "Celta", "Atletico", "Español", "Sevilla", "Girona", "Betis", "0", "1", "2", "3", "4", "5", "6"];
palabras_check = ["pMadrid", "pSevilla", "pGirona", "pBetis", "pAtletico", "p0", "p1", "p2", "p3", "p4", "p5", "p6"]; % Quitar cuando la DB esté completa #1

%% Pre procesado de audio

% Obtengo el contenido del directorio de la db
db_dir = "AudioDataBase\Train_Validation\";
archivos = dir(db_dir);

% Creo el struct que tendrá la forma: palabra{audio, medios, limites, descriptores}
palabras = struct();

for i=3:height(archivos)
    % Nombre de un field que tendra el struct
    nombre_palabra = "p" + archivos(i).name;

    % Quitar cuando la DB esté completa #1
    if ~ismember(nombre_palabra, palabras_check) 
        continue
    end

    % Creo otro struct para cada palabra
    palabras.(nombre_palabra) = struct();

    % Obtengo el contenido del directorio de las repeticiones
    repeticiones_dir = db_dir + archivos(i).name + "\Repeticiones";
    repeticiones = dir(repeticiones_dir);
    audio = []; % ¿cuando la db esté completa: audio = zeros(1, 80*fs) #2
    for y=3:height(repeticiones)
        nombre_audio = repeticiones(y).name;
        [raw, ~] = audioread(repeticiones_dir + "\" + nombre_audio);
        audio = [audio, raw']; 
    end

    % Agrego el audio concatenado al struct correspondiente a su palabra
    palabras.(nombre_palabra).audio_field = audio;

    % Hayo cuantas repeticiones hay por archivo, asi como tambien sus
    % puntos de inicio, final y medios.
    raw_gaps = get_gaps(audio, threshold);
    [pts, ~] = remove_gaps(audio, raw_gaps, gaps, threshold);

    %Calculo el midpoint de cada segmento
    medios_idx = floor((pts(:,2) + pts(:, 1)) ./ 2);

    % Calculo el inicio y fin de cada segmento
    half = nsamples/2;
    inicio = medios_idx - half;
    final = medios_idx + half;
    limites = [inicio, final];

    % Agrego los medios y los limites al struct
    palabras.(nombre_palabra).medios_field = medios_idx;
    palabras.(nombre_palabra).limites_field = limites;

end


%% Obtencion de descriptores
descriptores = audioFeatureExtractor(SampleRate=fs, ...
                                     Window=ventana, ...
                                     OverlapLength=0, ...
                                     erbSpectrum=true ...
                                     );
info(descriptores)

nombres_palabras = fieldnames(palabras);
for i=1:height(nombres_palabras)
    palabra = nombres_palabras{i};
    reps = height(palabras.(palabra).medios_field);
    seg_descriptores = [];
    for y=1:reps
        % Obtengo segmento
        inicio = palabras.(palabra).limites_field(y, 1);
        fin = palabras.(palabra).limites_field(y, 2);
        segmento = palabras.(palabra).audio_field(inicio:fin-1)';
        
        % Obtengo descriptores del segmento
        block_descriptores = extract(descriptores, segmento)';
        seg_descriptores = [seg_descriptores, block_descriptores(:)];
    end

    palabras.(palabra).descriptores_field = seg_descriptores;
end

%% Deposito descriptores y su label en nuevo struct

data_descriptors = struct();
nombres_palabras = fieldnames(palabras);
for i=1:height(nombres_palabras)
    palabra = nombres_palabras{i};
    data_descriptors.(palabra).label = i;
    data_descriptors.(palabra).descriptors = palabras.(palabra).descriptores_field;
end

%% Guardo la data obtenida en un archivo .mat

save("data_descriptors.mat", "data_descriptors")