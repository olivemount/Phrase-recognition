function procesado_de_segmentos_input(tc, ID)
blocks = 20;
nsamples = 4800;
t_ventana = 0.03; % 30ms
muestras_ventana = nsamples / blocks;
ventana = hamming(muestras_ventana);
fs = 8000;
r = 24;
threshold = 0.005;
gaps = 100;

%% Guardo audio
Tc = tc;
recobj = grabar_audio(Tc, fs, r, ID);
audio = getaudiodata(recobj)';
audiowrite('AudioDataBase\Predict\Unknown.wav', audio, fs);

%% Pre procesado de audio

% Obtengo el contenido del directorio de la db
db_dir = "AudioDataBase\Predict\";
archivos = dir(db_dir);

% Creo el struct que tendrá la forma: palabra{audio, medios, limites, descriptores}
palabras = struct();

for i=3:height(archivos)
    % Nombre de un field que tendra el struct
    nombre_palabra = "p" + "Unknown";

    % Creo otro struct para cada palabra
    palabras.(nombre_palabra) = struct();

    % Agrego el audio al struct correspondiente a su palabra
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

    % Guardo los segmentos del audio en archivos individuales
    for z=1:height(limites)
        s1 = limites(z, 1);
        s2 = limites(z, 2);
        segmento = audio(s1:s2);
        audioname = sprintf('AudioDataBase\\Predict\\Unknown%d.wav', z);
        audiowrite(audioname, segmento, fs);
    end

end


%% Obtencion de descriptores
descriptores = audioFeatureExtractor(SampleRate=fs, ...
                                     Window=ventana, ...
                                     OverlapLength=0, ...
                                     erbSpectrum=true ...
                                     );

nombres_palabras = fieldnames(palabras);
for i=1:height(nombres_palabras)
    palabra = nombres_palabras{i};
    reps = height(palabras.(palabra).medios_field);
    seg_descriptores = [];
    for y=1:reps
        % Obtengo segmentoy
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

input_descriptors = struct();
nombres_palabras = fieldnames(palabras);
for i=1:height(nombres_palabras)
    palabra = nombres_palabras{i};
    input_descriptors.(palabra).label = i;
    input_descriptors.(palabra).descriptors = palabras.(palabra).descriptores_field;
end

%% Guardo la data obtenida en un archivo .mat

save("input_descriptors_predict.mat", "input_descriptors")

end