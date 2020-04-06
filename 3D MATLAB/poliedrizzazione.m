function [] = poliedrizzazione( i, n, num_intersect ,num_vertex,a,b, num_dim)

global node;
global ele;
global points;
global poly;
global face;
global toll;
global touch;
global intersect_tetr;

for w=1:num_intersect
     %copio la prima faccia nei due nuovi poliedri
     intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces=[];
     intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces=[];
     intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(1).coord=intersect_tetr(i).array(w).vertex_even_poly;
     intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(1).coord=intersect_tetr(i).array(w).vertex_even_poly;

     %devo scorrere le facce del tetraedro e capire quali sono i punti sopra il poligono
     %e quelli sotto
     %trovo per ogni tetraedro le sue facce (4 facce)
     for q=1:num_vertex
         %faccio l'intersezione fra le facce dei primi due nodi
         %della faccia, poi interseco il risultato con le facce
         %del terzo nodo
         firststep=intersect(touch(ele(intersect_tetr(i).array(w).num_tetr,a(q))).elenco_face,touch(ele(intersect_tetr(i).array(w).num_tetr,a(q+1))).elenco_face);
         face_tetra(q)=intersect(firststep,touch(ele(intersect_tetr(i).array(w).num_tetr,a(q+2))).elenco_face);
     end

     out=0;
     for f=1:4 %scorre le 4 facce
         %per sapere quali sono i punti che stanno dalla stessa parte ne
         %faccio il prodotto scalare con la normale al piano
         upper_points=[];
         lower_points=[];
         middle_points=[];

         if out==0
             for p=1:3 %scorro i punti della faccia
                 if find(intersect_tetr(i).array(w).vertex_even_poly==face(face_tetra(f),p)) %vertice appartiene l piano del poligono
                     middle_points(end+1)=face(face_tetra(f),p);
                 elseif dot(node(face(face_tetra(f),p),:)-points(poly(i,1)),n)<-toll
                     lower_points(end+1)=face(face_tetra(f),p);
                 else dot(node(face(face_tetra(f),p),:)-points(poly(i,1)),n)>toll
                     upper_points(end+1)=face(face_tetra(f),p);
                 end
             end
                 %Se i tre punti sono tutti dalla stessa parte vuol dire che la
                 %faccia non è stata tagliata in due parti, quindi rimane una
                 %faccia del poligono
                 if isempty(lower_points)&& ~isempty(upper_points) %sono tutti in upper
                     intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(end+1).coord=face(face_tetra(f),:);
                 elseif isempty(upper_points) && ~isempty(lower_points) %sono tutti in  lower
                     intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(end+1).coord=face(face_tetra(f),:);
                 elseif isempty(upper_points) && isempty(lower_points) 
                     %sono vuoti tutti e due, sono tutti in middle, la faccia è completamente contenuta nel poligono, il tetraedro non è da dividire in due
                     %metto un contrassegno in poligonizzazione per dire
                     %che il tetradro è uguale a quello di partenza
                     intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(end+1).coord='same';
                     intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(end+1).coord='same';
                     out=1;
                     break;
                 else %sono un po' da una parte un po' dall'altra
                     %metto sopra quelli sopra e sotto quelli
                     %sotto, in entrambi quelli in mezzo
                     intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(end+1).coord=lower_points;
                     intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(end+1).coord=upper_points;
                     if ~isempty(middle_points) %inserisco in entrambi quelli in mezzo
                         intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(end).coord(end+1:end+size(middle_points,2))=middle_points;
                         intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(end).coord(end+1:end+size(middle_points,2))=middle_points;
                     end
                     %se l'ultima faccia sopra o sotto non ha
                     %dimensione 3 bisogna aggiungere eventuali vertici
                     %in vertex_even poly. controllo quali di questi
                     %vertici sono nella faccia face_tetra(f) e li
                     %aggiungo

                     %cerco quali vertici di vertex_even poly sono
                     %nella faccia con l'area
                     for k=1:size(intersect_tetr(i).array(w).vertex_even_poly,2)
                         X=intersect_tetr(i).array(w).vertex_even_poly(k);
                         if isempty(find(middle_points==X))%se X non è già quello in middle_points
                             area_face=norm(cross([node(face(face_tetra(f),2),:)-node(face(face_tetra(f),1),:)],[node(face(face_tetra(f),3),:)-node(face(face_tetra(f),1),:)]))/2;                     
                             for g=1:num_dim %area col punto
                                AXB(g)=norm(cross([node(face(face_tetra(f),g),:)-node(X,:)],[node(face(face_tetra(f),b(g+1)),:)-node(X,:)]))/2;
                             end
                             if abs(sum(AXB)-area_face)<=toll %punto interno faccia quindi partecipa alla divisione
                                intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(end).coord(end+1)=X;
                                intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(end).coord(end+1)=X;
                             end
                         end
                     end %k 
                 end
         end %chiude out
     end %chiude f 
     %ordino sia le facce di upper che di lower
     v1=points(poly(i,2),:)-points(poly(i,1),:);
     v2=cross(v1,n);
     %nuova base: v1 v2 n
     M=[v1' v2' n'];
     %ordino upper
     for pt=1:size(intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces,2) %scorre le facce di upper_poly
         if size(intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(pt).coord,2)>3
             %new_points:coord dei vertici proiettati
             new_points=zeros(size(intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(pt).coord,2),4);
             for z=1:size(intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(pt).coord,2) %sorre i nodi della faccia pt
                 bb=node(intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(pt).coord(z),:)';
                 new_points(z,1:3)=[M\bb]';
                 new_points(z,4)=intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(pt).coord(z);
             end %z
             %creo una struttura simile a polig_poly per
             %permettere a ordering_vertex di lavorare:
             inner_poly(1).num_tetr=[];
             inner_poly(1).coord=[];
             [inner_poly,new_points]=ordering_vertex(i,size(intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(pt).coord,2),1,intersect_tetr(i).array(w).num_tetr,new_points,inner_poly);
             intersect_tetr(i).array(w).poliedrizzazione.upper_poly_faces(pt).coord=inner_poly(1).coord;
         end
     end %chiudo upper
    %ordino lower
    for pt=1:size(intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces,2) %scorre le facce di lower_poly
         if size(intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(pt).coord,2)>3
             %new_points:coord dei vertici proiettati
             new_points=zeros(size(intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(pt).coord,2),4);
             for z=1:size(intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(pt).coord,2) %sorre i nodi della faccia pt
                 bb=node(intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(pt).coord(z),:)';
                 new_points(z,1:3)=[M\bb]';
                 new_points(z,4)=intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(pt).coord(z);
             end %z
             %creo una struttura simile a polig_poly per
             %permettere a ordering_vertex di lavorare:
             inner_poly(1).num_tetr=[];
             inner_poly(1).coord=[];
             [inner_poly,new_points]=ordering_vertex(i,size(intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(pt).coord,2),1,intersect_tetr(i).array(w).num_tetr,new_points,inner_poly);
             intersect_tetr(i).array(w).poliedrizzazione.lower_poly_faces(pt).coord=inner_poly(1).coord;
         end
     end %chiudo lower
 end %scorro num_intersect
end

