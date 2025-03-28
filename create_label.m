function label_matrix = create_label(names, name, nsamples)
    label_matrix = zeros(nsamples, height(names));
    [~, idx] = ismember(name, names);
    label_matrix(:, idx) = 1;
end