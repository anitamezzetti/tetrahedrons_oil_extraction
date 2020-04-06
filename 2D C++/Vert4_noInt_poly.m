function [ ] = Vert4_noInt_poly( i,m )
%Vert4_noInt
%   salva la poligonalizzazione di un triangolo con 4 vertici e 1 lato
%   tagliato, la traccia non finisce dentro il triangolo

global node;
global ele;
global edge;
global intersect_triangle;

%vertice che non è sul lato su cui c'è la traccia
ext_vert=setdiff(ele(intersect_triangle(i).array(m).num_tri,:),edge(intersect_triangle(i).array(m).intersect_edge,:));
aux_vert_poly=[];
aux_vert_poly(1,1)=ext_vert;
aux_vert_poly(2,1)=ext_vert;
aux_vert_poly(1,2)=edge(intersect_triangle(i).array(m).intersect_edge,1);
aux_vert_poly(2,3)=edge(intersect_triangle(i).array(m).intersect_edge,2);
aux_vert_poly(1,3)=intersect_triangle(i).array(m).vertex(4);
aux_vert_poly(2,2)=intersect_triangle(i).array(m).vertex(4);

for w0=1:1:2
    %ordinamento dei vertici in senso antiorario
    aux_vert_poly_coord=[];
    aux_vert_poly_coord(1,:)=node(aux_vert_poly(w0,1),:);
    aux_vert_poly_coord(2,:)=node(aux_vert_poly(w0,2),:);
    aux_vert_poly_coord(3,:)=node(aux_vert_poly(w0,3),:);
    aux_vert_poly_coord(4,:)=node(aux_vert_poly(w0,1),:);

    aux_vert_poly_res=anticlockwise(aux_vert_poly(w0,:), aux_vert_poly_coord);
    
    intersect_triangle(i).array(m).poly(w0).vert_poly(1)=aux_vert_poly_res(1);
    intersect_triangle(i).array(m).poly(w0).vert_poly(2)=aux_vert_poly_res(2);
    intersect_triangle(i).array(m).poly(w0).vert_poly(3)=aux_vert_poly_res(3);
end

end

