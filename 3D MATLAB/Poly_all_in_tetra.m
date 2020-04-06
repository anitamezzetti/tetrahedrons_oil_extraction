function [] = Poly_all_in_tetra( i,n, num_ele, num_edge_poly , num_tetra,num_vertex, num_points)
%funzione che mi trova qua'è il tetraedro che mi contiene tutto il poligono
%scorro i tetraedri. per ognuno calcolo il volume normalmente. poi lo
%ricalcolo come somma dei tetraedri che hanno come un vertice il primo nodo
%del poligono (posso considerare un nodo qualsiasi del poligono). se il
%poligono è esterno questo secondo volume sarà maggiore del primo.
%altrimenti abbiamo trovato il tetraedro che stavamo cercando.

global node;
global ele;
global points;
global poly;
global intersect_tetr;
global toll;
global touch;

for j=1:num_tetra
    
    %volume tetraedro normale (1/6 prodotto misto)
    v1=node(ele(j,2),:)-node(ele(j,1),:);
    v2=node(ele(j,3),:)-node(ele(j,1),:);
    v3=node(ele(j,4),:)-node(ele(j,1),:);
    vol=(1/6)*abs(dot(cross(v1,v2),v3));
    
    %volume come somma tetraedri 
    a=[1 2 3 4 1 2];
    for m=1:num_vertex
        v1=node(ele(j,a(m)),:)-points(poly(i,1),:);
        v2=node(ele(j,a(m+1)),:)-points(poly(i,1),:);
        v3=node(ele(j,a(m+2)),:)-points(poly(i,1),:);
        vol2(m)=(1/6)*abs(dot(cross(v1,v2),v3));
    end
    vol2=sum(vol2);
    
    if abs(vol-vol2)<=toll %abbiamo trovato il tetraedro j come giusto
        %lo inserisco in intersect_tetra 
        %non inserisco niente in intersect:poly poiche il poligono non
        %viene intersecato
        intersect_tetr(i).array(1).num_tetr=j;
        break;
        %non interseca altro fra facce, vertici o lati
    end
end %for scorre tetra

%il poligono non è da dividere
%sottotetraidrazazzione:
intersect_tetr(i).array(1).vertex_even_poly=[]; %punti di intersezione con il piano del poligono
intersect_tetr(i).array(1).section_poly_inner=[]; %vertici del poligono formato dalla frattura interna al tetra

%aggiungo i vertici del poligono come nodi
for p=1:num_edge_poly
    [ line_node ] = add_node(points(poly(i,p),:));
    intersect_tetr(i).array(1).section_poly_inner(end+1)=line_node;
    %disegno i nuovi punti in figure1
    figure(1);drawSphere([node(line_node, :) .05], 'FaceColor', 'g','MarkerSize',0.2);
    figure(1);text(node(line_node,1),node(line_node,2),node(line_node,3), cellstr(num2str(line_node))  , 'Fontsize',17 );
    
end

