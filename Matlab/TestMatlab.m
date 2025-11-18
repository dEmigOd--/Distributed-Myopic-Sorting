directory = 'c:\users\dmitry.ra\desktop';
Im1 = imread(sprintf('%s\\%s', directory, '1.png'));
Im2 = imread(sprintf('%s\\%s', directory, '2.png'));

Jr2 = imrotate(Im2, -0.5, 'nearest', 'crop');
Jm2 = uint8(zeros(size(Jr2)));
xshift = 0;
yshift = 6;
for clayer = 1:3
    Jm2(1:end-yshift, xshift+1:end, clayer) = Jr2(1+yshift:end, 1:end-xshift, clayer);
end

close all;
figure;
imshow(Im1);
figure;
imshow(Jm2);

imwrite(Jm2, sprintf('%s\\%s', directory, '3.png'));