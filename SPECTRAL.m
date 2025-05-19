function C = SPECTRAL(N)
% SPECTRAL, extracted from Washington-University/workbench.
% https://github.com/Washington-University/workbench/blob/master/src/Files/PaletteFile.cxx

spectral = [
158 1   66
213 62  79
244 109 67
253 174 97
254 224 139
255 255 191
230 245 152
171 221 164
102 194 165
50  136 189
94  79  162
]./255;

P = size(spectral,1);

if nargin < 1
   N = P;
end


C = interp1(flip(1:P), spectral, linspace(1,P,N), 'linear');
