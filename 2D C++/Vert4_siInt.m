function [ ] = Vert4_siInt( i,m )
%UNTITLED4 Summary of this function goes here
%   Dato un triangolo con la traccia che passa per un lato e finisce
%   dentro il triangolo, restituisce
global node;
global ele;
global edge;
global points;
global traces;
global toll;
global intersect_triangle;

%vertice che non è sul lato su cui c'è la traccia
ext_vert=setdiff(ele(intersect_triangle(i).array(m).num_tri,:),edge(intersect_triangle(i).array(m).intersect_edge,:));

diff_edge=edge(intersect_triangle(i).array(m).intersect_edge,:);


%trova s e t dell'intersezione tra il prolungamento della traccia e
%ciascuno degli altri lati non già intersecati
x1=[(node(diff_edge(1),:)-node(ext_vert,:))',(points(traces(i,1),:)-points(traces(i,2),:))']\[(points(traces(i,1),:)-node(ext_vert,:))'];
x2=[(node(diff_edge(2),:)-node(ext_vert,:))',(points(traces(i,1),:)-points(traces(i,2),:))']\[(points(traces(i,1),:)-node(ext_vert,:))'];


%controlla se l'intersezione del prolungamento della traccia è in un
%vertice (ovvero quello opposto al lato inizialmente intersecato
if abs(x1(1))<=toll && abs(x2(1))<=toll
    
    %la poligonalizzazione è identica a quella di un triangolo con 4
    %vertici e traccia passante per un nodo (CASO 3)
    Vert4_noInt_poly(i,m);
    
else %se l'intersezione del prolungamento della traccia è in un lato
    
    if x1(1)>toll && x1(1)<1-toll %se interseca il primo lato
        %ci sono un triangolo e un quadrilatero
        %--------------------SALVATAGGIO TRIANGOLO---------------------
        %salvataggio numero dei vertici
        aux_vert_poly=[];
        %intersezione tra traccia e lato intersecato
        aux_vert_poly(1)=intersect_triangle(i).array(m).vertex(4);
        %vertice in comune tra il lato intersecato dalla traccia e quello
        %dal prolungamento
        aux_vert_poly(2)=diff_edge(1);
        %intersezione tra lato e prolungamento della traccia
        %trova la coordinata dell'intersezione con il primo lato
        coord_t=(points(traces(i,1),:))+x1(2)*((points(traces(i,2),:)-(points(traces(i,1),:))));
        node(end+1,:)=coord_t;
        size_node=size(node);
        size_node=size_node(2);
        aux_vert_poly(3)=size_node;

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
        aux_vert_poly=[];

        %SALVATAGGIO VERTICI IN ORDINE
        %ricerca primo vertice del quadrilatero (ovvero quello sul
        %primo lato intersecato, ma che non è in comune con l'altro
        %lato intersecato
        aux_vert_poly(1)=diff_edge(2);
        %nodo (della traccia) sta sul primo lato intersecato
        aux_vert_poly(2)=intersect_triangle(i).array(m).vertex(4);
        %nodo dell'intersezione tra il prolungamento e un lato
        aux_vert_poly(3)=size_node;
        %ultimo nodo: opposto al lato intersecato dalla traccia
        aux_vert_poly(4)=ext_vert;
        
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
        
    else %se interseca il secondo lato
        %ci sono un triangolo e un quadrilatero
        %--------------------SALVATAGGIO TRIANGOLO---------------------
        %salvataggio numero dei vertici
        aux_vert_poly=[];
        %intersezione tra traccia e lato intersecato
        aux_vert_poly(1)=intersect_triangle(i).array(m).vertex(4);
        %vertice in comune tra il lato intersecato dalla traccia e quello
        %dal prolungamento
        aux_vert_poly(2)=diff_edge(2);
        %intersezione tra lato e prolungamento della traccia
        %trova la coordinata dell'intersezione con il primo lato
        coord_t=(points(traces(i,1),:))+x2(2)*((points(traces(i,2),:)-(points(traces(i,1),:))));
        node(end+1,:)=coord_t;
        size_node=size(node);
        size_node=size_node(2);
        aux_vert_poly(3)=size_node;

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
        aux_vert_poly=[];

        %SALVATAGGIO VERTICI IN ORDINE
        %ricerca primo vertice del quadrilatero (ovvero quello sul
        %primo lato intersecato, ma che non è in comune con l'altro
        %lato intersecato
        aux_vert_poly(1)=diff_edge(1);
        %nodo (della traccia) sta sul primo lato intersecato
        aux_vert_poly(2)=intersect_triangle(i).array(m).vertex(4);
        %nodo dell'intersezione tra il prolungamento e un lato
        aux_vert_poly(3)=size_node;
        %ultimo nodo: opposto al lato intersecato dalla traccia
        aux_vert_poly(4)=ext_vert;
        
        %ORDINAMENTO DEI VERTICI IN SENSO ANTIORARIO
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
end

%-----SOTTOTRIANGOLAZIONE----------------------------------------------
%se t<0 vuol dire che t=0 è dentro al triangolo
%se t>0 vuol dire che t=1 è dentro al triangolo
if x1(2)<-toll
    node(end+1,:)=points(traces(i,1),:);
else
    node(end+1,:)=points(traces(i,2),:);
end
size_node=size(node);
size_node=size_node(2);

aux_vert_tri(1,1)=intersect_triangle(i).array(m).vertex(4);
aux_vert_tri(1,2)=size_node;
aux_vert_tri(1,3)=diff_edge(1);
aux_vert_tri(2,1)=diff_edge(1);
aux_vert_tri(2,2)=size_node;
aux_vert_tri(2,3)=ext_vert;
aux_vert_tri(3,1)=ext_vert;
aux_vert_tri(3,2)=size_node;
aux_vert_tri(3,3)=diff_edge(2);
aux_vert_tri(4,1)=diff_edge(2);
aux_vert_tri(4,2)=size_node;
aux_vert_tri(4,3)=intersect_triangle(i).array(m).vertex(4);

for w0=1:1:4
    %ordinamento dei vertici in senso antiorario
    aux_vert_tri_coord=[];
    aux_vert_tri_coord(1,:)=node(aux_vert_tri(w0,1),:);
    aux_vert_tri_coord(2,:)=node(aux_vert_tri(w0,2),:);
    aux_vert_tri_coord(3,:)=node(aux_vert_tri(w0,3),:);
    aux_vert_tri_coord(4,:)=node(aux_vert_tri(w0,1),:);

    aux_vert_tri_res=anticlockwise(aux_vert_tri(w0,:), aux_vert_tri_coord);

    intersect_triangle(i).array(m).tri(w0).vert_tri(1)=aux_vert_tri_res(1);
    intersect_triangle(i).array(m).tri(w0).vert_tri(2)=aux_vert_tri_res(2);
    intersect_triangle(i).array(m).tri(w0).vert_tri(3)=aux_vert_tri_res(3);
end