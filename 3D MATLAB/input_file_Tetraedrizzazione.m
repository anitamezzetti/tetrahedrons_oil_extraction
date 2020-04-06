function [num_node,num_dim,num_ele,num_lati,num_edge,num_points,num_poly,num_edge_poly,num_faces,num_neighbour] = input_file_Tetraedrizzazione
% questa funzione carica i file della tetraedrizzazione e dei poligoni
% leggendo i valori e caricandoli in apposite matrici e strutture globali


global node;
global ele;
global edge;
global neigh;
global points;
global poly;
global face;
global poly_share_face;

%----------------NODE-------------------

%apertura file node e controllo
file=fopen('barra.1.node','r');
if(file<3)
    disp('ERROR: opening file node');
    return
end
%salvataggio node
num_node=fscanf(file,'%d',1); %12 nodi
num_dim=fscanf(file,'%d',1);
scarto=fscanf(file,'%d %d',2);
%allocazione matrice
node=zeros(num_node,num_dim);
for i = 1:1:num_node
     node(i,1:num_dim)=fscanf(file,'%*d %f %f %f',num_dim); %salta il primo: num nodo corrente
end
fclose(file);

%----------------ELE-------------------

%apertura file ele e controllo
file=fopen('barra.1.ele','r');
if(file<3)
    disp('ERROR: opening file ele');
    return
end
%salvataggio ele
num_ele=fscanf(file,'%d',1); %numero tetraedri (12)
num_lati=fscanf(file,'%d',1); %4 => tetraedri
scarto=fscanf(file,'%d',1);
%allocazione matrice
ele=zeros(num_ele,num_lati);
for i = 1:1:num_ele
       ele(i,1:num_lati)=fscanf(file,'%*d %d %d %d %d',num_lati);
end
fclose(file);

%----------------EDGE-------------------

%apertura file edge e controllo
file=fopen('barra.1.edge','r');
if(file<3)
    disp('ERROR: opening file edge');
    return
end
%salvataggio edge
num_edge=fscanf(file,'%d',1); %33
scarto=fscanf(file,'%d',1);
%allocazione matrice
edge=zeros(num_edge,2);
for i = 1:1:num_edge
   edge(i,1:2)=fscanf(file,'%*d %d %d',2);
   scarto=fscanf(file,'%d %d',2);
end
fclose(file);

%----------------NEIGH-------------------

%apertura file neigh e controllo
file=fopen('barra.1.neigh','r');
if(file<3)
    disp('ERROR: opening file neigh');
    return
end
%salvataggio neigh
num_ele2=fscanf(file,'%d',1);
num_neighbour=fscanf(file,'%d',1);
%controllo che il numero di tetraedri sia uguale a quello
%inserito precedentemente
if(num_ele~=num_ele2)
    disp('ERROR: number of triangles in file neigh');
    return
end

%allocazione matrice
neigh=zeros(num_ele2,num_neighbour);
for i = 1:1:num_ele2
     neigh(i,1:num_neighbour)=fscanf(file,'%*d %d %d %d %d',num_neighbour);
end
fclose(file);

%----------------FACE-------------------
%apertura file face e controllo
file=fopen('barra.1.face','r');
if(file<3)
    disp('ERROR: opening file face');
    return
end
%salvataggio edge
num_faces=fscanf(file,'%d',1); %34
scarto=fscanf(file,'%d',1);
%allocazione matrice
face=zeros(num_faces,3);
poly_share_face=zeros(num_faces,2); %contine i due poligoni che condividono quella faccia
for i = 1:1:num_faces
   face(i,1:3)=fscanf(file,'%*d %d %d %d',3);
   scarto=fscanf(file,'%d',1);
   poly_share_face(i,1:2)=fscanf(file,'%d %d',2);
end
fclose(file);


%----------------POLY-------------------

file=fopen('fractbase.pol','r');
if(file<3)
    disp('ERROR: opening file pol');
    return
end
num_points=fscanf(file, '%d', 1);
scarto=fscanf(file, '%d %d %d', 3);
%allocazione matrice
points=zeros(num_points,3);
for i=1:1:num_points
    points(i,1:num_dim)=fscanf(file,'%*f %f %f %f', num_dim);
end
num_poly=fscanf(file, '%d', 1);
scarto=fscanf(file, '%d', 1);
%allocazione matrice
poly=zeros(num_poly,4);
for i=1:1:num_poly
    poly(i,1:4)=fscanf(file,'%*d %d %d %d %d',4);
    num_edge_poly(i,:)=size(poly(i,:),2);
end
fclose(file);

end

