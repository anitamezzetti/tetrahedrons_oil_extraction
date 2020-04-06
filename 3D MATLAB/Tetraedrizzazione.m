clear all
clc

global node;
global ele;
global points;
global poly;
global face_control;
global tetra_control;
global edge_control;
global toll;
global touch;
global intersect_tetr;
global tetra_tail;
global total_node;

toll=10^-14;
%toll1=10^-10;
a=[1 2 3 4 1 2];
b=[1,2,3,1];

%----------------------CARICAMENTO FILE---------------------------------
[num_node,num_dim,num_ele,num_vertex,num_edge,num_points,num_poly,num_edge_poly,num_faces,num_neighbour]=input_file_Tetraedrizzazione;

%numero totale di nodi in node che dopo mi servirà 
total_node=num_node;
 
%-----------------------------TOUCH---------------------------------------
touch_3D(num_node,num_ele,num_vertex,num_edge,num_faces);


%-----------------------------DISEGNO------------------------------------
figure(1);clf
figure(2);clf
figure(1);
figure(2);
figure(1);Draw_3D(num_edge_poly)

for i=1:num_poly %scorro I poligoni
     
    %----------------------INIZIALIZZAZIONI-----------------------------
    face_control=[]; %vettore facce controllate
    tetra_control=[]; %vettore tetra controllati
    edge_control=[]; %vettore lati controllati
    tetra_tail=[]; %coda tetraedri da controllare
    intersect_tetr(i).array(1).num_tetr=-1;
    intersect_tetr(i).array(1).intersect_edge.num_edge=[];
    intersect_tetr(i).array(1).intersect_face.num_face=[];
    intersect_tetr(i).array(1).intersect_face.coord=[];
    intersect_tetr(i).array(1).intersect_edge.coord=[];
    num_intersect=0; %num tetraedri intersecati per quel poligono
    
    %------------------------NORMALE PIANO POLIGONO--------------------
    %calcolo le normali al piano, tutte nello stesso punto. Ne calcolo una
    %per tripletta, e prendo tante triplette quanti sono i vertici del
    %poligono meno due così da prendere in considerazione tutti i vertici
    %almeno una volta
    for j=2:(num_edge_poly-1) %faccio partire j direttamente da 2 tanto il primo lo scarto sempre perchè è fisso
        v1=points(poly(i,j),:)-points(poly(i,1),:);
        v2=points(poly(i,j+1),:)-points(poly(i,1),:);
        m(j-1,:)=cross(v1,v2);
    end
    n=sum(m)/norm(sum(m)); %vettore normale al piano nel punto points(poly(i,1)) trovata dall'interpolazione di tutte le normali
    %da n posso ricavare l'equazione cartesiana del piano(vedi foglio)
   
    
    %--------------------------AREA POLIGONO-----------------------------
    for g=2:(num_edge_poly-1)
        area_poly(g-1)=norm(cross(points(poly(i,g),:)-points(poly(i,1),:),points(poly(i,g+1),:)-points(poly(i,1),:)))/2;                     
    end
    area_poly=sum(area_poly);
    
    %-------------------------TROVO LA PRIMA FACCIA---------------------
   special_edge=[]; %vettore che mi tiene conto dei lati del tetra interni al poligono (complanrai)
   %se talei lati non hanno un vertice in comune con vertici del poligono
   %non sono da prendere a priori. tuttavia il poligono potrebbe esntrare
   %nel tetraedro attraverso essi, quindi sono da considerare solo se si
   %trovano atri punti di intersezione!
   
    for j=1:num_faces
        face_control(j)=2;
        [num_intersect,special_edge]=control_face( n, i, j, num_dim ,num_edge_poly, area_poly,num_neighbour,num_intersect, special_edge);
        if num_intersect~=0
            %ho trovato un tetraedro quindi la coda di tetraedri non sarà
            %vuota
            break;
        end 
    end 
      
    
    if  num_intersect==0
        %---------------------POLIGONO INTERNO TETRAEDRO------------------
        %se non ha trovato neanche un tetra intersecato scorrendo tutte le
        %facce significa che il poligono è completamente contenuto dentro un
        %solo tetra(poichè si è stabilito ch enon è esterno all'insimee di
        %tetraedri)
        Poly_all_in_tetra(i,n,num_ele, num_edge_poly , num_ele,num_vertex, num_points);
         
    else %ho almeno un intersecato
        
        %----------------------SCORRO CODA TETRA-----------------------
        %ora la coda dei tetraedri sarà non vuota e la scorro per controllare tutti i
        %tetraedri 
               
        y=1;
        while y<=size(tetra_tail,2) %faccio un ciclo while, tutttavia voglio i controlli alla fine quindi uso un break in fondo
            
            %tetra_tail(y)=numero tetraedro da controllare 
            %controllo che il tetraedro non sia già stato controllato
            [flag_tetra]=already_control(tetra_tail(y),tetra_control);

            if flag_tetra==0 %tetraedro non controllato
                tetra_control(tetra_tail(y))=2; %segno che ho controllato il tetraedro
                
                %trovo per ogni tetraedro le sue facce (4 facce)
                for q=1:num_vertex
                    %faccio l'intersezione fra le facce dei primi due nodi
                    %della faccia, poi interseco il risultato con le facce
                    %del terzo nodo
                    firststep=intersect(touch(ele(tetra_tail(y),a(q))).elenco_face,touch(ele(tetra_tail(y),a(q+1))).elenco_face);
                    face_tetra(q)=intersect(firststep,touch(ele(tetra_tail(y),a(q+2))).elenco_face);
                end

                for q=1:num_vertex %ciclo delle quattro facce di quel tetraedro
                    %controllo che quella faccia non sia stata controllata
                    [flag_face]=already_control(face_tetra(q),face_control);

                    if flag_face==0 %faccia non controllata
                        face_control(face_tetra(q))=2;
                        [num_intersect,special_edge]=control_face(n,i, face_tetra(q) , num_dim ,num_edge_poly, area_poly,num_neighbour,num_intersect, special_edge);
                    end
                end %di q che scorre le facce per quel tetraedro  
            end %end di if tetraedro non controllato
            y=y+1;
            if y>size(tetra_tail,2)
                break
            end
            
        end %scorro coda tetra
        
        %----------CLASSIFICO VERTICI DEL POLIGONO----------------
        %scorro i tetraedri intersecati e controllo se i vertici del
        %poligono sono interni al tetraedro, quelli che sono interni li
        %devo aggiungere a quel tetraedro se non sono mai stati aggiunti
        %prima. inizializzo per tutti i tetraedri intersecati la nuova
        %struttura dove inserirli
        classify_vertex_poly( i,num_intersect, num_edge_poly, num_vertex, num_dim,n,a,b);
        
        %---------AGGIUNGO EVENTUALI PUNTI PER special_edge--------------
        %tolgo i doppioni da special edge
        special_edge=unique(special_edge);
        
        if ~isempty(special_edge)
            analyze_special_edge( i, num_intersect, special_edge, a);
        end

        %disegno i nuovi punti aggiunti:
        for q = num_node+1:total_node
            drawSphere([node(q, :) .1], 'FaceColor', 'b','MarkerSize',0.2);
            text(node(q,1),node(q,2),node(q,3), cellstr(num2str(q)), 'Color', [0.2 0 0.4] , 'Fontsize',20 );
        end
        
        %----------------------------PUNTO 2-----------------------------
