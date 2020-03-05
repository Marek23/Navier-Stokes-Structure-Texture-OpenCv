clear; close all;

%% parametry
imageName   = 'SNR2m';
imageformat = '.png';
lambda      = 0.002;
p_r         = 10;
%s_r = ceil(sqrt(size(I,1)*0.02*size(I,2)*0.02))
s_r         = 30;
alfa        = 0.2;

%% pomocnicze nazwy plików (nie trzeba zmienia?)
imgName   = [imageName imageformat];
img_uName = 'test_u.png';
img_vName = 'test_v.png';
maskName  = 'mask.png';
NavStoRes = 'NS_u.png';

I = im2double(imread(imgName));

[nx, ny, nz] = size(I);

maska = double(1-((I(:,:,1) == 0 ) & ...
                (  I(:,:,2) == 1) & ...
                (  I(:,:,3) == 0)));
%%maska zostaje powi?kszona bo algorytm segmentacji zazielenia granic?
erodedMask = maska;
for i=1:3
    erodedMask = imerode(erodedMask,ones(3,3));
end
figure 
imshow(erodedMask)
imwrite(~erodedMask, maskName);

R = I(:,:,1);
T = I(:,:,2);
F = I(:,:,3);

%% dla R T i F robiê rozbicie tesktury i struktury
tic
[RUN1,RV] = StructureTexture(R, lambda);
[TUN1,TV] = StructureTexture(T, lambda);
[FUN1,FV] = StructureTexture(F, lambda);
ts = toc;

% RUN1(maska == 1) = [0;255;0];
% TUN1(maska == 1) = [0;255;0];
% FUN1(maska == 1) = [0;255;0];

U(:,:,1) = RUN1;
U(:,:,2) = TUN1;
U(:,:,3) = FUN1;

V(:,:,1) = RV;
V(:,:,2) = TV;
V(:,:,3) = FV;

imwrite(U, img_uName);
imwrite(V, img_vName);

%% Navier Stokes
tic
cmd = sprintf('python %s %s %s %s', 'inpaint.py', img_uName, maskName, NavStoRes);  
system(cmd)
tns = toc;
U = im2double(imread(NavStoRes));
imwrite(U, NavStoRes);

%% algorytm Criminisi
C    = erodedMask;

RVTVFVm = main(nx,ny,nz,V(:),erodedMask(:),C(:),p_r,s_r,alfa);
RVTVFVr = reshape(RVTVFVm,[nx,ny,nz]);

RV = RVTVFVr(:,:,1);
TV = RVTVFVr(:,:,2);
FV = RVTVFVr(:,:,3);

%% konwersja do obrazu kolorowego
I(:,:,1) = U(:,:,1) + RV;
I(:,:,2) = U(:,:,2) + TV;
I(:,:,3) = U(:,:,3) + FV;

imshow(I);

%% wynik obrazu kolorowego
imwrite(I, ['output_' 'ts_' num2str(ts) 'tns_' num2str(tns) '_' imageName imageformat]);
