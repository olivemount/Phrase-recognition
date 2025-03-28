function audios = sample_paths(pth, folders, samples)
% pth debe ser el path de un folder conteniendo solamente folders

    inside_folders = struct2path(dir(pth));
    
    audios = cell(samples, folders);

    %Reviso cada folder
    for i=1:height(inside_folders)
        curr_folder = inside_folders{i};
        folder_content = struct2path(dir(curr_folder));
        [audios{:, i}] = deal(folder_content{:});
    end
end