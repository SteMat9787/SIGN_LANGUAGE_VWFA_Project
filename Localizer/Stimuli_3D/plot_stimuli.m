contents = dir('*.jpeg') % or whatever the filename extension is

for i = 1:numel(contents)
  filename = contents(i).name;
  % Open the file specified in filename, do your processing...
Image = imread(filename);
  figure(1)
  set(gcf,'color','w'); %to have white background
  subplot(8,6,i);
  imshow(Image)
end