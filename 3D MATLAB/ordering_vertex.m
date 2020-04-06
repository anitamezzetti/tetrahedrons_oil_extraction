function [ polig_poly ,vertex_newcoord] = ordering_vertex( i,k,v,tetra,vertex_newcoord,polig_poly)
%questa funzione ordina (in modo da formare poligoni) e inserisce i vertici dei nuovi poligoni che si
%formano sulla frattura, nella struttura di poligonizzazione polig_poly
 %k=tot_intersection ovvero la lunghezza di vertex_newcoord da
 %considerare (punti di intersezione di quel tetraedro)
 vertex_newcoord_up=[];
 vertex_newcoord_down=[];
 %prendo come primo nodo quello che ha la coordinaa x pi� bassa 
 %index conterr� il primo indice della di dove ha trovato un minimo
 [~,index]=min(vertex_newcoord(:,1));
 %p1 punto corrispondente a quello di indice minimo
 p1=vertex_newcoord(index,4);
 xp1=vertex_newcoord(index,1:3);
 %devo salvarlo nella struttura di poligonizzazione come il primo nodo
 polig_poly(v).num_tetra=tetra;
 polig_poly(v).coord(1)=p1;
 %devo levare p1 da vertex 
 vertex_newcoord(index,:)=[];
 %devo dividere tutti gli altri punti in due insiemi, quelli che hanno
 %coordinata y maggiore o uguale di quella di p1 e gli altri
 for g=1:size(vertex_newcoord,1)
     if vertex_newcoord(g,2)>=xp1(2)
         vertex_newcoord_up(end+1,4)=vertex_newcoord(g,4);
         vertex_newcoord_up(end,1:3)=vertex_newcoord(g,1:3);
     else
         vertex_newcoord_down(end+1,4)=vertex_newcoord(g,4);
         vertex_newcoord_down(end,1:3)=vertex_newcoord(g,1:3);
     end
 end
 %ordino i punti up con le y decrescenti e i punti down con le y crescenti
 %perch� serve per l'ordine
 if ~isempty(vertex_newcoord_down)
     [~,I]=sort(vertex_newcoord_down(:,2),'ascend');
     vertex_newcoord_down=vertex_newcoord_down(I,:);
 end
 if ~isempty(vertex_newcoord_up)
     [~,I]=sort(vertex_newcoord_up(:,2),'descend');
     vertex_newcoord_up=vertex_newcoord_up(I,:);
 end
 %ora inizio a vedere quali sono quelli down con la coordinata x minore
 %colleganoli uno per uno, cos� da averli pure in senso antiorario...ce
 %svuoto vertex_newcoord per poterlo ririempire con i nodi formanti un
 %poligono e non a caso
 vertex_newcoord=[];
 vertex_newcoord(1,1:3)=xp1;
 s=(size(vertex_newcoord_down,1)-1); %meno uno perch� l'ultimo che rimarr� non sar� da controllare
for j=1:s 
    [~,index]=min(vertex_newcoord_down(:,1)); %trova quello con la coord x minore
    polig_poly(v).coord(end+1)=vertex_newcoord_down(index,4); %salvo la coordinata come secondo punto 
    %devo ordinarli anche vertex_newcoord perch�
    %servir� fuori per disegnarli con fill
    vertex_newcoord(end+1,1:3)=vertex_newcoord_down(index,1:3);
     %devo levare il punto dal vettore
     vertex_newcoord_down(index,:)=[];    
end %chiude j
%inserisco l'ultimo rimasto in polig
if ~(isempty(vertex_newcoord_down))
    polig_poly(v).coord(end+1)=vertex_newcoord_down(1,4); 
    vertex_newcoord(end+1,1:3)=vertex_newcoord_down(1,1:3);
end
%ora bisogna fare la stessa cosa con up ricordarno per� ora di salvare i
%nodi in polig_poli al contrario perch� quello con la coordinata x minore
%sar� quello che chiude il poligono
s=(size(vertex_newcoord_up,1)-1); %meno uno perch� l'ultimo che rimarr� non sar� da controllare
for j=1:s 
    [~,index]=min(vertex_newcoord_up(:,1)); %trova quello con la coord x minore
    polig_poly(v).coord(k-j+1)=vertex_newcoord_up(index,4); %salvo la coordinata come secondo punto 
    vertex_newcoord(k-j+1,1:3)=vertex_newcoord_up(index,1:3);
     %devo levare il punto dai vettori
     vertex_newcoord_up(index,:)=[];    
end %chiude j
%inserisco l'ultimo rimasto in polig
if ~(isempty(vertex_newcoord_up))
    polig_poly(v).coord(k-s)=vertex_newcoord_up(1,4);
    vertex_newcoord(k-s,1:3)=vertex_newcoord_up(1,1:3);
end

end

