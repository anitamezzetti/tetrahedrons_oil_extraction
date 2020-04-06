function [flag] = check_node(index,j,n,i, num_edge)
    %funzione che ricevendo il nodo che non è traccia e il lato in considerazione
    %(j) ricerca i due triangoli che hanno quel lato in comune (1 o 2),
    %troviamo i due vertici dei triangoli che non appartengono al lato,
    %epoi vediamo con scalar se quei triangoli sono tagliati (o entrambi o
    %uno o nessuno);
    
    global edge;
    global toll;
    global touch;
    global ele;
    global node;
    
    %j è la riga di edge e nodeontrace è il vertice sulla traccia
    %cerchiamo i due triangoli che hanno quel lato j in comune
    common=intersect(touch(edge(j,1)).elenco_tri,touch(edge(j,2)).elenco_tri); 
    num_common=size(common); %num_common è il numero di triangoli in comune col lato j
    num_common=num_common(2);
    flag=-ones(1,num_common);
    node_on_trace=setdiff(edge(j,:),edge(j,index)); %numero del nodo sulla traccia
    
    %scorro i triangoli che hanno quel lato in comune (1 o 2)
    for k=1:1:num_common
        %scorro tutti i vertici del triangolo e controllo quale non sia
        %uguale ad uno dei due vertici del lato
        f=setdiff(ele(common(k),:),edge(j,:));
        %f contiene il vertice del triangolo i che non appartiene al lato
        %edge(j);
%         for k=1:1:3
%             if edge(j,1)~=ele(common(i),k) && edge(j,2)~=ele(common(i),k)
%                 f=ele(common(i),k);
%                 break; %esco dal for k
%             end
%         end
        
        %troviamo il lato h che ha come estremi f e edge(j,index);
        for m=1:num_edge
            if isequal(edge(m,:),[f,edge(j,index)])==1 || isequal(edge(m,:),[edge(j,index),f])==1
                %quando esce m contiene la riga del lato che unisce f e
                %edge(j, index)
                break;
            end
        end
        [s1,s2]=scalar(i,m,n);
        
        if s1*s2<-toll
            flag(k)=common(k); %flag contiene il numero del triangolo che sappiamo essere tagliato;
        
        end
    end
end

