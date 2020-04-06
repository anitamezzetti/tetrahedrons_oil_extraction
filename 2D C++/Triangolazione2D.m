clear all
clc

global node;
global ele;
global edge;
global touch;
global points;
global traces;
global toll;
global intersect_triangle;

toll=10^(-14); %tolleranza
flag=zeros(1,2);

%funzione che carica la triangolazione e le tracce
[num_node,num_dim,num_ele,num_lati,num_edge,num_points,num_traces]=Input_file_Triangolazione2D;
%vettore di strutture o matrici sparse
%touch: vettore di liste che a ogni riga corrisponde un nodo e sono salvati i numeri dei triangoli di cui tale nodo è vertice
for i=1:1:num_node
    touch(i).num_tri=0;
    touch(i).num_node=0;
end
for j=1:1:num_ele
    for k=1:1:num_lati
        touch(ele(j,k)).num_tri=touch(ele(j,k)).num_tri+1;
        touch(ele(j,k)).elenco_tri(touch(ele(j,k)).num_tri)=j;
    end
end
for j=1:1:num_edge
    touch(edge(j,1)).num_node=touch(edge(j,1)).num_node+1;
    touch(edge(j,1)).elenco_node(touch(edge(j,1)).num_node)=edge(j,2);
    touch(edge(j,2)).num_node=touch(edge(j,2)).num_node+1;
    touch(edge(j,2)).elenco_node(touch(edge(j,2)).num_node)=edge(j,1);
end

%for i=1:1:num_node %scorro i nodi
%   touch(i).elenco_tri=sort(touch(i).elenco_tri); %ordino i triangoli
%   touch(i).elenco_node=sort(touch(i).elenco_node); %ordino i nodi
%end

