function [RED, GREEN, BLUE, IMAGE ] = GetRAWDATAandIMAGE( impname )
% extract 2D arrays of light intensities collected through red, green, and blue filters of the camera sensor,
% as well as the TrueColor image of the object itself
%   Detailed explanation goes here

warning off MATLAB:imagesci:tiffmexutils:libtiffWarning
testinfo=imfinfo(impname);
timage=Tiff(impname,'r');
offset=getTag(timage,'SubIFD');
setSubDirectory(timage,offset(1));
impimage=double(read(timage));
close(timage);

% ignore outer 'offset' rows and columns of pixels (covered)
xo=testinfo.SubIFDs{1}.ActiveArea(2)+1;
width=testinfo.SubIFDs{1}.DefaultCropSize(1);
yo=testinfo.SubIFDs{1}.ActiveArea(1)+1;
height=testinfo.SubIFDs{1}.DefaultCropSize(2);
impimage=impimage(yo:yo+height-1,xo:xo+width-1);

%Linearization
black = testinfo.SubIFDs{1}.BlackLevel(1);
saturation = testinfo.SubIFDs{1}.WhiteLevel;
impimage=(impimage-black)/(saturation-black);

% 'compress' each bayer 2x2 array to 1 RGB pixel
scaley=size(impimage,1)/2;
scalex=size(impimage,2)/2;

% pixel 1
unitmask=[1,nan;nan,nan];
mask=repmat(unitmask,scaley,scalex);
p1=double(impimage).*mask;
p1=p1(:);
p1(isnan(p1))=[];
p1=reshape(p1,[scaley scalex]);

%pixel 2
unitmask=[nan,1;nan,nan];
mask=repmat(unitmask,scaley,scalex);
p2=double(impimage).*mask;
p2=p2(:);
p2(isnan(p2))=[];
p2=reshape(p2,[scaley scalex]);

%pixel 3
unitmask=[nan,nan;1,nan];
mask=repmat(unitmask,scaley,scalex);
p3=double(impimage).*mask;
p3=p3(:);
p3(isnan(p3))=[];
p3=reshape(p3,[scaley scalex]);

%pixel 4
unitmask=[nan,nan;nan,1];
mask=repmat(unitmask,scaley,scalex);
p4=double(impimage).*mask;
p4=p4(:);
p4(isnan(p4))=[];
p4=reshape(p4,[scaley scalex]);


rawimage=cat(3,p1,(p2+p3)/2,p4); % 'rggb'
%color transformation
carray=testinfo.ColorMatrix2;
xyz2cam=reshape(carray,3,3)';

rgb2xyz=[ 0.4124564, 0.3575761, 0.1804375;
           0.2126729, 0.7151522, 0.0721750;
           0.0193339, 0.1191920, 0.9503041];

rgb2cam=xyz2cam*rgb2xyz;
cam2rgb=rgb2cam^-1;


r = cam2rgb(1,1)*rawimage(:,:,1)+cam2rgb(1,2)*rawimage(:,:,2)+cam2rgb(1,3)*rawimage(:,:,3);
g = cam2rgb(2,1)*rawimage(:,:,1)+cam2rgb(2,2)*rawimage(:,:,2)+cam2rgb(2,3)*rawimage(:,:,3);
b = cam2rgb(3,1)*rawimage(:,:,1)+cam2rgb(3,2)*rawimage(:,:,2)+cam2rgb(3,3)*rawimage(:,:,3);
IMAGE = cat(3,r,g,b);
IMAGE = max(0,min(IMAGE,1));

warning on MATLAB:imagesci:tiffmexutils:libtiffWarning
RED=rawimage(:,:,1);
GREEN=rawimage(:,:,2);
BLUE=rawimage(:,:,3);
end
