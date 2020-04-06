function [num_intersect,special_edge] = control_face( n, i, j, num_dim ,num_edge_poly, area_poly,num_neighbour,num_intersect, special_edge)
%COME OUTPUT IO METTEREI [num_intersect,p] !!   [bool,p]

% n=normale poligono
% i=numero poligono
% j=numero faccia
%mi deve ridare bool che mi dice se la faccia è tagliata o meno
global node;
global edge;
global points;
global poly;
global face;
global toll;
global touch;
global intersect_tetr;
global total_node;
global edge_control;
global poly_share_face;

control_poly=zeros(num_edge_poly,1);

%calcoliamo la normale (f) alla faccia:
v1=node(face(j,2),:)-node(face(j,1),:);
v2=node(face(j,3),:)-node(face(j,1),:);
f=cross(v1,v2);
a=[1 2 3 1]; %per semplificare dopo quando mi serve p+1 e non dividere sempre i casi
b=[1 2 3 4 1];

%edge_face sono i lati della faccia considerata
edge_face(1)=intersect(touch(face(j,1)).elenco_edge,touch(face(j,2)).elenco_edge);
edge_face(2)=intersect(touch(face(j,2)).elenco_edge,touch(face(j,3)).elenco_edge);
edge_face(3)=intersect(touch(face(j,3)).elenco_edge,touch(face(j,1)).elenco_edge);

