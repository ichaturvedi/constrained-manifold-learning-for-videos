med = [1 10 67 189 410];
fileList = getAllFiles('Drive/');
C = zeros(length(med),320*180*3);
parfor i=1:length(med)
  
    dirname = sprintf('Drive/%d',med(i));
    fileList2 = getAllFiles(dirname);
    img = im2double(imread(fileList2{i})); 
    %img = imresize(img,[64 64]);
    img = img(:)';
    C(i,:) = img;   
    
end

X = zeros(length(fileList),320*180*3);
parfor i=1:length(fileList)    
    i  
    img = im2double(imread(fileList{i}));  
    img = img(:)';
    X(i,:) = img;   
   
end

pdistall = pdist2(X,C);
[val, idx] = min(pdistall');


for n = 1:length(med)-1

dirname2 = sprintf('Drive%d',n);
mkdir(dirname2);
rmdir(dirname2,'s');
mkdir(dirname2);

parfor i=1:length(idx)
    i
    if pdistall(i,n)<70 && pdistall(i,n+1)<70
       
        [filepath,name2,ext] = fileparts(fileList{i});
        newStr = strrep(filepath,'Drive',dirname2);
        mkdir(newStr);
        copyfile(fileList{i},newStr);
    end
    
end

dirname = sprintf('%sb',dirname2);
mkdir(dirname);
files = dir(dirname2);
dirFlags = [files.isdir];
subFolders = files(dirFlags);
cnt = 1;
for k = 3 : length(subFolders)
  fileList2 = getAllFiles(fullfile(dirname2,subFolders(k).name));
  if length(fileList2)>10
    dirname = sprintf('%sb/%d',dirname2,cnt);
    mkdir(dirname);
    copyfile( fullfile(dirname2,subFolders(k).name),dirname);
    cnt = cnt + 1;
  end
end

end

