function [ poly_1 ] = anticlockwise(poly, poly_coord)
%mette i nodi in senso antiorario di un poligono di grandezza qualsiasi.
%input= vertici e coordinate
%output= vertici
global node;

size_coord=size(poly_coord);
size_coord=size_coord(1)-1;
poly_1=[];

%se è in senso orario
if ispolycw((poly_coord(:,1)), (poly_coord(:,2)))==1
    %mette in senso antiorario
    [poly_coord(:,1), poly_coord(:,2)] = poly2ccw(poly_coord(:,1), poly_coord(:,2));

    %salva il numero dei nodi messi in senso antiorario
    for w1=1:1:size_coord
        for w2=1:1:size_coord
            if isequal(poly_coord(w1,:),node(poly(w2),:))==1
                poly_1(w1)=poly(w2);
            end
        end
    end
else
    poly_1=poly;
end

