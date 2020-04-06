function [ ] = Vert5_Edge2_poly( i,m )
%Vert5_Edge2_poly
%   salva la poligonalizzazione di un triangolo con 5 vertici e 2 lati
%   tagliati

global node;
global edge;
global toll;
global intersect_triangle;

%ci sono un triangolo e un quadrilatero
%--------------------SALVATAGGIO TRIANGOLO---------------------
%salvataggio numero dei vertici
aux_vert_poly=[];
aux_vert_poly(1)=intersect(edge(intersect_triangle(i).array(m).intersect_edge(1),:),edge(intersect_triangle(i).array(m).intersect_edge(2),:));
aux_vert_poly(2)=intersect_triangle(i).array(m).vertex(4);
aux_vert_poly(3)=intersect_triangle(i).array(m).vertex(5);

%ordinamento dei vertici in senso antiorario
aux_vert_poly_coord=[];
aux_vert_poly_coord(1,:)=node(aux_vert_poly(1),:);
aux_vert_poly_coord(2,:)=node(aux_vert_poly(2),:);
aux_vert_poly_coord(3,:)=node(aux_vert_poly(3),:);
aux_vert_poly_coord(4,:)=node(aux_vert_poly(1),:); %non obbigatorio ripetere il primo

aux_vert_poly=anticlockwise(aux_vert_poly, aux_vert_poly_coord);

intersect_triangle(i).array(m).poly(1).vert_poly(1)=aux_vert_poly(1);
intersect_triangle(i).array(m).poly(1).vert_poly(2)=aux_vert_poly(2);
intersect_triangle(i).array(m).poly(1).vert_poly(3)=aux_vert_poly(3);


%-------------SALVATAGGIO QUADRILATERO-------------------------
ext_vert=aux_vert_poly(1);
aux_vert_poly=[];

%SALVATAGGIO VERTICI IN ORDINE
%ricerca primo vertice del quadrilatero (ovvero quello sul
%primo lato intersecato, ma che non è in comune con l'altro
%lato intersecato
aux_vert_poly(1)=setdiff(edge(intersect_triangle(i).array(m).intersect_edge(1),:),ext_vert);

%ricerca di quale nodo (traccia) sta sul primo lato intersecato
if abs(node(ext_vert,1)-node(aux_vert_poly(1),1))<=toll
    %segmento verticale
    if node(intersect_triangle(i).array(m).vertex(4),1)==node(ext_vert,1) %xp==xi
        aux_vert_poly(2)=intersect_triangle(i).array(m).vertex(4);
        aux_vert_poly(3)=intersect_triangle(i).array(m).vertex(5);
    else
        aux_vert_poly(2)=intersect_triangle(i).array(m).vertex(5);
        aux_vert_poly(3)=intersect_triangle(i).array(m).vertex(4);
    end
else %segmento obliquo
    %utilizzo la retta passante per due punti
    xp=node(intersect_triangle(i).array(m).vertex(4),1);
    yp=node(intersect_triangle(i).array(m).vertex(4),2);
    xi=node(ext_vert,1);
    yi=node(ext_vert,2);
    xf=node(aux_vert_poly(1),1);
    yf=node(aux_vert_poly(1),2);

    %se il primo nodo (nella posiz. 4) sta sul segmento
    if abs(yp-yi-(yf-yi)/(xf-xi)*(xp-xi))<=toll
        aux_vert_poly(2)=intersect_triangle(i).array(m).vertex(4);
        aux_vert_poly(3)=intersect_triangle(i).array(m).vertex(5);
    else
        aux_vert_poly(2)=intersect_triangle(i).array(m).vertex(5);
        aux_vert_poly(3)=intersect_triangle(i).array(m).vertex(4);
    end
end
%inserimento ultimo vertice del quadrilatero
aux_vert_poly(4)=setdiff(edge(intersect_triangle(i).array(m).intersect_edge(2),:),ext_vert);

%ORDINAMENTO DEI VERTICI IN SENSO ORARIO
aux_vert_poly_coord=[];
aux_vert_poly_coord(1,:)=node(aux_vert_poly(1),:);
aux_vert_poly_coord(2,:)=node(aux_vert_poly(2),:);
aux_vert_poly_coord(3,:)=node(aux_vert_poly(3),:);
aux_vert_poly_coord(4,:)=node(aux_vert_poly(4),:);
aux_vert_poly_coord(5,:)=node(aux_vert_poly(1),:);

aux_vert_poly=anticlockwise(aux_vert_poly, aux_vert_poly_coord);

intersect_triangle(i).array(m).poly(2).vert_poly(1)=aux_vert_poly(1);
intersect_triangle(i).array(m).poly(2).vert_poly(2)=aux_vert_poly(2);
intersect_triangle(i).array(m).poly(2).vert_poly(3)=aux_vert_poly(3);
intersect_triangle(i).array(m).poly(2).vert_poly(4)=aux_vert_poly(4);


end

