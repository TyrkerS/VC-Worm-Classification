function classificacio_cucs_debug_visual()
    imatge = imread('WormImages/wormA01.tif');
    figure, imshow(imatge), title('1 - Original RGB');

    if size(imatge,3) == 3
        imatge = rgb2gray(imatge);
    end
    figure, imshow(imatge), title('2 - Escala de grisos');

    resized = imresize(imatge, 1.5);
    [h, w] = size(resized);
    w_crop = round(w * 0.2);
    h_crop = round(h * 0.05);
    cropped = resized(h_crop+80:end-h_crop, w_crop:end-w_crop);
    figure, imshow(cropped), title('3 - Retallada i redimensionada');

    contrast = imadjust(cropped, [], [], 1.5);
    filtered = medfilt2(contrast, [5 5]);
    figure, imshow(filtered), title('4 - Contrast millorat i filtrada');

    bin_raw = ~imbinarize(filtered, 'adaptive', 'Sensitivity', 1);
    figure, imshow(bin_raw), title('5 - Binaritzacio inicial');

    bin = bwareaopen(bin_raw, 100);
    figure, imshow(bin), title('6 - Binaritzacio neta (sense soroll)');

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
    figure, imshow(mask_lent), title('7 - Mascara de la lent');

    mask_cucs = bin & ~mask_lent;
    figure, imshow(mask_cucs), title('8 - Sense la lent');

    edges = edge(mask_cucs, 'Canny');
    se = strel('disk', 2);
    edges_open = imdilate(edges, se);
    edges_closed = imclose(edges_open, se);
    filled = imfill(edges_closed, 'holes');
    figure, imshow(filled), title('9 - Zones omplertes');

    pre_cucs = filled - edges_open;
    cucs = bwareaopen(pre_cucs, 200);
    figure, imshow(cucs), title('10 - Cucs probables (pre-filtrat)');

    [cucs_label, num_cucs] = bwlabel(cucs);
    cucs_props = regionprops(cucs_label, 'Area', 'Perimeter');
    for i = 1:num_cucs
        circ = 4*pi*cucs_props(i).Area / (cucs_props(i).Perimeter^2);
        if abs(circ - 1) < 0.3
            cucs(cucs_label == i) = 0;
        end
    end
    figure, imshow(cucs), title('11 - Despres de filtrar formes circulars');

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

    figure, imshow(joined), title('12 - Cucs esprimats per erosio');

    masc_final = bwareaopen(joined | small, 100);
    figure, imshow(masc_final), title('13 - Mascara final cucs');

    [L_final, N_final] = bwlabel(masc_final);
    props = regionprops(L_final, 'BoundingBox', 'MajorAxisLength', 'MinorAxisLength');
    num_vius = 0;
    num_morts = 0;
    img_color = im2uint8(repmat(cropped,1,1,3));
    for i = 1:N_final
        major = props(i).MajorAxisLength;
        minor = props(i).MinorAxisLength;
        if minor == 0, continue; end
        ratio = major / minor;
        bbox = props(i).BoundingBox;
        if ratio < 10
            color = [0 255 0];
            num_vius = num_vius + 1;
        else
            color = [255 0 0];
            num_morts = num_morts + 1;
        end
        img_color = insertShape(img_color, 'Rectangle', bbox, 'Color', color, 'LineWidth', 2);
    end

    figure, imshow(img_color);
    title(sprintf('14 - Classificacio final: Vius = %d, Morts = %d', num_vius, num_morts));
end