if cross(n,f)==0 %piani paralleli
    %vediamo se sono complanari
    if abs(dot((node(face(j,1),:)-points(poly(i,1),:)),n))<=toll %(p-P0)*n=0 sono complanari   
            flag(1) = inner_point( i, num_edge_poly,area_poly, node(face(j,1),:),n);
            flag(2) = inner_point( i, num_edge_poly,area_poly, node(face(j,2),:),n);
            flag(3) = inner_point( i, num_edge_poly,area_poly, node(face(j,3),:),n);
            %flag è 1 se è interno o sul bordo 0 se è esterno
            flag_in=0; 
            if isequal(flag,[1,1,1]) %sono tutti interni o sul bordo no intersecato
                 %eh niente 
                 flag_in=1; %è da settare ugualmente perchè se i punti della faccia sono tutti interni il poligono non può essere dentro la faccia a sua volta
            else %sono tutti e tre fuori o alcuni fuori e alcuni dentro, dobbiamo scorrore i lati della faccia e poi quelli del poligono 
                for l=1:3 %scorro lati faccia
                    %controllo se lato già controllato
                    [flag_edge]=already_control(edge_face(l) , edge_control);

                    if flag_edge==0 %quel lato non era già stato controllato
                        edge_control(edge_face(l))=2;
                        
                        for k=1:num_edge_poly %scorro i lati del poligono
                            
                           if norm(cross((node(edge(edge_face(l),2),:)-node(edge(edge_face(l),1),:)),(points(poly(i,b(k+1)),:)-points(poly(i,b(k)),:))))<=toll %lato poligono e lato faccia paralleli
                               v1=[points(poly(i,k),:)-node(edge(edge_face(l),1),:)];%vettore direzione del primo punto del lato del poligono e primo punto lato considerato
                               v3=[points(poly(i,b(k+1)),:)-points(poly(i,b(k)),:)]; %vettore direzione del lato del poligono considerato
                               if norm(cross(v1,v3))<=toll %rette lato e retta lato poligono concidenti
                                     %bisogna vedere se lato poligono interseca lato edge_face(j)
                                     ki=(points(poly(i,b(k+1)),:)-points(poly(i,k),:))'\(node(edge(edge_face(l),1),:)-points(poly(i,k),:))'; 
                                     kf=(points(poly(i,b(k+1)),:)-points(poly(i,k),:))'\(node(edge(edge_face(l),2),:)-points(poly(i,k),:))';
                                     [ki,kf]=sort(ki,kf); %coordinate parametriche del lato del poligono rispetto al lato della faccia
                                     if kf>=1-toll && ki<=1-toll
                                         flag_in=1;
                                         edge_control(edge_face(l))=1; %dice che quel lato è stato intersecato oltre che controllato
                                         %inserire le caratteristiche del
                                         %taglio nella struttura       
                                         %cerco i tetraedri che condividono il lato edge_face(l)
                                         tetra_share=intersect(touch(edge(edge_face(l),1)).elenco_tetra,touch(edge(edge_face(l),2).elenco_tetra));
                                        
                                            for m=1:size(tetra_share,2)
                                                [line_insert(m),num_intersect]=insert_only_tetra(i,tetra_share(m),num_intersect,num_neighbour); %mi dice dove ha inserito il tetredro o dove si trovava
                                                
                                                %scorro i lati del poly per una stessa faccia. quindi, uno
                                                %stesso lato della faccia potrebbe essere intersecato da più
                                                %lati del poly. quindi controllo per evitare ripetizioni:
                                                edge_already_intersect=0;% verifica che quel lato sià già presente
                                                v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                                %controllo se è il primo lato inserito per quel tetra. non faccio tutto
                                                %dentro al while perchè per io primo nodo mi darebbe errore di lunghezza di
                                                %matrice perchè aumenti v oltre a sua dimensione
                                                if intersect_tetr(i).array(line_insert(m)).intersect_edge(1).num_edge>0 %non è il primo lato
                                                    while (intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                        if intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge==edge_face(l)
                                                            %lato già presente alla posizione v qundi esco dal while   
                                                            edge_already_intersect=1;
                                                            break;
                                                        end
                                                        v=v+1;
                                                    end %while
                                                    if edge_already_intersect==0 %devo aggiungere quel lato
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(l);  
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                        
                                                    end 
                                                else %è il primo lato, v resta 1
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(l);  
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; 
                                                end
                                            end
                                            if ki<=toll %lato del poligono completamente interno al lato della faccia
                                                %inserire in quale coordinata cartesiana viene intersecato quindi
                                                %aggiorno node con i nuovi punti di
                                                %intersezione (in questo caso sono due e sono gli estremi del lato del poligono)
                                                %li devo comunque aggiungere in node perchè così hanno un unica
                                                %numerazione prima controllo che non ci siano già in node
                                                control_poly(k)=1;
                                                control_poly(b(k+1))=1;
                                                if k==1
                                                    control_poly(num_edge_poly)=1;
                                                else
                                                    control_poly(k-1)=1;
                                                end
                                                 line_node1=add_node(edge(edge_face(l),1)); %inserisce o ritorna il numero del nodo da inserire nella struttura di enreambi gli estremi del lato del poligono interno al lato della faccia
                                                 line_node2=add_node(edge(edge_face(l),2));
                                                 for m=1:size(tetra_share,2) %inserisce le stesse coordinate in tutti i tetraedri che hanno quel lato
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=line_node1;
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=line_node2;
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord);
                                                 end
                                            else %solo ki è interno al lato del poligono mentre kf è fuori
                                                %bisogna inseire nella struttura delle intersezioni
                                                %del poligono la coordinata parametrica ki perchè
                                                %è interna 
                                                control_poly(k)=1;
                                                control_poly(b(k+1))=1;
                                                %bisogna aggionare node inserendo
                                                %la coordinata del lato del
                                                %poligono che è interno al lato
                                                %della faccia e metterlo nella
                                                %struttura generale
                                                line_node=add_node([points(poly(i,b(k+1)),1),points(poly(i,b(k+1)),2),points(poly(i,b(k+1)),3)]);  %p=coord cartes dell'estremo del lato del poligono che è interno al lato della faccia
                                                for m=1:size(tetra_share,2) %inserisce le stesse coordinate in tutti i tetraedri che hanno quel lato
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=line_node;
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=line_node;
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord);
                                                end
                                            end
                                     elseif (ki<toll && kf>toll) %ultimo caso sappiamo già che kf è interno al lato non sul bordo perchè altrimenti entrava prima
                                         flag_in=1;
                                         edge_control(edge_face(l))=1; %dice che quel lato è stato intersecato oltre che controllato
                                         %inserire le caratteristiche del taglio
                                         %cerco i tetraedri che condividono il lato edge_face(l)
                                         tetra_share=intersect(touch(edge(edge_face(l),1).elenco_tetra),touch(edge(edge_face(l),2).elenco_tetra));
                                         
                                         for m=1:size(tetra_share,2)
                                            [line_insert(m),num_intersect]=insert_only_tetra(i,tetra_share(m),num_intersect,num_neighbour); %mi dice dove ha inserito il tetredro o dove si trovava

                                            %scorro i lati del poly per una stessa faccia. quindi, uno
                                            %stesso lato della faccia potrebbe essere intersecato da più
                                            %lati del poly. quindi controllo per evitare ripetizioni:
                                            edge_already_intersect=0;% verifica che quel lato sià già presente
                                            v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                            
                                            if intersect_tetr(i).array(line_insert(m)).intersect_edge(1).num_edge>0 %non è il primo lato
                                                while (intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                    if intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge==edge_face(l)
                                                        %lato già presente alla posizione v qundi esco dal while   
                                                        edge_already_intersect=1;
                                                        break;
                                                    end
                                                    v=v+1;
                                                end %while
                                                if edge_already_intersect==0 %devo aggiungere quel lato
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(l);  
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while

                                                end 
                                            else %è il primo lato, v resta 1
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(l);  
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; 
                                            end

                                         end
                                         
                                        control_poly(k)=1;
                                        if k==1
                                            control_poly(num_edge_poly)=1;
                                        else
                                            control_poly(k-1)=1;
                                        end
                                        
                                        %bisogna aggionare node inserendo
                                        %la coordinata del lato del
                                        %poligono che è interno al lato
                                        %della faccia e metterlo nella
                                        %struttura generale
                                        line_node = add_node([points(poly(i,b(k)),1),points(poly(i,b(k)),2),points(poly(i,b(k)),3)]); %p= coordinate del primo estemo del lato della faccia considerato
                                        for m=1:size(tetra_share,2) %inserisce le stesse coordinate in tutti i tetraedri che hanno quel lato
                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=line_node;

                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord);
                                        end
                                     end %chiude controlli paralleli
                               end %chiude norm piccolo
                               
                           else %lato poligono e lato faccia non sono paralleli (del norm grande)
                               %dobbiamo trovare coordin ata parametrica
                               %dell'intersezione
                               x=[(node(edge(edge_face(l),2),:)-node(edge(edge_face(l),1),:))',-(points(poly(i,b(k+1)),:)-points(poly(i,b(k)),:))']\[(points(poly(i,b(k)),:)-node(edge(edge_face(l),1),:))'];
                               %x(1)=s lato tetra x(2)=t lato poly
                               
                               if abs(x(1))<=toll && (abs(x(2))<=toll || abs(x(2)-1)<=toll) %intersezione nel punto di inizio del lato e in un estremo del lato del poligono 
                                   flag_in=1;
                                   edge_control(edge_face(l))=1; %dice che quel lato è stato intersecato oltre che controllato
                                   %ricerco i tetraedri con questo
                                   %lato
                                   tetra_share=intersect(touch(edge(edge_face(l),1).elenco_tetra),touch(edge(edge_face(l),2).elenco_tetra));          
                                   for m=1:size(tetra_share,2)
                                        [line_insert(m),num_intersect] = insert_only_tetra(i,tetra_share(m),num_intersect,num_neighbour); %inserisce tetraedro nella struttura
                                       
                                        %scorro i lati del poly per una stessa faccia. quindi, uno
                                        %stesso lato della faccia potrebbe essere intersecato da più
                                        %lati del poly. quindi controllo per evitare ripetizioni:
                                        edge_already_intersect=0;% verifica che quel lato sià già presente
                                        v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                        if intersect_tetr(i).array(line_insert(m)).intersect_edge(1).num_edge>0 %non è il primo lato
                                            while (intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                if intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge==edge_face(l)
                                                    %lato già presente alla posizione v qundi esco dal while   
                                                    edge_already_intersect=1;
                                                    break;
                                                end
                                                v=v+1;
                                            end %while
                                            if edge_already_intersect==0 %devo aggiungere quel lato
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(l);  
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while

                                            end 
                                        else %è il primo lato, v resta 1
                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(l);  
                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; 
                                        end
                                        
                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=edge(edge_face(l),1); %e sua coord
                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord);
                                   end
                                   
                                   if abs(x(2))<=toll
                                        control_poly(k)=1; %aggiorna l'intersezione del poligono 
                                        if k==1
                                            control_poly(num_edge_poly)=1;
                                        else
                                            control_poly(k-1)=1;
                                        end
                                   else
                                     control_poly(k)=1;
                                     control_poly(b(k+1))=1;
                                   end
                               elseif (abs(x(1)-1)<=toll && (abs(x(2))<=toll || abs(x(2)-1)<=toll))%si intersecano entrambi ad un estremo
                                   flag_in=1;
                                   edge_control(edge_face(l))=1; %dice che quel lato è stato intersecato oltre che controllato
                                   %ricerco i tetraedri con questo
                                   %lato
                                   tetra_share=intersect(touch(edge(edge_face(l),1).elenco_tetra),touch(edge(edge_face(l),2).elenco_tetra));         
                                   for m=1:size(tetra_share,2)
                                        [line_insert(m),num_intersect] = insert_only_tetra(i,tetra_share(m),num_intersect,num_neighbour); %inserisce tetraedro nella struttura
                                        
                                        %scorro i lati del poly per una stessa faccia. quindi, uno
                                        %stesso lato della faccia potrebbe essere intersecato da più
                                        %lati del poly. quindi controllo per evitare ripetizioni:
                                        edge_already_intersect=0;% verifica che quel lato sià già presente
                                        v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                        if intersect_tetr(i).array(line_insert(m)).intersect_edge(1).num_edge>0 %non è il primo lato
                                            while (intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                if intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge==edge_face(l)
                                                    %lato già presente alla posizione v qundi esco dal while   
                                                    edge_already_intersect=1;
                                                    break;
                                                end
                                                v=v+1;
                                            end %while
                                            if edge_already_intersect==0 %devo aggiungere quel lato
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(l);  
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while

                                            end 
                                        else %è il primo lato, v resta 1
                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(l);  
                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; 
                                        end
                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=edge(edge_face(l),2); %e sua coord
                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord);
                                   end
                                   if abs(x(2))<=toll
                                        control_poly(k)=1; %aggiorna la struttura di intersezione del poligono 
                                        if k==1
                                            control_poly(num_edge_poly)=1;
                                        else
                                            control_poly(k-1)=1;
                                        end
                                   else
                                     control_poly(k)=1;
                                     control_poly(b(k+1))=1;
                                   end
                               elseif (x(1)>toll && x(1)<1-toll && x(2)<1-toll && x(2)>toll) %si intersecano in un punto interno ad entrambi
                                   flag_in=1;
                                   edge_control(edge_face(l))=1; %dice che quel lato è stato intersecato oltre che controllato
                                   %inserire il nodo nuovo se non presente 
                                    [ line_node ] = add_node([node(edge(edge_face(l),1),:)+x(1)*(node(edge(edge_face(l),2),:)-node(edge(edge_face(l),1),:))]); 
                                                                      
                                   %ricerco i tetraedri con questo
                                   %lato
                                   tetra_share=intersect(touch(edge(edge_face(l),1)).elenco_tetra,touch(edge(edge_face(l),2)).elenco_tetra);        
                                   for m=1:size(tetra_share,2)
                                        [line_insert(m),num_intersect] = insert_only_tetra(i,tetra_share(m),num_intersect,num_neighbour); %inserisce tetraedro nella struttura e mette lui e i suoi vicini da controllare
                                        
                                        %scorro i lati del poly per una stessa faccia. quindi, uno
                                        %stesso lato della faccia potrebbe essere intersecato da più
                                        %lati del poly. quindi controllo per evitare ripetizioni:
                                        edge_already_intersect=0;% verifica che quel lato sià già presente
                                        v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                        if intersect_tetr(i).array(line_insert(m)).intersect_edge(1).num_edge>0 %non è il primo lato
                                            while (intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                if intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge==edge_face(l)
                                                    %lato già presente alla posizione v qundi esco dal while   
                                                    edge_already_intersect=1;
                                                    break;
                                                end
                                                v=v+1;
                                            end %while
                                            if edge_already_intersect==0 %devo aggiungere quel lato
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(l);  
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while

                                            end 
                                        else %è il primo lato, v resta 1
                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(l);  
                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; 
                                        end
                                        
                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=line_node; %e sua coord
                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord);
                                   end
                               
                                    control_poly(k)=1; %aggiorna la struttura di intersezione del poligono 
                               end %altrimenti non si intersecano e via 
                             end %chiudo norm lungo
                           end %chiudo k
                    end %end quel lato non era già stato controllato
                end %chiudo for l=1:3
                %prima di uscire bisogna vedere che se non ho trovato
                %intersezioni il poligono è interno alla faccia
                
                if flag_in==0 && edge_control(edge_face(1))~=1 && edge_control(edge_face(2))~=1 && edge_control(edge_face(3))~=1
                    %poligono completamente interno alla faccia 
                    %devo inserire la faccia come tagliata nei due
                    %tetraedri che la condividono 
                    if poly_share_face(j,2)~=-1 %controllo se la condividono uno o due tetraedri
                        num_share=2;
                    else
                        num_share=1;
                    end
                    %non ho bisogno di controllare se i due tetraedri siano
                    %già nella struttura perchè se i poligono è tutto
                    %dentro la loro faccia non ho mai trovato altre
                    %intersezioni
                    for z=1:num_share
                        num_intersect=num_intersect+1;
                        [line_insert,num_intersect] = insert_only_tetra(i,poly_share_face(j,z),num_intersect,num_neighbour);
                        intersect_tetr(i).array(num_intersect).intersect_face(end+1).num_face=j; %inserisce la faccia
                        for d=1:num_edge_poly %inserire gli estremi del poligono
                            intersect_tetr(i).array(num_intersect).intersect_face(end).coord(end+1)=poly(i,d); 
                            intersect_tetr(i).array(num_intersect).intersect_face(end).coord=unique(intersect_tetr(i).array(num_intersect).intersect_face(end).coord);
                        end
                    end
                    
                    %tutti i lati del poligono sono tagliati
                    control_poly(:)=ones(size(control_poly,1),1);
                end %chiude if poligono interno alla faccia
            end %chiudo flag
        end %chiudo complanari   
 else %non sono parallali piano faccia e piano poligono
        
        %interseco le tre rette dei lati della faccia con il piano (se non
        %sono paralleli, se sono paralleli potrebbe essere una intersezione
        %completa o niente(stesso caso di uno dei tre lati del caso complanare)) trovo le coordinate parametriche del lato della
        %faccia. Vedo se la coordinata è tra zero e uno altrimenti non c'è
        %intersezione. Se è fra zero e uno vedi con inner se è interno.
        %Se è proprio zero o uno vedi se l'intersezione capita su un
        %vertice del poligono altrimenti non è preso.
        %dopo guardi se appartiene al bordo delpoligono facendo il prodotto
        %vettoriale tra la direzione del lato delpoligono e il vettore
        %congiungente un vertice del lato del poligono e l'intersezione
        %cartesiana. Se viene zero cerco la cooridinata parametrica
        %dell'intersezione con il lato del poligono e la salvo perchè mi
        %servirà. Se non è zero l'intersezione è interna quindi avendo già
        %considerato tutti i casi è preso.
        
        for w=1:num_dim %scorro i lati della faccia
           [ flag_edge ] = already_control( edge_face(w) , edge_control);
           if flag_edge==0 %quel lato non era già stato controllato
                v3=[node(edge(edge_face(w),2),:)-node(edge(edge_face(w),1),:)];
                if abs(dot(n,v3))<=toll %n e v3 perpendicolari=> piano parallelo v3
                    t(w)=inf;
                else %non paralleli
                    %t1(j)=(dot((points(poly(1,1),:)-node(edge(j,1),:)),n))\(dot(v3,n)); %metodo sberrons 
                    A=[n(1),n(2),n(3),0;... %metodo lidia
                       1,0,0,-v3(1);...
                       0,1,0,-v3(2);...
                       0,0,1,-v3(3)];
                    bb=[n(1)*points(poly(1,1),1)+n(2)*points(poly(1,1),2)+n(3)*points(poly(1,1),3);...
                       node(edge(edge_face(w),1),1);...
                       node(edge(edge_face(w),1),2);...
                       node(edge(edge_face(w),1),3)];
                    X=A\bb;
                    t(w)=X(4); %coord para di dove incrocia il piano del poli rispetto lato faccia
                end
            end
        end %end scorro i lati della faccia    
        %il vettore t contiene le coordinate parametriche dell'intersezione
        %delle tre rette passanti per i lati con il piano del poligono
        
        for w=1:num_dim %scorro i lati della faccia
                       
            %controllo se lato già controllato
            [ flag_edge ] = already_control( edge_face(w) , edge_control);
            if flag_edge==0 %quel lato non era già stato controllato
                edge_control(edge_face(w))=2;

                if t(w)~=inf %piano poligono e lato faccia non paralleli
                    if t(w)>=-toll && t(w)<=1+toll %il lato interseca il piano
                        %trovo le coordinate del punto di intersezione
                        X=node(edge(edge_face(w),1),:)+t(w)*(node(edge(edge_face(w),2),:)-node(edge(edge_face(w),1),:));

                        %controllo che il punto sia interno o sul bordo al poligono
                        flag= inner_point(i,num_edge_poly,area_poly, X ,n);
                        
                        if flag==1 %intersezione interna o sul bordo al poligono
                            %se t è proprio 0 o 1 il lato va bene solo se il punto
                            %di intersezione corrisponde a un vertice del poligono
                            if abs(t(w))<=toll || abs(t(w)-1)<=toll %vertici lato faccia
                                %controllo se X corrisponde a un vertice
                                %del poligono
                                flag_vertex_poly=0;
                                for g=1:num_edge_poly
                                    if abs(X-points(poly(i,g),:))<=[toll toll toll]
                                        flag_vertex_poly=g;
                                    end
                                end
                                if flag_vertex_poly ~=0 %intersezione su vertice poligono
                                    
                                    %INSERISCI la faccia NEL PUNTO X e dico che passa per
                                    %il vertice numero flag_vertex_poly del
                                    %poligono
                                    %non scorro line insert perchè interseca solo il lato quindi
                                    %considero già tutti i 2 tetraedri di line_insert
                                    %vedendo quali condividono quel lato non inserisco X 
                                    %come nuovo nodo perchè è un nodo del tetraedro
                                    edge_control(edge_face(w))=1; %dice che quel lato è stato intersecato oltre che controllato
                                    %questo lato va inserito anche in tutti i tetraedri che lo
                                    %condividono:
                                    %cerco i tetraedri che condividono il lato edge_face(w)
                                    tetra_share=intersect(touch(edge(edge_face(w),1)).elenco_tetra,touch(edge(edge_face(w),2)).elenco_tetra);
                                                                 
                                    for m=1:size(tetra_share,2)
                                        [line_insert,num_intersect] = insert_only_tetra(i,tetra_share(m),num_intersect,num_neighbour);
                                        
                                        %scorro i lati del poly per una stessa faccia. quindi, uno
                                        %stesso lato della faccia potrebbe essere intersecato da più
                                        %lati del poly. quindi controllo per evitare ripetizioni:
                                        edge_already_intersect=0;% verifica che quel lato sià già presente
                                        v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                        if intersect_tetr(i).array(line_insert).intersect_edge(1).num_edge>0 %non è il primo lato
                                            while (intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                if intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge==edge_face(w)
                                                    %lato già presente alla posizione v qundi esco dal while   
                                                    edge_already_intersect=1;
                                                    break;
                                                end
                                                v=v+1;
                                            end %while
                                            if edge_already_intersect==0 %devo aggiungere quel lato
                                                intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge=edge_face(w);  
                                                intersect_tetr(i).array(line_insert).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                intersect_tetr(i).array(line_insert).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while

                                            end 
                                        else %è il primo lato, v resta 1
                                            intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge=edge_face(w);  
                                            intersect_tetr(i).array(line_insert).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                            intersect_tetr(i).array(line_insert).intersect_edge(v+1).coord=[]; 
                                        end
                                        
                                        if abs(t(w))<=toll %primo vertice lato tetra
                                            intersect_tetr(i).array(line_insert).intersect_edge(v).coord(end+1)=edge(edge_face(w),1);
                                        else %secondo vertice
                                            intersect_tetr(i).array(line_insert).intersect_edge(v).coord(end+1)=edge(edge_face(w),2);
                                        end
                                        intersect_tetr(i).array(line_insert).intersect_edge(end).coord=unique(intersect_tetr(i).array(line_insert).intersect_edge(end).coord);
                                    end

                                    %inserisco in inter_poli le coordinate dei due lati che condividono il
                                    %vertice tagliato:
                                    control_poly(flag_vertex_poly)=1;
                                    if flag_vertex_poly==1
                                        control_poly(num_edge_poly)=1;
                                    else
                                        control_poly(flag_vertex_poly-1)=1;
                                    end
                                else %non è uno dei verici
                                    %bisogna vedere che non cada su un lato
                                    %del poligono e nel caso sia così mettere in control poly il controllo effettuato,
                                    %si scorrono i lati del poligono e si controlla che il
                                    %prodotto scalare tra il vettore del lato del poligono e quello
                                    %congiungente il punto di intersezione e uno dei vertici del lato poligono, sia zero
                                    for c=1:num_edge_poly
                                        aa=points(poly(i,b(c+1)),:)-points(poly(1,b(c)),:);
                                        bb=points(poly(i,b(c)),:)-X;
                                        if norm(cross(aa,bb))<toll %le due lunghezze sono uguali
                                            control_poly(c)=1;
                                        end
                                    end %c
                                    
                                    if abs(t(w))<toll    
                                        special_edge(end+1)=edge(edge_face(w),1);
                                    elseif abs(t(w)-1)<toll
                                        special_edge(end+1)=edge(edge_face(w),2);
                                    end
                                end
                                
                            else %intersezione interna al lato faccia

                                %controllo se X appartiene al bordo del poligono
                                s=-ones(1,num_edge_poly);
                                for g=1:num_edge_poly
                                    %controllo con prodotto vettoriale p1-p2 e p1-X
                                    %che devono essere paralleli
                                    if norm(cross(points(poly(i,b(g+1)),:)-points(poly(i,g),:),points(poly(i,g),:)-X))<toll
                                        %so già che X interno allora è sicuro sul lato del poligono
                                        control_poly(g)=1;
                                        %s=coord para di dove cade X rispetto al lato g
                                        s(g)=(X-points(poly(i,g),:))/(points(poly(i,b(g+1)),:)-points(poly(i,g),:));
                                        if abs(s(g)-1)<toll %se s(g) è 1 devo inserire il lato dopo
                                            control_poly(b(g+1))=1;
                                        elseif abs(s(g))<toll
                                            if g==1
                                                control_poly(num_edge_poly)=1;
                                            else
                                                control_poly(g-1)=1;
                                            end
                                        
                                        end
                                    end                           
                                end
                 
                                %X è un nuovo nodo da inserire:
                                [line_node]=add_node( X ); 
                                
                                %DEVO INSERIRE TUTTI
                                %I TETRA CHE CONDIVIDONO QUEL LATO PERCHè
                                %IL LATO è TAGLIATO, NON LA FACCIA
                                edge_control(edge_face(w))=1; %dice che quel lato è stato intersecato oltre che controllato
                                %cerco i tetraedri che condividono quel
                                %lato
                                share_tetra=intersect(touch(edge(edge_face(w),1)).elenco_tetra,touch(edge(edge_face(w),2)).elenco_tetra);
                                for d=1:size(share_tetra,2)

                                    %inserisco i tetraedri trovati in
                                    %intersect_tetra e inserisco che sono
                                    %intersecti nel lato nel punto X
                                    
                                    [line_insert,num_intersect] = insert_only_tetra(i,share_tetra(d),num_intersect,num_neighbour);
                                    %scorro i lati del poly per una stessa faccia. quindi, uno
                                    %stesso lato della faccia potrebbe essere intersecato da più
                                    %lati del poly. quindi controllo per evitare ripetizioni:
                                    edge_already_intersect=0;% verifica che quel lato sià già presente
                                    v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                    if intersect_tetr(i).array(line_insert).intersect_edge(1).num_edge>0 %non è il primo lato
                                        while (intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                            if intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge==edge_face(w)
                                                %lato già presente alla posizione v qundi esco dal while   
                                                edge_already_intersect=1;
                                                break;
                                            end
                                            v=v+1;
                                        end %while
                                        if edge_already_intersect==0 %devo aggiungere quel lato
                                            intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge=edge_face(w);  
                                            intersect_tetr(i).array(line_insert).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                            intersect_tetr(i).array(line_insert).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while

                                        end 
                                    else %è il primo lato, v resta 1
                                        intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge=edge_face(w);  
                                        intersect_tetr(i).array(line_insert).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                        intersect_tetr(i).array(line_insert).intersect_edge(v+1).coord=[]; 
                                    end
                                   
                                    
                                    intersect_tetr(i).array(line_insert).intersect_edge(v).coord(end+1)=total_node;
                                    intersect_tetr(i).array(line_insert).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert).intersect_edge(v).coord);
                                end %ciclo d
                            end %chiudo ciclo interno lato
                        end %chiudo flag di inner
                    end %chiudo f di lato intersecato piano

                else %LATO FACCIA PARALLELO PIANO POLIGONO: t(p) è inf
                    
                    %se un punto del lato appartiene al piano del poligono il
                    %lato appartiene al piano altrimenti sono pralleli non
                    %complanari e salto quel lato

                    if abs(dot(node(face(j,w),:)-points(poly(i,1),:),n))<toll %sono complanari

                        flag(1)=inner_point(i,num_edge_poly,area_poly,node(edge(edge_face(w),1),:),n);
                        flag(2)=inner_point(i,num_edge_poly,area_poly,node(edge(edge_face(w),2),:),n);

                        if isequal(flag,[1 1]) %lato tetra interno/bordo
                            %va bene sono se uno dei due vertici del lato del
                            %tetraedro corrisponde a un vertice del
                            %poligono.
                            %quindi per ogni lato del poligono controllo il 
                            %punto di intersezione e vedo se è interno.
                            
                            flag_found=0; %mi chiede se trova che cade su un vertice del poligono
                            
                            for k=1:num_edge_poly 
                                
                               if abs(points(poly(i,b(k)),:)-node(face(j,a(w)),:))<=[toll toll toll] %primo vertice lato tetraedro
                                    flag_found=1;
                                   %la faccia del tetraedro non è da inserire perchè tocca solo il suo vertice
                                    %non inserisco nessun nuovo nodo perchè l'intersezione è un vertice del lato
                                    %INSERISCO per tutti i tetraedri che condividono quel lato:
                                    tetra_share=intersect(touch(edge(edge_face(w),1)).elenco_tetra,touch(edge(edge_face(w),2)).elenco_tetra);
                                    edge_control(edge_face(w))=1; %dice che quel lato è stato intersecato oltre che controllato
                                    for f=1:size(tetra_share,2)
                                        if edge_control(edge_face(w))==0 %quel lato non già controllato, altrimenti lo inserisce più volte
                                            [line_insert,num_intersect]=insert_only_tetra(i,tetra_share(f),num_intersect,num_neighbour);
                                            
                                            %scorro i lati del poly per una stessa faccia. quindi, uno
                                            %stesso lato della faccia potrebbe essere intersecato da più
                                            %lati del poly. quindi controllo per evitare ripetizioni:
                                            edge_already_intersect=0;% verifica che quel lato sià già presente
                                            v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                            if intersect_tetr(i).array(line_insert).intersect_edge(1).num_edge>0 %non è il primo lato
                                                while (intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                    if intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge==edge_face(w)
                                                        %lato già presente alla posizione v qundi esco dal while   
                                                        edge_already_intersect=1;
                                                        break;
                                                    end
                                                    v=v+1;
                                                end %while
                                                if edge_already_intersect==0 %devo aggiungere quel lato
                                                    intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge=edge_face(w);  
                                                    intersect_tetr(i).array(line_insert).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                    intersect_tetr(i).array(line_insert).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while

                                                end 
                                            else %è il primo lato, v resta 1
                                                intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge=edge_face(w);  
                                                intersect_tetr(i).array(line_insert).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                intersect_tetr(i).array(line_insert).intersect_edge(v+1).coord=[]; 
                                            end
                                            
                                            intersect_tetr(i).array(line_insert).intersect_edge(v).coord(end+1)=face(j,a(w));
                                            intersect_tetr(i).array(line_insert).intersect_edge(v).coord(end+1)=face(j,a(w+1));
                                            intersect_tetr(i).array(line_insert).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert).intersect_edge(v).coord);
                                        end
                                    end
                                    edge_control(edge_face(w))=1; %dice che quel lato è stato intersecato oltre che controllato
                                    control_poly(k)=1;
                                    if k==1
                                        control_poly(num_edge_poly)=1;
                                    else
                                        control_poly(k-1)=1;
                                    end
                                    
                                elseif abs(points(poly(i,b(k)),:)-node(face(j,a(w+1)),:))<=[toll toll toll] %secondo vertice lato tetraedro
                                    flag_found=1;
                                    tetra_share=intersect(touch(edge(edge_face(w),1)).elenco_tetra,touch(edge(edge_face(w),2)).elenco_tetra);
                                    edge_control(edge_face(w))=1; %dice che quel lato è stato intersecato oltre che controllato
                                    for r=1:size(tetra_share,2)
                                        [line_insert,num_intersect]=insert_only_tetra(i,tetra_share(r),num_intersect,num_neighbour);
                                        
                                        %scorro i lati del poly per una stessa faccia. quindi, uno
                                        %stesso lato della faccia potrebbe essere intersecato da più
                                        %lati del poly. quindi controllo per evitare ripetizioni:
                                        edge_already_intersect=0;% verifica che quel lato sià già presente
                                        v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                        if intersect_tetr(i).array(line_insert).intersect_edge(1).num_edge>0 %non è il primo lato
                                            while (intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                if intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge==edge_face(w)
                                                    %lato già presente alla posizione v qundi esco dal while   
                                                    edge_already_intersect=1;
                                                    break;
                                                end
                                                v=v+1;
                                            end %while
                                            if edge_already_intersect==0 %devo aggiungere quel lato
                                                intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge=edge_face(w);  
                                                intersect_tetr(i).array(line_insert).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                intersect_tetr(i).array(line_insert).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while

                                            end 
                                        else %è il primo lato, v resta 1
                                            intersect_tetr(i).array(line_insert).intersect_edge(v).num_edge=edge_face(w);  
                                            intersect_tetr(i).array(line_insert).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                            intersect_tetr(i).array(line_insert).intersect_edge(v+1).coord=[]; 
                                        end
                                        
                                        
                                        intersect_tetr(i).array(line_insert).intersect_edge(v).coord(end+1)=face(j,a(w));
                                        intersect_tetr(i).array(line_insert).intersect_edge(v).coord(end+1)=face(j,a(w+1));
                                        intersect_tetr(i).array(line_insert).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert).intersect_edge(v).coord);
                                    end
                                    control_poly(k)=1;
                                    if k==1
                                        control_poly(num_edge_poly)=1;
                                    else
                                        control_poly(k-1)=1;
                                    end
                               end
                            end
                            
                            if flag_found==0 %non è su un vertice del poigono
                                special_edge(end+1:end+2)=edge(edge_face(w),:);
                            end                

                        else %if isequal(flag,[0 0])% || isequal(flag,[0 1]) || isequal(flag,[1 0])
                           %00 entrambi esterni, 01 o 10 uno esterno e uno inter/bordo
 
                           for k=1:num_edge_poly %scorro i lati del poligono
                               if norm(cross((node(face(j,a(w+1)),:)-node(face(j,a(w)),:)),(points(poly(i,b(k)),:)-points(poly(i,b(k+1)),:))))<=toll %lato faccia e lato poligono paralleli
                                   v1=[points(poly(i,b(k)),:)-node(face(j,a(w)),:)];%vettore direzione del primo punto del lato del poligono e primo punto lato del tetra
                                   v3=[node(face(j,a(w+1)),:)-node(face(j,a(w)),:)];

                                   if norm(cross(v1,v3))<=toll %rette lato e retta lato poligono concidenti
                                       
                                         %k è la coord para del vertice del lato del tetra rispetto al lato
                                         %del poligono
                                         ki=(points(poly(i,b(k+1)),:)-points(poly(i,b(k)),:))'\(node(face(j,a(w)),:)-points(poly(i,b(k)),:))'; 
                                         kf=(points(poly(i,b(k+1)),:)-points(poly(i,b(k)),:))'\(node(face(j,a(w+1)),:)-points(poly(i,b(k)),:))';
                                         [ki,kf]=sort(ki,kf);
                                         
                                         
                                         if kf>=1-toll && ki<=1-toll
                                             edge_control(edge_face(w))=1; %dice che quel lato è stato intersecato oltre che controllato
                                             %inserire le caratteristiche del
                                             %taglio nella struttura       
                                             %cerco i tetraedri che condividono il lato edge_face(l)
                                             tetra_share=intersect(touch(edge(edge_face(w),1).elenco_tetra),touch(edge(edge_face(w),2).elenco_tetra));
                                            
                                            control_poly(k)=1;
                                            for m=1:size(tetra_share,2)
                                                [line_insert(m),num_intersect]=insert_only_tetra(i,tetra_share(m),num_intersect,num_neighbour); %mi dice dove ha inserito il tetredro o dove si trovava
                                                 
                                                %scorro i lati del poly per una stessa faccia. quindi, uno
                                                %stesso lato della faccia potrebbe essere intersecato da più
                                                %lati del poly. quindi controllo per evitare ripetizioni:
                                                edge_already_intersect=0;% verifica che quel lato sià già presente
                                                v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                                if intersect_tetr(i).array(line_insert(m)).intersect_edge(1).num_edge>0 %non è il primo lato
                                                    while (intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                        if intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge==edge_face(w)
                                                            %lato già presente alla posizione v qundi esco dal while   
                                                            edge_already_intersect=1;
                                                            break;
                                                        end
                                                        v=v+1;
                                                    end %while
                                                    if edge_already_intersect==0 %devo aggiungere quel lato
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(w);  
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                        
                                                    end 
                                                else %è il primo lato, v resta 1
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(w);  
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; 
                                                end
                                            end
                                            if ki<=toll %lato del poligono completamente interno al lato della faccia
                                                %inserire in quale coordinata cartesiana viene intersecato quindi aggiorno node con i nuovi punti di
                                                %intersezione (in questo caso sono due e sono gli estremi del lato del poligono)
                                                %li devo comunque aggiungere in node perchè così hanno un unica
                                                %numerazione prima controllo che non ci siano già in node

                                                 line_node1=add_node(edge(edge_face(w),1)); %inserisce o ritorna il numero del nodo da inserire nella struttura di enreambi gli estremi del lato del poligono interno al lato della faccia
                                                 line_node2=add_node(edge(edge_face(w),2));
                                                 for m=1:size(tetra_share,2) %inserisce le stesse coordinate in tutti i tetraedri che hanno quel lato
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=line_node1;
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=line_node2;
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord);
                                                 end
                                            else 
                                                %bisogna inserire nella struttura delle intersezioni
                                                %del poligono la coordinata parametrica ki perchè è interna 
                                                control_poly(k)=1;
                                                control_poly(b(k+1))=1;
                                                %bisogna aggionare node inserendo
                                                %la coordinata del lato del
                                                %poligono che è interno al lato
                                                %della faccia e metterlo nella
                                                %struttura generale
                                                line_node=add_node(points(poly(i,b(k+1)),:));  
                                                for m=1:size(tetra_share,2) %inserisce le stesse coordinate in tutti i tetraedri che hanno quel lato
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=line_node;
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord);
                                                end
                                            end
                                     elseif (ki<=toll && kf>toll)
                                          edge_control(edge_face(w))=1; %dice che quel lato è stato intersecato oltre che controllato
                                          %inserire le caratteristiche del taglio
                                          %cerco i tetraedri che condividono il lato edge_face(l)
                                          tetra_share=intersect(touch(edge(edge_face(w),1).elenco_tetra),touch(edge(edge_face(w),2).elenco_tetra));
                                            for m=1:size(tetra_share,2)
                                                [line_insert(m),num_intersect]=insert_only_tetra(i,tetra_share(m),num_intersect,num_neighbour); %mi dice dove ha inserito il tetredro o dove si trovava
                                               
                                                edge_already_intersect=0;% verifica che quel lato sià già presente
                                                v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                                if intersect_tetr(i).array(line_insert(m)).intersect_edge(1).num_edge>0 %non è il primo lato
                                                    while (intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                        if intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge==edge_face(w)
                                                            %lato già presente alla posizione v qundi esco dal while   
                                                            edge_already_intersect=1;
                                                            break;
                                                        end
                                                        v=v+1;
                                                    end %while
                                                    if edge_already_intersect==0 %devo aggiungere quel lato
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(w);  
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                        
                                                    end 
                                                else %è il primo lato, v resta 1
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(w);  
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; 
                                                end
                                                
                                            end
                                            %bisogna inseire
                                            %nella struttura delle intersezioni
                                            %del poligono
                                            %la coordinata parametrica kf perchè
                                            %è interna 
                                            control_poly(k)=1;
                                            if k==1
                                                control_poly(num_edge_poly)=1;
                                            else
                                                control_poly(k-1)=1;
                                            end
                                            %bisogna aggionare node inserendo
                                            %la coordinata del lato del
                                            %poligono che è interno al lato
                                            %della faccia e metterlo nella
                                            %struttura generale
                                            line_node = add_node([points(poly(i,b(k)),1),points(poly(i,b(k)),2),points(poly(i,b(k)),3)]); %p= coordinate del primo estemo del lato della faccia considerato
                                            for m=1:size(tetra_share,2) %inserisce le stesse coordinate in tutti i tetraedri che hanno quel lato
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=line_node;
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord=unique(intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord);
                                                end
                                     end %chiude controlli fra 0 e 1
                                   end %coincidenti
                                   
                               else %LATO POLIGONO E LATO TETRAEDRO NON PARALLELI
                                   
                                 %il lato edge_face(w) è coincidente con piano del poligono e ha un punto fuori e uno dentro
                                 %oppure tutti e due fuori  
                                 
                                 %salvo il punto interno se non coincide
                                 %con quello di intersezione e il punto di
                                 %intersezioen
                                 if isequal (flag,[0 1])
                                    inner=edge(edge_face(w),2); %punto interno
                                 elseif isequal (flag,[1 0])
                                    inner=edge(edge_face(w),1);
                                 else
                                     inner=-1;
                                 end

                                 %sappiamo che non sono paralleli, troviamo
                                 %s e t
                                 x=[(node(edge(edge_face(w),2),:)-node(edge(edge_face(w),1),:))',-(points(poly(i,b(k+1)),:)-points(poly(i,b(k)),:))']\[(points(poly(i,b(k)),:)-node(edge(edge_face(w),1),:))'];

                                 if x(1)>=-toll && x(1)<=1+toll && x(2)>=-toll && x(2)<=1+toll %se node_intersection è interno al lato faccia e al quello del poligono
                                         node_intersection=node(edge(edge_face(w),1),:)+x(1)*(node(edge(edge_face(w),2),:)-node(edge(edge_face(w),1),:));
                                         [line_insertnode]=add_node(node_intersection);
                                          edge_control(edge_face(w))=1;
                                         %mi chiedo se sono lo stesso punto
                                         if line_insertnode==inner 

                                             if (abs(x(2))<toll || abs(x(2)-1)<toll) %se è un vertice del poligono
                                                 %quel lato è da prendere

                                                 tetra_share=intersect(touch(edge(edge_face(w),1)).elenco_tetra,touch(edge(edge_face(w),2)).elenco_tetra);
                                                 for m=1:size(tetra_share,2)
                                                    [line_insert(m),num_intersect]=insert_only_tetra(i,tetra_share(m),num_intersect,num_neighbour); %mi dice dove ha inserito il tetredro o dove si trovava

                                                    edge_already_intersect=0;% verifica che quel lato sià già presente
                                                    v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                                    if intersect_tetr(i).array(line_insert(m)).intersect_edge(1).num_edge>0 %non è il primo lato
                                                        while (intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                            if intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge==edge_face(w)
                                                                %lato già presente alla posizione v qundi esco dal while   
                                                                edge_already_intersect=1;
                                                                break;
                                                            end
                                                            v=v+1;
                                                        end %while
                                                        if edge_already_intersect==0 %devo aggiungere quel lato
                                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(w);  
                                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                            intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while

                                                        end 
                                                    else %è il primo lato, v resta 1
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(w);  
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                        intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; 
                                                    end

                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord(end+1)=inner;
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord=unique( intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord);
                                                 end
                                             else %non è un verice del poligono ma siamo sul bordo 
                                                 special_edge(end+1)=inner;                                         
                                             end

                                         else %nuovo nodo

                                             control_poly(k)=1;
                                             tetra_share=intersect(touch(edge(edge_face(w),1)).elenco_tetra,touch(edge(edge_face(w),2)).elenco_tetra);
                                             for m=1:size(tetra_share,2)
                                                [line_insert(m),num_intersect]=insert_only_tetra(i,tetra_share(m),num_intersect,num_neighbour); %mi dice dove ha inserito il tetredro o dove si trovava

                                                %scorro i lati del poly per una stessa faccia. quindi, uno
                                                %stesso lato della faccia potrebbe essere intersecato da più
                                                %lati del poly. quindi controllo per evitare ripetizioni:
                                                edge_already_intersect=0;% verifica che quel lato sià già presente
                                                v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                                                if intersect_tetr(i).array(line_insert(m)).intersect_edge(1).num_edge>0 %non è il primo lato
                                                while (intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                                                    if intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge==edge_face(w)
                                                        %lato già presente alla posizione v qundi esco dal while   
                                                        edge_already_intersect=1;
                                                        break;
                                                    end
                                                    v=v+1;
                                                end %while
                                                if edge_already_intersect==0 %devo aggiungere quel lato
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(w);  
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                    intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while

                                                end 
                                            else %è il primo lato, v resta 1
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v).num_edge=edge_face(w);  
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v+1).coord=[]; 
                                            end
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(v).coord (end+1)=line_insertnode;
                                                intersect_tetr(i).array(line_insert(m)).intersect_edge(end).coord=unique(intersect_tetr(i).array(line_insert(m)).intersect_edge(end).coord);
                                          end
                                             %aggiungo i tetraedri che condividono
                                             %quel lato


                                         end %line_insertnode==inner 
                                     end %flag_x
                               end %chiudo if lato faccia lato poligono paralleli
                           end %chiudo for k scorro lati poligono    
                        end %chiudo flag se sono gli estremi interni al poligono
                    end %chiuso sono complanari 
                end %chiudo if inf (lato faccia paralleli o no)
            end %flag quel lato non ancora controllato
        end %chiudo w che scorre i lati del tetra
        
        %---------------TAGLIATA SOLO FACCIA NO LATI----------------------
        %controllo se ho trovato un lato tagliato per quella facci: vedo s
        %è 1 in control face
        
        exit_face=0;%non so se serve, da verificare
        
        %trovo la coord parametrica rispetto al lato della faccia  dell'intersezione lato poli piano faccia
        for w=1:num_edge_poly %scorro i lati del poligono
            v3=[points(poly(i,b(w+1)),:)-points(poly(i,b(w)),:)];
            %calcolo la normale alla faccia
            v1=node(face(j,2),:)-node(face(j,1),:);
            v2=node(face(j,3),:)-node(face(j,1),:);
            f=cross(v1,v2);
            if abs(dot(f,v3))<=toll %n e v3 perpendicolari=> piano parallelo v3
                t(w)=Inf; %ma se il lato fosse completamente dentro la faccia lo prendiamo in quache altro punto del programma? Forse lo analizzo nel mio pezzo?
            else %non paralleli
                %t1(j)=(dot((points(poly(1,1),:)-node(edge(j,1),:)),n))\(dot(v3,n)); %metodo sberrons 
                A=[f(1),f(2),f(3),0;... %metodo lidia
                   1,0,0,-v3(1);...
                   0,1,0,-v3(2);...
                   0,0,1,-v3(3)];
                bb=[f(1)*node(face(j,1),1)+f(2)*node(face(j,1),2)+f(3)*node(face(j,1),3);...
                   points(poly(i,w),1);...
                   points(poly(i,w),2);...
                   points(poly(i,w),3)];
                X=A\bb;
                t(w)=X(4); %coord para di dove incrocia il piano del tetra rispetto lato poly
             end
        end %end scorro i lati della faccia    
        
        for w=1:num_edge_poly
            if control_poly(w)==0
                [num_intersect]=intersect_onlyface_noedge(f,i,j,num_edge_poly,edge_face ,a,b, num_dim,t,w,num_intersect,num_neighbour);
            end %if non avevo trovato intersezione con nessun lato
        end
end %chiudo tutto
end

