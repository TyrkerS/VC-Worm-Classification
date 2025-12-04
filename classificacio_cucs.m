function [num_vius, num_morts, estat_imatge, img_marcada] = classificacio_cucs(nom_imatge)
    % Llegeix i processa la imatge per detectar i classificar cucs vius i morts

    % Carregar i convertir a escala de grisos si cal
    imatge = imread(nom_imatge);
    if size(imatge,3) == 3
        imatge = rgb2gray(imatge);
    end

    % Redimensionar i retallar marges de la imatge
    resized = imresize(imatge, 1.5);
    [h, w] = size(resized);
    w_crop = round(w * 0.2);
    h_crop = round(h * 0.05);
    cropped = resized(h_crop+80:end-h_crop, w_crop:end-w_crop);

    % Millora del contrast, filtrat i binarització
    contrast = imadjust(cropped, [], [], 1.5);
    filtered = medfilt2(contrast, [5 5]);
    bin = ~imbinarize(filtered, 'adaptive', 'Sensitivity', 1);
    bin = bwareaopen(bin, 100);  % Elimina petits sorolls

    % Detecció de la lent (component gran tocant la vora amb certa circularitat)
    [L, num] = bwlabel(bin);
    props = regionprops(L, 'Area', 'Perimeter');
    mask_lent = false(size(bin));
    for i = 1:num
        regio = (L == i);
        perim = props(i).Perimeter;
        area = props(i).Area;
        if perim == 0, continue; end
        circ = 4 * pi * area / perim^2;
        toca_vora = any(regio(1,:)) || any(regio(end,:)) || ...
                    any(regio(:,1)) || any(regio(:,end));
        if area > 1000 && toca_vora && circ > 0.5
            mask_lent = mask_lent | regio;
        end
    end
    mask_cucs = bin & ~mask_lent;  % Esborrem la lent de la binarització

    % Detecció de contorns i omplert per obtenir formes tancades
    edges = edge(mask_cucs, 'Canny');
    se = strel('disk', 2);
    edges_open = imdilate(edges, se);
    edges_closed = imclose(edges_open, se);
    filled = imfill(edges_closed, 'holes');
    pre_cucs = filled - edges_open;
    cucs = bwareaopen(pre_cucs, 200);  % Eliminar objectes massa petits

    % Eliminar formes circulars falses (possibles artefactes)
    [cucs_label, num_cucs] = bwlabel(cucs);
    cucs_props = regionprops(cucs_label, 'Area', 'Perimeter');
    for i = 1:num_cucs
        circ = 4*pi*cucs_props(i).Area / (cucs_props(i).Perimeter^2);
        if abs(circ - 1) < 0.3
            cucs(cucs_label == i) = 0;
        end
    end

    % Separar cucs units i afegir els petits
    [labels_cucs, num_labels] = bwlabel(cucs);
    props_labels = regionprops(labels_cucs, 'Area');
    joined = false(size(cucs));
    small = false(size(cucs));
    for i = 1:num_labels
        cuc = labels_cucs == i;
        area = props_labels(i).Area;
        if area > 1700
            cuc = imerode(cuc, strel('disk', 3));
            joined = joined | cuc;
        elseif area > 1200
            cuc = imerode(cuc, strel('square', 2));
            joined = joined | cuc;
        elseif area < 1200
            small = small | cuc;
        end
    end
    masc_final = bwareaopen(joined | small, 100);

    % Classificació dels cucs segons forma (relació eixos major/menor)
    [L_final, N_final] = bwlabel(masc_final);
    props = regionprops(L_final, 'BoundingBox', 'MajorAxisLength', 'MinorAxisLength');
    num_vius = 0;
    num_morts = 0;
    img_marcada = im2uint8(repmat(cropped,1,1,3));  % Convertim a imatge RGB 

    for i = 1:N_final
        major = props(i).MajorAxisLength;
        minor = props(i).MinorAxisLength;
        if minor == 0, continue; end
        ratio = major / minor;
        bbox = props(i).BoundingBox;
        if ratio < 10
            color = [0 255 0];  % Verd = viu 
            num_vius = num_vius + 1;
        else
            color = [255 0 0];  % Vermell = mort 
            num_morts = num_morts + 1;
        end
        img_marcada = insertShape(img_marcada, 'Rectangle', bbox, 'Color', color, 'LineWidth', 2);
    end

    % Determinar l'estat de la imatge segons la majoria
    if num_vius > num_morts
        estat_imatge = 'alive';
    else
        estat_imatge = 'dead';
    end
end
