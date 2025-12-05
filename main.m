
fitxer_csv = 'WormDataA.csv';
carpeta = 'WormImages/';
resultats_folder = 'resultats/';

if ~exist(resultats_folder, 'dir')
    mkdir(resultats_folder);
end

fid = fopen(fitxer_csv, 'r');
titol = fgetl(fid);  % llegim la primera línia (capçalera) i l’ignorem

correctes = 0;
total = 0;

encerts_totals = 0;
total_cucs = 0;

while ~feof(fid)
    linia = fgetl(fid);
    if isempty(linia), continue; end

    % Separem el nom i la resta
    parts = split(linia, ',');
    nom_fitxer = strtrim(parts{1});
    resta = parts{2};

    % Separem la resta amb ;
    detalls = split(resta, ';');
    estat_real = strtrim(detalls{1});
    morts = str2double(detalls{2});
    vius = str2double(detalls{3});

    % Cridem la funció de classificació
    imatge_path = fullfile(carpeta, nom_fitxer);
    [vius_detectats, morts_detectats, estat_pred, img_marcada] = classificacio_cucs(imatge_path);

    % Guardar resultat
    [~, nom_sense_extensio, ~] = fileparts(nom_fitxer);
    imwrite(img_marcada, fullfile(resultats_folder, [nom_sense_extensio, '_resultat.png']));

    % Comparació d'estat general
    if strcmpi(estat_pred, estat_real)
        correctes = correctes + 1;
    end
    total = total + 1;

    % Comparació de detecció de cucs (no es fa per exactitud, sinó per encerts parcials)
    encerts_vius = min(vius_detectats, vius);
    encerts_morts = min(morts_detectats, morts);
    encerts_totals = encerts_totals + encerts_vius + encerts_morts;
    total_cucs = total_cucs + vius + morts;

    % Missatge per imatge
    % Missatge per imatge (millorat)
    fprintf('%s || Pred: %s - Vius: %d - Morts: %d  || Real: %s - Vius: %d - Morts: %d\n', ...
        nom_fitxer, estat_pred, vius_detectats, morts_detectats, estat_real, vius, morts);

end

fclose(fid);

% Resultats finals
fprintf('\nPrecisió global (classificació): %.2f%% (%d de %d correctes)\n', ...
    (correctes/total)*100, correctes, total);

fprintf('Precisió detecció cucs: %.2f%% (%d de %d cucs detectats correctament!)\n', ...
    (encerts_totals/total_cucs)*100, encerts_totals, total_cucs);