for i=1:1:num_traces %scorro le tracce con i

    ft=@(t) (points(traces(i,1),:))+t*((points(traces(i,2),:)-(points(traces(i,1),:)))); %retta passante per i due vertici della traccia
    p=1;
    %coord(i).list=0; %inizializzo la lista dove per ogni traccia salvo le coordinate curvilinee delle intersezioni
    %poly(i).list=0;
    intersect_triangle(i).array(1).coord=-1; %struttura dei triangoli tagliati per ogni traccia
    intersect_triangle(i).array(1).num_tri=-1;
    intersect_triangle(i).array(1).poly(1).vert_poly(1)=-1;
    %a(1)=-1;

    n=[-points(traces(i,2),2)+points(traces(i,1),2), points(traces(i,2),1)-points(traces(i,1),1)]; %vettore normale traccia i (-ty, tx)
    
    for j=1:1:num_edge %scorro i lati con j. appena trovo un lato intersecato esco dal ciclo, 
        %vedo a che triangolo appartiene tale lato e poi cerco i vicini
        %prima cerco il vettore candidato a essere intersecato se è candidato poi controllo con la funzione che s e t siano fra 0 e 1
        [s1,s2]=scalar(i,j,n);
        %se s1 e s2 sono concordi scarto direttamente, quinid non lo inserisco neanche
  
        %x è il vettore (s t)' ottenuto risolvendo il sistema lineare
        %dato da ...
        x=[(node(edge(j,2),:)-node(edge(j,1),:))',(points(traces(i,1),:)-points(traces(i,2),:))']\[(points(traces(i,1),:)-node(edge(j,1),:))'];
        %x(1)=s x(2)=t
        
        if s1*s2<-toll  %se sono discordi continuo con i controlli, altrimenti vado diretto al lato succesivo
            %fs=@(s) node(edge(j,1),:) + (node(edge(j,2),:)-node(edge(j,1),:))*s;   %segmenti lati
            %ft=@(t) points(traces(i,1),:) + (points(traces(i,2),:)-points(traces(i,1),:))*t; %segmenti tracce
            %A=[(node(edge(j,2),:)-node(edge(j,1),:))',(points(traces(i,1),:)-points(traces(i,2),:))'];
            %b=[(points(traces(i,1),:)-node(edge(j,1),:))'];
            if x(1)>=-toll && x(2)>=-toll && x(1)<=1+toll && x(2)<=1+toll % sia t che s fra 0 e 1 i segmenti si intersecano (no vertici del segmento)
                %for k=1:1:num_ele  %scorro i triangoli                    
                    %dal momento che su matlab esiste solo l'allocazione dinamica (quindi è come se usassimo delle malloc), è
                    %meglio non creare nuovi vettori che andremo a utilizzare una sola volt. i controlli preferiamofarli attraversi cicli
                p=Insert(j,i,p,x(1),x(2));
                    %if ( edge(,:)==ele(k,1:2) ) || (edge(j,:)==ele(k,2:3)) || (edge(j,:)==ele(k,1:2:3)) ...
                     %  || (edge(j,2:-1:1)==ele(k,1:2)) || (edge(j,2:-1:1)==ele(k,2:3)) || (edge(j,2:-1:1)==ele(k,1:2:3))
                      % firstfound=k;
                      % break; %esco dal for che scorre i triangoli
                    %end
            end %se non entra nell'if è da scartare
        elseif (abs(s1)<=0+toll) && (abs(s2)<=0+toll)
           %sarebbe un sistema sovradeterminato ma in questo caso funziona perchè il rango è massimo
           ki=(points(traces(i,2),:)-points(traces(i,1),:))/(node(edge(j,1),:)-points(traces(i,1),:)); 
           %ki coordinata curvilinea dell'estremo iniziale del segmento
           %ripetto alla traccia, idem per kf ma è quello finale
           kf=(points(traces(i,2),:)-points(traces(i,1),:))/(node(edge(j,2),:)-points(traces(i,1),:));
           [ki,kf]=sort(ki,kf);
           %se k è fra 0 e 1 allora l'estremo del segemento è interno alla traccia. se esattamente zero o 1 cade nell'estremo
           if (ki>=0-toll) && (kf<=1+toll) %1
           elseif kf<=0+toll || ki>=1-toll %2
           elseif (kf>1+toll && ki<1-toll) || (ki<0-toll && kf>0+toll)
               if ki<=-toll
                   p=Insert(j,i,p,x(1),0);
               end
               if kf>=1+toll
                   p=Insert(j,i,p,x(1),1);
               end
           end
        elseif abs(s1*s2)<=0+toll && ((abs(s1)>=0+toll) || (abs(s2)>=0+toll)) %un vertice si trova sulla traccia   
            %sto analizzando il lato j di edge. s1 è legato da a x1, s2 è legato a x2
            if abs(s1)<=toll 
                %x1 è  sulla traccia
                flag=check_node(2,j,n,i,num_edge); %passiamo a check_node il nodo che non è sulla traccia, la riga di edge, la normale alla traccia e il numero di traccia
            else 
                %x2 è sulla traccia
                flag=check_node(1,j,n,i,num_edge);
            end
            for k=1:size(flag)
                if flag(k)~=-1 %flag(k) è il num del triangolo tagliato
                   if p==1 %primo triangolo
                       intersect_triangle(i).array(1).num_tri=flag(k);
                       intersect_triangle(i).array(1).coord(1)=x(2);
                       p=p+1;
                       intersect_triangle(i).array(1).intersect_edge=j;  
                       
                   else
                       flag1=0;
                       for v=1:1:p-1 %il for di v controlla che il triangolo non sia già presente
                           if intersect_triangle(i).array(v).num_tri==flag(k)
                                intersect_triangle(i).array(v).coord(end+1)=x(2);
                                flag1=1;

                                if x(1)>toll && x(1)<1-toll
                                    if intersect_triangle(i).array(v).intersect_edge(end)==-1 %se l'ultimo è-1 lo metto al posto dell'ultimo altrimenti nel posto successivo
                                        intersect_triangle(i).array(v).intersect_edge(end)=j; 
                                    else
                                        intersect_triangle(i).array(v).intersect_edge(end+1)=j;
                                    end
                                end

                           end
                       end
                       if flag1==0 %aggiungo il triangolo
                            intersect_triangle(i).array(p).num_tri=flag(k);
                            intersect_triangle(i).array(p).coord(1)=x(2);
                            if x(1)>toll && x(1)<1-toll
                                intersect_triangle(i).array(p).intersect_edge=j; 
                            else
                                intersect_triangle(i).array(p).intersect_edge=-1;
                            end
                            p=p+1; 
                       end
                   end
                end %end flag diverso -1
            end
        end
    end
   
    num_intersected=size(intersect_triangle(i).array);
    num_intersected=num_intersected(2);
    %allunghiamo la matrice node inserendo i nuovi vertici ottenuti
    %dall'intersezione di ogni lato di ogn triangolo di una traccia
    %Aggiungiamo il numero dei vertici (node) del triangolo e il numero dei
    %nuovi vertici ottenuti dall'intersezione all'interno dell'array di
    %intersect_triangle(i)
    new_num_node=size(node);
    new_num_node=new_num_node(1);
    for m=1:1:num_intersected %scorro i triangoli intersecati
        %salva il numero dei vertici dei triangoli
        intersect_triangle(i).array(m).vertex(1)=ele(intersect_triangle(i).array(m).num_tri,1);
        intersect_triangle(i).array(m).vertex(2)=ele(intersect_triangle(i).array(m).num_tri,2);
        intersect_triangle(i).array(m).vertex(3)=ele(intersect_triangle(i).array(m).num_tri,3);
        
        intersect_triangle(i).array(m).node_pass=-1;
        
        num_coord=size(intersect_triangle(i).array(m).coord);%numero coordinate per ogni triangolo
        num_coord=num_coord(2);
        for j=1:1:num_coord
            new_node=ft(intersect_triangle(i).array(m).coord(j));   %coordinate nuovo nodo
            %controlllo che il nodo non sia già presente:
            %rincontrollo il numero di nodi a ogni giro,
            %se ne possono aver aggiunti:
            
            flag=1;
            for k=1:1:new_num_node
                %controllo se il nuovo esiste già
                if isequal(node(k,:),new_node)==1
                    %controllo che il nodo esistente non fosse già un
                    %vertice del triangolo in considerazione
                    if intersect_triangle(i).array(m).vertex(1)~=k &&...
                       intersect_triangle(i).array(m).vertex(2)~=k &&...
                       intersect_triangle(i).array(m).vertex(3)~=k
                   
                         %salvataggio del nodo già esistente, ma che non è
                         %uno dei suoi vertici
                         intersect_triangle(i).array(m).vertex(end+1)=k;
                    else
                        intersect_triangle(i).array(m).node_pass=k; 
                        %ho salvato il vertice di quel triangolo intersect
                        %dove passa la traccia
                    end
                    flag=0; %nodo già presente, è il nodo k non aggungerlo
                    
                    %non mettere break che esce da tutto!!! :)
                end
            end
            if flag==1 %nodo da aggiungere
                %aggiunge un nuovo nodo
                node(end+1,:)=new_node;
                new_num_node=new_num_node+1;
                %salvataggio del numero del nuovo nodo presente su un lato
                %del triangolo
                intersect_triangle(i).array(m).vertex(end+1)=new_num_node;
                              
            end
        end %alla fine di questo ciclo vertex ha 4 o 5 nodi a seconda se è stato 
        %intersecato un un vertice e un lato o i due lati. cambia come mi
        %devo comportare:
        
    end
    

    %--------------------------PUNTO 2------------------------------------
    %riscorro i triangoli intersecati in un ciclo separato da quello per la
    %poligonizzazione. alla fine fare un ciclo unico!!!!

    for m=1:1:num_intersected
        intersect_triangle(i).array(m).share(1).share_num_tri=-1; %triangoli in comune
        intersect_triangle(i).array(m).share(1).share_nodes_tri=-1; %vertici in comune per quel triangolo
        %trovo l'elenco dei triancoli che condividono un vertice con il triangolo tagliato e quali vertici 
        
        %scorro i vertici del triangolo
        for j=1:num_lati
            for k=1:num_ele
                if k~=intersect_triangle(i).array(m).num_tri %non è lo stesso triangolo
                    if ele(intersect_triangle(i).array(m).num_tri,j)==ele(k,1) ||...
                            ele(intersect_triangle(i).array(m).num_tri,j)==ele(k,2) ||...
                            ele(intersect_triangle(i).array(m).num_tri,j)==ele(k,3) %uno dei tre vertici del triangolo k ugauli
                        
                        if intersect_triangle(i).array(m).share(1).share_num_tri==-1 %primo triangolo trovato per triangolo internecato m
                            intersect_triangle(i).array(m).share(1).share_num_tri=k;
                            intersect_triangle(i).array(m).share(1).share_nodes_tri=ele(intersect_triangle(i).array(m).num_tri,j);
                        else
                            %cerco se triangolo già presente
                            num_share_tri=size(intersect_triangle(i).array(m).share);
                            num_share_tri=num_share_tri(2);
                            flag=0; %flag diventa 1 se il triangolo k lo trova già
                            for z=1:num_share_tri %z scorre i tringoli gia inseriti
                                if k==intersect_triangle(i).array(m).share(z).share_num_tri %triangolo k già presente alla posizione z
                                    intersect_triangle(i).array(m).share(z).share_nodes_tri(end+1)=ele(intersect_triangle(i).array(m).num_tri,j); %nodo j in comune
                                    flag=1;
                                end
                            end
                            if flag==0 %triangolo non trovato
                                num_share_tri=num_share_tri+1;
                                intersect_triangle(i).array(m).share(num_share_tri).share_num_tri=k;
                                intersect_triangle(i).array(m).share(num_share_tri).share_nodes_tri=ele(intersect_triangle(i).array(m).num_tri,j);
                            end
                        end
                    end
                end
            end
        end
    end
    
    %-----------POLIGONALIZZAZIONE E SOTTOTRIANGOLAZIONE-------------------
    %scorro i triangoli intersecati per creare la poligonazione e
    %sottotriangolazione
    for m=1:1:num_intersected
        size_vertex=size(intersect_triangle(i).array(m).vertex);
        size_vertex=size_vertex(2);
        size_intersect_edge=size(unique(intersect_triangle(i).array(m).intersect_edge));
        size_intersect_edge=size_intersect_edge(2);
        %a seconda del numero di vertici cambia
        
        %-----CASO 1: 5 VERTICI E 2 LATI TAGLIATI--------------------------
        if size_vertex==5 && size_intersect_edge==2
            Vert5_Edge2_poly(i,m);
            Vert5_Edge2_tri(i,m);
        end
        
        %-----CASO 2: 5 VERTICI E 1 LATO TAGLIATO--------------------------
        %se la traccia sta completamente dentro un lato
        if size_vertex==5 && size_intersect_edge==1
            Vert5_Edge1(i,m);
        end
        
        
        %---CASO 3: 4 VERTICI E LA TRACCIA NON FINISCE DENTRO IL TRIANGOLO-
        if size_vertex==4 && ...
            (intersect_triangle(i).array(m).node_pass~=-1 ||...
             (intersect_triangle(i).array(m).node_pass==-1 &&...
              (abs(intersect_triangle(i).array(m).coord)<=toll ||...
               abs(intersect_triangle(i).array(m).coord-1)<=toll)))
            
            %------Poligonalizzazione------
            Vert4_noInt_poly(i,m);
            %------Triangolazione----------
            Vert4_noInt_tri( i,m );
        end
        
        %-----CASO 4: 3 VERTICI E LA TRACCIA FINISCE IN UN VERTICE---------
        if size_vertex==3 && ...
              (abs(intersect_triangle(i).array(m).coord)<=toll ||...
               abs(intersect_triangle(i).array(m).coord-1)<=toll)
            
            %------Poligonalizzazione------
            intersect_triangle(i).array(m).poly(:)=ele(intersect_triangle(i).array(m).num_tri,:);
            %------Triangolazione----------
            intersect_triangle(i).array(m).tri(1).vert_tri(:)=intersect_triangle(i).array(m).poly(w0).vert_poly(:);
        end
        
        %---CASO 5: 3 VERTICI E LA TRACCIA FINISCE DENTRO AL TRIANGOLO-----
        if size_vertex==3 &&...
                intersect_triangle(i).array(m).coord>toll && intersect_triangle(i).array(m).coord<1-toll
            
            Vert3_siInt(i,m);
            
        end
        
        %---CASO 6: 4 VERTICI E LA TRACCIA FINISCE DENTRO AL TRIANGOLO-----
        if size_vertex==4 &&...
                intersect_triangle(i).array(m).node_pass==-1 &&...
                intersect_triangle(i).array(m).coord>toll && intersect_triangle(i).array(m).coord<1-toll
            
            Vert4_siInt(i,m);
            
        end
        
    end
    
    %---------------VISUALIZZA TRIANGOLAZIONE E TRACCE---------------------

    %funzione che crea la figura di triangolazione con le tracce
    Show(num_edge,i)
    title('Triangolazione e traccia','Color','k')
    pause
    
    %-------STAMPA DEI TRIANGOLI INTERSECATI-------------------------------

    Show_tri_intersect( num_edge,i,num_intersected )
    pause
    
    %------------STAMPA DEI TRIANGOLI CHE HANNO IN COMUNE------------------
    %------------ALMENO UN VERTICE CON TRIANGOLI TAGLIATI------------------
    
    Show_tri_share( num_edge,i,num_intersected )
    pause
    
    %----------STAMPA LA POLIGONALIZZAZIONE--------------------------------
    
    Show_poly( num_edge,i,num_intersected )
    pause
    
    %----------STAMPA LA SOTTOTRIANGOLAZIONE-------------------------------
    
    Show_sottotri( num_edge,i,num_intersected )
    pause
    
end