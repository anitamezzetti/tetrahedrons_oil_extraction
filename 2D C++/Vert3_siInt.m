function [ ] = Vert3_siInt( i,m )
%UNTITLED4 Summary of this function goes here
%   Dato un triangolo con la traccia che passa per un vertice e finisce
%   dentro il triangolo, restituisce la poligonalizzazione creata dal
%   prolungamento della fine della traccia al lato opposto

global node;
global ele;
global points;
global traces;
global intersect_triangle;

aux_vert_poly=[];
%nodo per cui passa la traccia
ext_vert=intersect_triangle(i).array(m).node_pass;
%nodi del triangolo per cui non passa la traccia
diff_edge=setdiff(ele(intersect_triangle(i).array(m).num_tri),ext_vert);


%----------POLIGONALIZZAZIONE----------------------------------------------

%salvataggio dei nodi del triangolo 
aux_vert_poly(1,1)=ext_vert;
aux_vert_poly(2,1)=ext_vert;
aux_vert_poly(1,3)=diff_edge(1);
aux_vert_poly(2,3)=diff_edge(2);

%ricerca dell'intersezione del prolungamento della traccia con il lato
%opposto al vertice tagliato dal triangolo
x=[(node(diff_edge(2),:)-node(diff_edge(1),:))',(points(traces(i,1),:)-points(traces(i,2),:))']\[(points(traces(i,1),:)-node(diff_edge(1),:))'];
coord_t=(points(traces(i,1),:))+x(2)*((points(traces(i,2),:)-(points(traces(i,1),:))));
node(end+1,:)=coord_t;
size_node=size(node);
size_node=size_node(2);

aux_vert_poly(1,2)=size_node;
aux_vert_poly(2,2)=size_node;

%ordinamento e salvataggio dei vertici della poligonalizzazione
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


%----------------SOTTOTRIANGOLAZIONE---------------------------------------
aux_vert_tri=[];
%ricerca dell'estremo della traccia interno al triangolo
%se t<0 vuol dire che t=0 è dentro al triangolo
%se t>0 vuol dire che t=1 è dentro al triangolo
if x1(2)<-toll
    node(end+1,:)=points(traces(i,1),:);
else
    node(end+1,:)=points(traces(i,2),:);
end
size_node=size(node);
size_node=size_node(2);


%salvataggio dei nodi del triangolo
aux_vert_tri(1,1)=ext_vert;
aux_vert_tri(3,3)=ext_vert;
aux_vert_tri(1,2)=size_node;
aux_vert_tri(2,2)=size_node;
aux_vert_tri(3,2)=size_node;
aux_vert_tri(1,3)=diff_edge(1);
aux_vert_tri(2,1)=diff_edge(1);
aux_vert_tri(2,3)=diff_edge(2);
aux_vert_tri(3,1)=diff_edge(2);

%ordino i vertici dei triangoli
for w0=1:1:3
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

end

