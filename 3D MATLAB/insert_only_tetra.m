function [line_insert,num_intersect] = insert_only_tetra(i,numb_tetra,num_intersect,num_neighbour)
%questa funzione è un supplemento di insert_tetra perchè nesessitiamo a
%volte di inserire solo il tetraedro nella struttura intersect e di
%inserirli in tetra_tail, ma non partendo da una faccia, avendo invece già
%il numero del tetraedro da inserire

    global intersect_tetr;
    global neigh;
    global tetra_tail;
    global poly_share_face;
    
    %---------------------inserimento in coda---------------
    %inserimento tetraedri nella coda da controllare
    %prima controllo che non ci siano già se p non è 1
    if isempty(tetra_tail) %p==1 %primo inseriento coda vuota
        tetra_tail(1)=numb_tetra; %tetra_tail(p)=numb_tetra; 
    else %devo controllare che i tetraedri non ci siano già
        found1=0;
        for h=1:size(tetra_tail,2)  %p-1
            if tetra_tail(h)==numb_tetra
               found1=1; %primo tetraedro già presente non è da inserire
               break;
            end
        end
        if found1==0 %non lo ha trovato quindi è da inserire
           tetra_tail(end+1)=numb_tetra; %tetra_tail(p)=numb_tetra;
        end
    end
    
    
    %---------------------inserimento vicini in coda---------------
    %da inserire in coda anche i tetraedri vicini ai due/uno inseriti
    for x=1:num_neighbour %scorro i vicini del tetraedro
       if neigh(numb_tetra,x)~=-1 %se quel vicino è un vero tetraedro o è sul bordo
           found3=0; %tetraedro vicino già trovato in coda se vale 1
           for h=1:size(tetra_tail,2)  %scorro i tetraedri nella coda
               if tetra_tail(h)==neigh(numb_tetra,x)
                   found3=1;
               end
           end
           if found3==0 %non lo ha trovato è da inserire
               tetra_tail(end+1)=neigh(numb_tetra,x);
           end
       end
    end
    %------------inserimento tetraedri tagliati nella struttura finale------
 
    %ora devo inserire i tetraedri che condividono la faccia tagliata che ho
    %trovato
    flag=0;
    %controllo che quei tetraedri non siano già presenti
    
    for m=1:num_intersect
        if num_intersect<=size(intersect_tetr(i).array,2)
            if isequal(intersect_tetr(i).array(m).num_tetr,numb_tetra)
                line_insert=m; %casella in cui andare a aggiornare i dati se il tetraedro è già presente
                flag=1;
                break;
            end
        end
    end
    if flag==0
        %non l'ha trovato e deve inseriro in una nuova posizione
        num_intersect=num_intersect+1;
        line_insert=num_intersect;
        intersect_tetr(i).array(num_intersect).num_tetr=numb_tetra;
        %ogni volta che metti un nuovo tetra inizializza edge
        intersect_tetr(i).array(line_insert).intersect_edge.num_edge=[];
        intersect_tetr(i).array(line_insert).intersect_edge.coord=[];
        intersect_tetr(i).array(line_insert).intersect_face.num_face=[];
        intersect_tetr(i).array(line_insert).intersect_face.coord=[];
    end
end

