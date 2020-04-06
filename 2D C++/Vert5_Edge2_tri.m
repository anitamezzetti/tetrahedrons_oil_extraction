function [] = Vert5_Edge2_tri(  i,m )
%Vert5_Edge2_tri
%   ho un poligono e un triangolo. lascio il triangolo come tale e divido
%   in due il poligono

global intersect_triangle;

intersect_triangle(i).array(m).tri(1).vert_tri=-1;
for j=1:1:2 %2 poligoni
    %if (size(intersect_triangle(i).array(m).poly(j).vert_poly))==[1 3]
    if isequal(size(intersect_triangle(i).array(m).poly(j).vert_poly),[1 3])
        if intersect_triangle(i).array(m).tri(1).vert_tri==-1
            intersect_triangle(i).array(m).tri(1).vert_tri=intersect_triangle(i).array(m).poly(j).vert_poly;
        else
            intersect_triangle(i).array(m).tri(end+1).vert_tri=intersect_triangle(i).array(m).poly(j).vert_poly;
        end
    else
        %ho quattro vertici già in sensoa ntiorario: metto v1 v2 e v4
        %insieme e v2 v3 v4 insieme. resta il senso antiorario
        if intersect_triangle(i).array(m).tri(1).vert_tri==-1
            intersect_triangle(i).array(m).tri(1).vert_tri=...
                [intersect_triangle(i).array(m).poly(j).vert_poly(1), ...
                intersect_triangle(i).array(m).poly(j).vert_poly(2), ...
                intersect_triangle(i).array(m).poly(j).vert_poly(4)];
            intersect_triangle(i).array(m).tri(1).vert_tri=...
                [intersect_triangle(i).array(m).poly(j).vert_poly(2), ...
                intersect_triangle(i).array(m).poly(j).vert_poly(3), ...
                intersect_triangle(i).array(m).poly(j).vert_poly(4)];
        else
            intersect_triangle(i).array(m).tri(end+1).vert_tri=...
                [intersect_triangle(i).array(m).poly(j).vert_poly(1), ...
                intersect_triangle(i).array(m).poly(j).vert_poly(2), ...
                intersect_triangle(i).array(m).poly(j).vert_poly(4)];
            intersect_triangle(i).array(m).tri(end+1).vert_tri=...
                [intersect_triangle(i).array(m).poly(j).vert_poly(2), ...
                intersect_triangle(i).array(m).poly(j).vert_poly(3), ...
                intersect_triangle(i).array(m).poly(j).vert_poly(4)];            
        end
    end
end