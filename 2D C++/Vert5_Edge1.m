function [ ] = Vert5_Edge1( i,m )
%Vert5_Edge1
%   salva la poligonalizzazione di un triangolo con 5 vertici e 1 lato
%   tagliato

    global node;
    global ele;
    global edge;
    global intersect_triangle;
    %vertice che non è sul lato su cui c'è la traccia
    ext_vert=setdiff(ele(intersect_triangle(i).array(m).num_tri),edge(intersect_triangle(i).array(m).intersect_edge));
    %coordinate del primo estremo del lato su cui c'è la traccia
    x1=node(edge(intersect_triangle(i).array(m).intersect_edge,1),1);
    y1=node(edge(intersect_triangle(i).array(m).intersect_edge,1),2);
    %coordinate estremi traccia
    xt1=node(intersect_triangle(i).array(m).vertex(4),1);
    yt1=node(intersect_triangle(i).array(m).vertex(4),2);
    xt2=node(intersect_triangle(i).array(m).vertex(5),1);
    yt2=node(intersect_triangle(i).array(m).vertex(5),2);
    %calcolo delle distanze degli estremi della traccia dal primo
    %estremo del lato su cui c'è la traccia
    dist1=sqrt((x1-xt1)^2+(y1-yt1)^2);
    dist2=sqrt((x1-xt2)^2+(y1-yt2)^2);

    aux_vert_poly(1,1)=ext_vert;
    aux_vert_poly(2,1)=ext_vert;
    aux_vert_poly(3,1)=ext_vert;
    aux_vert_poly(1,2)=edge(intersect_triangle(i).array(m).intersect_edge,1);
    aux_vert_poly(3,3)=edge(intersect_triangle(i).array(m).intersect_edge,2);
    if dist1<dist2
        aux_vert_poly(1,3)=intersect_triangle(i).array(m).vertex(4);
        aux_vert_poly(2,2)=intersect_triangle(i).array(m).vertex(4);
        aux_vert_poly(2,3)=intersect_triangle(i).array(m).vertex(5);
        aux_vert_poly(3,2)=intersect_triangle(i).array(m).vertex(5);
    else
        aux_vert_poly(1,3)=intersect_triangle(i).array(m).vertex(5);
        aux_vert_poly(2,2)=intersect_triangle(i).array(m).vertex(5);
        aux_vert_poly(2,3)=intersect_triangle(i).array(m).vertex(4);
        aux_vert_poly(3,2)=intersect_triangle(i).array(m).vertex(4);
    end

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

        %--------------TRIANGOLAZIONE--------------------------------------
        intersect_triangle(i).array(m).tri(w0).vert_tri(:)=intersect_triangle(i).array(m).poly(w0).vert_poly(:);
    end 
end


