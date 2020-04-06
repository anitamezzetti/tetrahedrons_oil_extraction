function [ ] = Vert4_noInt_tri( i,m )
%   salva la sottotriangolazione di un triangolo con 4 vertici e 1 lato
%   tagliato, la traccia non finisce dentro il triangolo
global intersect_triangle

for w0=1:1:2
    intersect_triangle(i).array(m).tri(w0).vert_tri(:)=intersect_triangle(i).array(m).poly(w0).vert_poly(:);
end

end

