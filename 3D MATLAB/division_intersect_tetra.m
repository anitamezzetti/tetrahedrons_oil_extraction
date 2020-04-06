function [] = division_intersect_tetra( i,n,num_intersect, num_vertex, M, color )

global node;
global ele;
global points;
global poly;
global toll;
global touch;
global intersect_tetr;

 for k=1:num_intersect
    intersect_tetr(i).array(k).vertex_even_poly=[]; %punti di intersezione con il piano del poligono
    intersect_tetr(i).array(k).section_poly_inner=[]; %vertici del poligono formato dalla parte della frattura interna al tetra

    %scorro tutti i lati di quel tetraedro
    tetra=intersect_tetr(i).array(k).num_tetr;
    edge_tetra=[];

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
                     for h=1:size(intersect_tetr(i).array(k).vertex_even_poly,2)
                         if intersect_tetr(i).array(k).vertex_even_poly(h)==ele(tetra,j)
                             flag=1; %se lo trovo non lo rinserisco
                         end
                     end
                     if flag==0
                        intersect_tetr(i).array(k).vertex_even_poly(end+1)=ele(tetra,j); 
                     end

                     %inserisco il secondo vertice:
                     flag=0;
                     for h=1:size(intersect_tetr(i).array(k).vertex_even_poly,2)
                         if intersect_tetr(i).array(k).vertex_even_poly(h)==ele(tetra,m)
                             flag=1; %se lo trovo non lo rinserisco
                         end
                     end
                     if flag==0
                        intersect_tetr(i).array(k).vertex_even_poly(end+1)=ele(tetra,m); 
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
                     for h=1:size(intersect_tetr(i).array(k).vertex_even_poly,2)
                         if intersect_tetr(i).array(k).vertex_even_poly(h)==line_node
                             flag=1; %se lo trovo non lo rinserisco
                         end
                     end
                     if flag==0
                        intersect_tetr(i).array(k).vertex_even_poly(end+1)=line_node; 
                     end

                 end %end t fra 0 e 1
             end  %end v3 n normali o perpendicolari

             %ora ho in intersect_tetr(i).array(k).vertex_even_poly
             %salvati i punti del tetraedro che intersecano il
             %piano del poligono

        end %ciclo m
    end  %ciclo j
     
     %se sono presenti vertici del poligon all0interno di quel
     %tetra li aggiungo
     if intersect_tetr(i).array(k).intersect_vertex_poly>0 %almeno un vertice                 
         intersect_tetr(i).array(k).section_poly_inner(end+1:end+size(intersect_tetr(i).array(k).intersect_vertex_poly,2))=intersect_tetr(i).array(k).intersect_vertex_poly;
     end


     %il poligono formato dalla parte della frattura interna
     %al tetraedro è formato dai punti in intersect_edge,
     %intersect_face ed eventuali vertici del poligono
     %interni al poligono
     for u=1:size(intersect_tetr(i).array(k).intersect_edge,2)
         if intersect_tetr(i).array(k).intersect_edge(u).coord>0 %c'è qualcosa per quel lato
             size1=size(intersect_tetr(i).array(k).intersect_edge(u).coord,2);
             intersect_tetr(i).array(k).section_poly_inner(end+1:end+size1)=intersect_tetr(i).array(k).intersect_edge(u).coord;
         end
     end
     for u=1:size(intersect_tetr(i).array(k).intersect_face,2)
         size1=size(intersect_tetr(i).array(k).intersect_face(u).coord,2);
         intersect_tetr(i).array(k).section_poly_inner(end+1:end+size1)=intersect_tetr(i).array(k).intersect_face(u).coord;
     end
    intersect_tetr(i).array(k).section_poly_inner=unique(intersect_tetr(i).array(k).section_poly_inner);

    %metto in SENSO ANTIORARIO se sono più di 3:
     if size(intersect_tetr(i).array(k).section_poly_inner,2)>3
         %M matrice di rotazione l'abbiamo giò dalla
         %poligonizzazione :)

         %new_points:coord dei vertici proiettati
         new_points=zeros(size(intersect_tetr(i).array(k).section_poly_inner,2),4);
         for z=1:size(intersect_tetr(i).array(k).section_poly_inner,2)
             bb=node(intersect_tetr(i).array(k).section_poly_inner(z),:)';
             new_points(z,1:3)=[M\bb]';
             new_points(z,4)=intersect_tetr(i).array(k).section_poly_inner(z);
         end %z
        % new_points=new_points(:,1:2); %taglia gli zeri della terza coordinata

         %creo una struttura simile a polig_poly per
         %permettere a ordering_vertex di lavorare:
         inner_poly(1).num_tetr=[];
         inner_poly(1).coord=[];
         [inner_poly,new_points]=ordering_vertex(i,size(intersect_tetr(i).array(k).section_poly_inner,2),1,tetra,new_points,inner_poly);
         intersect_tetr(i).array(k).section_poly_inner=inner_poly(1).coord;
     end
     %ordino anche vertex_even_poly
     if size(intersect_tetr(i).array(k).vertex_even_poly,2)>3
          new_points=zeros(size(intersect_tetr(i).array(k).vertex_even_poly,2),4);
         for z=1:size(intersect_tetr(i).array(k).vertex_even_poly,2)
             bb=node(intersect_tetr(i).array(k).vertex_even_poly(z),:)';
             new_points(z,1:3)=[M\bb]';
             new_points(z,4)=intersect_tetr(i).array(k).vertex_even_poly(z);
         end %z
         %creo una struttura simile a polig_poly per
         %permettere a ordering_vertex di lavorare:
         inner_poly(1).num_tetr=[];
         inner_poly(1).coord=[];
         [inner_poly,new_points]=ordering_vertex(i,size(intersect_tetr(i).array(k).vertex_even_poly,2),1,tetra,new_points,inner_poly);
         intersect_tetr(i).array(k).vertex_even_poly=inner_poly(1).coord;
     end
    
     %disegno
     hold all
     %li ordino per poterli confrontare
%       intersect_tetr(i).array(k).section_poly_inner=sort(intersect_tetr(i).array(k).section_poly_inner);
%       intersect_tetr(i).array(k).vertex_even_poly=sort(intersect_tetr(i).array(k).vertex_even_poly);
         vector1=sort(intersect_tetr(i).array(k).section_poly_inner);
         vector2=sort(intersect_tetr(i).array(k).vertex_even_poly);
     if isequal(vector1,vector2)==0 %se c'è differeenza fra la parte dentro e fuori il poligono
         new_points=zeros(size(intersect_tetr(i).array(k).vertex_even_poly,2),3);
         for z=1:size(intersect_tetr(i).array(k).vertex_even_poly,2)
             bb=node(intersect_tetr(i).array(k).vertex_even_poly(z),:)';
             new_points(z,:)=[M\bb]';
             figure(2);text(new_points(z,1),new_points(z,2), cellstr(num2str(intersect_tetr(i).array(k).vertex_even_poly(z))),  'Fontsize',15 );
         end 
         if size(intersect_tetr(i).array(k).section_poly_inner,2)>2 %almeno tre punti
             X=new_points(:,1);
             Y=new_points(:,2);
             figure(2);fill(X,Y,color(k,:), 'facealpha',.2);   
         end
    end
end %ciclo k scorre num_intersect


end

