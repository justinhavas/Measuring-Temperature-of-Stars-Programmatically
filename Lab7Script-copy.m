%%Lab7 Script
%Import photo
[FileName,PathName] = uigetfile('*.dng','Select the picture file');
P=importdata([PathName FileName]);

%Display this image
figure(1);
image(P);

%% Use raw data script
[RED, GREEN, BLUE, IMAGE] = GetRAWDATAandIMAGE([PathName FileName]);
%% Plot new image to determine rectangle
figure(2);
image(IMAGE);
%% Calculate intensities in red, blue, and green
rectRed = RED(721:723,1455:1459); % 805:1257,968:1454 for sun; 886:945,1374:1439 for metal
rectRed = rectRed(:); %for sirius star 721:723,1455:1459, betelgeuse 1391:1396,1676:1681, alde 230:234,1250:1254
Ired = mean(rectRed); % for albeiro 800:802,1349:1351 other 835:836,1303:1305
rectGreen = GREEN(721:723,1455:1459); %mizar 757:760,1372:1374 other 770:772,1394:1396
rectGreen = rectGreen(:);
Igreen = mean(rectGreen);
rectBlue = BLUE(721:723,1455:1459);
rectBlue = rectBlue(:);
Iblue = mean(rectBlue);

ratGR = Igreen/Ired;
ratBG = Iblue/Igreen;
ratBR = Iblue/Ired;

%% calc density
T = [1000:10:40000]; % 2000 to 10000 changed for sun, use 1000 to 2000 for metal
dRed = SpecDens(Tr_red(:,1),T);
dBlue = SpecDens(Tr_blue(:,1),T);
dGreen = SpecDens(Tr_green(:,1),T);
IredT = sum((1./save11).*(1./save1).*Tr_red(:,2).*dRed); 
IblueT = sum(save22.*save2.*Tr_blue(:,2).*dBlue); 
IgreenT = sum(Tr_green(:,2).*dGreen);

% metal: save1=0.9110,save2=1.1861 sun:save11=0.9970,save22=0.7431

%% expected ratios
expGR = IgreenT./IredT;
expBG = IblueT./IgreenT;
expBR = IblueT./IredT;

figure(3);
plot(expGR,T);
figure(4);
plot(expBG,T);
figure(5);
plot(expBR,T);

TempGR = interp1(expGR,T,ratGR);
TempBG = interp1(expBG,T,ratBG);
TempBR = interp1(expBR,T,ratBR);


%% Calibration 
Calib = interp1(T,expGR,9000); %5778 for sun, 1373 for metal
Scale = ratGR/Calib;
Calib2 = interp1(T,expBG,9000);
Scale2 = ratBG/Calib2;
%save1 = Scale; % save1 and save2 were scalars from metal
%save2 = Scale2; %save11 and save22 were scalars for sun

N_Tr_blue = Scale2.*save22.*save2.*Tr_blue(:,2); 
N_Tr_green = Tr_green(:,2);
N_Tr_red = (1./Scale).*(1./save1).*(1./save11).*Tr_red(:,2); 

N_IredT = sum(N_Tr_red.*dRed);
N_IblueT = sum(N_Tr_blue.*dBlue);
N_IgreenT = sum(N_Tr_green.*dGreen);

N_expGR = N_IgreenT./N_IredT;
N_expBG = N_IblueT./N_IgreenT;
N_expBR = N_IblueT./N_IredT;

figure(6);
plot(N_expGR,T);
figure(7);
plot(N_expBG,T);
figure(8);
plot(N_expBR,T);

N_TempGR = interp1(N_expGR,T,ratGR);
N_TempBG = interp1(N_expBG,T,ratBG);
N_TempBR = interp1(N_expBR,T,ratBR);