edge_tetra=[];
tetra=intersect_tetr(i).array(1).num_tetr;
for j=1:(num_vertex-1) %primo vertice lato
    for m=(j+1):num_vertex %secondo vertice lato

         edge_tetra(end+1)=intersect(touch(ele(tetra,j)).elenco_edge,touch(ele(tetra,m)).elenco_edge);
         v3=[node(ele(tetra,m),:)-node(ele(tetra,j),:)]; %vettore lato

         %controllo se lato tetra parallelo con piano poly
         if abs(dot(n, v3))<toll %normale e lato perpendicolari

             %controllo se complanari: prodotto vett fra lato e
             %primo vertice lato-primo vertice poly nullo:
             if cross(v3,[node(ele(tetra,j),:)-points(poly(i,1),:)])==0
                 %se sono complanari entrambi gli estremi del
                 %lato del tetra sono sul piano del poligono

                 %inserisco il primo vertice:
                 flag=0;
                 for h=1:size(intersect_tetr(i).array(1).vertex_even_poly,2)
                     if intersect_tetr(i).array(1).vertex_even_poly(h)==ele(tetra,j)
                         flag=1; %se lo trovo non lo rinserisco
                     end
                 end
                 if flag==0
                    intersect_tetr(i).array(1).vertex_even_poly(end+1)=ele(tetra,j); 
                 end

                 %inserisco il secondo vertice:
                 flag=0;
                 for h=1:size(intersect_tetr(i).array(1).vertex_even_poly,2)
                     if intersect_tetr(i).array(1).vertex_even_poly(h)==ele(tetra,m)
                         flag=1; %se lo trovo non lo rinserisco
                     end
                 end
                 if flag==0
                    intersect_tetr(i).array(1).vertex_even_poly(end+1)=ele(tetra,m); 
                 end
             end
             %se non sono complanari niente

         else %lato tetra non parallelo piano poly

             %trovo la coord parametrica t rispetto al lato del
             %tetra di intersezione col piano poly:
             A=[n(1),n(2),n(3),0;... %metodo lidia
               1,0,0,-v3(1);...
               0,1,0,-v3(2);...
               0,0,1,-v3(3)];
             bb=[n(1)*points(poly(i,1),1)+n(2)*points(poly(i,1),2)+n(3)*points(poly(i,1),3);...
               node(ele(tetra,j),1);...
               node(ele(tetra,j),2);...
               node(ele(tetra,j),3)];
             X=A\bb;
             t=X(4);

             if t>=-toll && t<=1+toll %il lato interseca il piano del poligono

                 %trovoi punto di intersezione e lo salvo
                 X=node(ele(tetra,j),:)+t*(node(ele(tetra,m),:)-node(ele(tetra,j),:));
                 [line_node]=add_node( X );
                 %cerco se non è già presente
                 flag=0;
                 for h=1:size(intersect_tetr(i).array(1).vertex_even_poly,2)
                     if intersect_tetr(i).array(1).vertex_even_poly(h)==line_node
                         flag=1; %se lo trovo non lo rinserisco
                     end
                 end
                 if flag==0
                    intersect_tetr(i).array(1).vertex_even_poly(end+1)=line_node; 
                 end

             end %end t fra 0 e 1
         end  %end v3 n normali o perpendicolari

         %ora ho in intersect_tetr(i).array(k).vertex_even_poly
         %salvati i punti del tetraedro che intersecano il
         %piano del poligono
    end %ciclo m
end  %ciclo j

if size(intersect_tetr(i).array(1).section_poly_inner,2)>3
v1=points(poly(i,2),:)-points(poly(i,1),:);
v2=cross(v1,n);
%nuova base: v1 v2 n
M=[v1' v2' n']; 

%new_points:coord dei vertici proiettati
new_points=zeros(size(intersect_tetr(i).array(1).section_poly_inner,2),3+1);
for z=1:size(intersect_tetr(i).array(1).section_poly_inner,2)
     bb=node(intersect_tetr(i).array(1).section_poly_inner(z),:)';
     new_points(z,1:3)=[M\bb]';
     new_points(z,4)=intersect_tetr(i).array(1).section_poly_inner(z);
end %z
% new_points=new_points(:,1:2); %taglia gli zeri della terza coordinata

%creo una struttura simile a polig_poly per
%permettere a ordering_vertex di lavorare:
inner_poly.num_tetra=[];
inner_poly.coord=[];
[inner_poly,new_points]=ordering_vertex(i,size(intersect_tetr(i).array(1).section_poly_inner,2),1,tetra,new_points,inner_poly);
intersect_tetr(i).array(1).section_poly_inner=inner_poly(1).coord;
end

%disegno
%new_points:coord dei vertici proiettati
for k=1:num_points
    bb=points(k,:)';
    new_points(k,:)=[M\bb]';
end %k
new_points=new_points(:,1:2); %taglia gli zeri della terza coordinata

%disegno il poligono
figure(2)
for k=1:num_vertex
    x(k)=new_points(poly(i,k),1);
    y(k)=new_points(poly(i,k),2);
end
color=rand(1,3);
axis equal
axis([-3 3 -3 3])
title('divisione frattura')
fill(x,y,color)

%disegno la sottotetraidrazzione
intersect_tetr(i).array(1).section_poly_inner=sort(intersect_tetr(i).array(1).section_poly_inner);
intersect_tetr(i).array(1).vertex_even_poly=sort(intersect_tetr(i).array(1).vertex_even_poly);
if isequal(intersect_tetr(i).array(1).vertex_even_poly,intersect_tetr(i).array(1).section_poly_inner)==0 %se c'è differeenza fra la parte dentro e fuori il poligono
     new_points=zeros(size(intersect_tetr(i).array(1).vertex_even_poly,2),3);
     for z=1:size(intersect_tetr(i).array(1).vertex_even_poly,2)
         bb=node(intersect_tetr(i).array(1).vertex_even_poly(z),:)';
         new_points(z,:)=[M\bb]';
         figure(2);text(new_points(z,1),new_points(z,2), cellstr(num2str(intersect_tetr(i).array(1).vertex_even_poly(z))),  'Fontsize',15 );
     end 
     X=new_points(:,1);
     Y=new_points(:,2);
     hold all
     figure(2);fill(X,Y,color, 'facealpha',.2);          
end

end

