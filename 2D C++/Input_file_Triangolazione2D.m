function [num_node,num_dim,num_ele,num_lati,num_edge,num_points,num_traces]=Input_file_Triangolazione2D
%Input_file_Triangolazione2D
%   questa funzione carica i file della triangolazione e della traccia
%   leggendo i valori e caricandoli in apposite matrici e strutture globali

global node;
global ele;
global edge;
global neigh;
%global touch;
global points;
global traces;

%----------------NODE-------------------

%apertura file node e controllo
file=fopen('quad.1.node','r');
if(file<3)
    disp('ERROR: opening file node');
    return
end
%salvataggio node
num_node=fscanf(file,'%d',1); %13 nodi
num_dim=fscanf(file,'%d',1);
scarto=fscanf(file,'%d %d',2);
%allocazione matrice
node=zeros(num_node,num_dim);
for i = 1:1:num_node
     node(i,1:num_dim)=fscanf(file,'%*d %f %f',num_dim); %salta il primo: num nodo corrente
     scarto=fscanf(file,'%d',1);
end
fclose(file);

%----------------ELE-------------------

%apertura file ele e controllo
file=fopen('quad.1.ele','r');
if(file<3)
    disp('ERROR: opening file ele');
    return
end
%salvataggio ele
num_ele=fscanf(file,'%d',1); %numero trangoli
num_lati=fscanf(file,'%d',1); %3 => triangoli
scarto=fscanf(file,'%d',1);
%allocazione matrice
ele=zeros(num_ele,num_lati);
for i = 1:1:num_ele
       ele(i,1:num_lati)=fscanf(file,'%*d %d %d %d',num_lati);
end
fclose(file);

%----------------EDGE-------------------

%apertura file edge e controllo
file=fopen('quad.1.edge','r');
if(file<3)
    disp('ERROR: opening file edge');
    return
end
%salvataggio edge
num_edge=fscanf(file,'%d',1);
scarto=fscanf(file,'%d',1);
%allocazione matrice
edge=zeros(num_edge,2);
for i = 1:1:num_edge
   edge(i,1:2)=fscanf(file,'%*d %d %d',2);
   scarto=fscanf(file,'%d',1);
end
fclose(file);

%----------------NEIGH-------------------

%apertura file neigh e controllo
file=fopen('quad.1.neigh','r');
if(file<3)
    disp('ERROR: opening file neigh');
    return
end
%salvataggio neigh
num_ele2=fscanf(file,'%d',1);
num_lati2=fscanf(file,'%d',1);
%controllo che il numero di lati e di triangoli sia uguale a quello
%inserito precedentemente
if(num_ele~=num_ele2)
    disp('ERROR: number of triangles in file neigh');
    return
end
if(num_lati~=num_lati2)
    disp('ERROR: number of edges in file neigh');
    return
end
%allocazione matrice
neigh=zeros(num_ele2,num_lati2);
for i = 1:1:num_ele2
     neigh(i,1:num_lati2)=fscanf(file,'%*d %d %d %d',num_lati2);
end
fclose(file);

%----------------TRACE-------------------

file=fopen('trace.trace','r');
if(file<3)
    disp('ERROR: opening file trace');
    return
end
num_points=fscanf(file, '%d', 1);
scarto=fscanf(file, '%d %d %d', 3);
%allocazione matrice
points=zeros(num_points,2);
for i=1:1:num_points
    points(i,1:num_dim)=fscanf(file,'%*f %f %f', num_dim);
end
num_traces=fscanf(file, '%d', 1);
scarto=fscanf(file, '%d', 1);
%allocazione matrice
traces=zeros(num_traces,2);
for i=1:1:num_traces
    traces(i,1:2)=fscanf(file,'%*d %d %d',2);
end
fclose(file);

end