%       Per ciascuna frattura individuare l'elenco dei tetraedri che condividono almeno un vertice
%       con un tetraedro tagliato e per questi memorizzare anche quali vertici o lati sono condivisi
%       con un tetraedro tagliato.
        point2_3D(i,num_intersect,num_vertex,num_ele);

         %-------------POLIGONIZZAZIONE del poligono----------------------
        % scorro  tetraedri intersecati. cambio sistema di riferimento. poi con anticlock
        % (eventualmente modificato) li metto in senso antiorario e li
        % rialzo.
        [ polig_poly , M, color] = poligonizzazione_poly( i, num_intersect, n , num_points, num_vertex, num_edge_poly);

        %------------------tetraedri tagliati, divisione-----------------
        %per ogni tetraedro intersecato vedo in che punti è intersecato dal
        %piano del poligono. n è la normale al poligono
        division_intersect_tetra( i,n,num_intersect, num_vertex, M, color );
       
         %-------------------POLIEDRIZZAZIONE-----------------
         %divido i due due poliedri che si sono formati dal passaggio del piano
         %della frattura, quindi bisogna trovare quali sono le nuove facce che la
         %dividono. Una, qulla nuova che si è creata c'è già ed è in comune ad
         %entrmabe i poliedri per trovare le nuove analizzo le vecchie facce e
         %trovo quali sono i nuovi punti che si sono formuti su di esse. queste
         %saranno le nuove facce
         poliedrizzazione( i, n, num_intersect ,num_vertex,a,b, num_dim);
         
    end %if num_intersect==0
end
    