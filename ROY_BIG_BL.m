function C = ROY_BIG_BL(N)
% ROY-BIG-BL, extracted from Washington-University/workbench.
% https://github.com/Washington-University/workbench/blob/master/src/Files/PaletteFile.cxx

roy_big_bl = [
1	1	0
1	0.784313725490196	0
1	0.470588235294118	0
1	0	0
0.784313725490196	0	0
0.588235294117647	0	0
0.392156862745098	0	0
0.235294117647059	0	0
0	0	0.313725490196078
0	0	0.666666666666667
0.294117647058824	0	0.490196078431373
0.490196078431373	0	0.627450980392157
0.294117647058824	0.490196078431373	0
0	0.784313725490196	0
0	1	0
0	1	1
];

P = size(roy_big_bl,1);

if nargin < 1
   N = P;
end


C = interp1(flip(1:P), roy_big_bl, linspace(1,P,N), 'linear');
