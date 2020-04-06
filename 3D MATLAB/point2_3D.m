function [] = point2_3D(i,num_intersect,num_vertex,num_ele)

global ele;
global touch;
global intersect_tetr;
global edge;

for m=1:1:num_intersect
        intersect_tetr(i).array(m).share(1).share_num_tetr=[]; 
        intersect_tetr(i).array(m).share(1).share_nodes_tetr=[]; 
        intersect_tetr(i).array(m).share(1).share_edge_tetr=[];
       
        %scorro i vertici del tretraedro
        for j=1:num_vertex 
            for k=1:num_ele %scorro tutti i tetraedri
                if k~=intersect_tetr(i).array(m).num_tetr %non è lo stesso tetraedro
                    if ele(intersect_tetr(i).array(m).num_tetr,j)==ele(k,1) ||...
                            ele(intersect_tetr(i).array(m).num_tetr,j)==ele(k,2) ||...
                            ele(intersect_tetr(i).array(m).num_tetr,j)==ele(k,3) ||...
                            ele(intersect_tetr(i).array(m).num_tetr,j)==ele(k,4) %uno dei 4 vertici del  k ugauli
                        
                        if isempty(intersect_tetr(i).array(m).share(1).share_num_tetr) %non ho elemtenti in share tetr
                            intersect_tetr(i).array(m).share(1).share_num_tetr=k;
                            intersect_tetr(i).array(m).share(1).share_nodes_tetr(1)=ele(intersect_tetr(i).array(m).num_tetr,j);
                        else
                            %cerco se tretraedro già presente
                            flag=0; %flag diventa 1 se il tetra k lo trova già
                            for z=1:size(intersect_tetr(i).array(m).share,2) %z scorre i tringoli gia inseriti
                                if k==intersect_tetr(i).array(m).share(z).share_num_tetr %triangolo k già presente alla posizione z
                                    intersect_tetr(i).array(m).share(z).share_nodes_tetr(end+1)=ele(intersect_tetr(i).array(m).num_tetr,j); %nodo j in comune
                                    flag=1;
                                end
                            end
                            if flag==0 %triangolo non trovato
                                intersect_tetr(i).array(m).share(end+1).share_num_tetr=k;
                                intersect_tetr(i).array(m).share(end).share_nodes_tetr=ele(intersect_tetr(i).array(m).num_tetr,j);
                            end
                        end
                    end
                end
            end
        end %scorro i vertici
        
        a=[1 2 3 4 1 2];
        %scorro i lati del tretraedro
        for j=1:num_vertex-1
            %l va dal numero dopo j a num vertex per trovare tutti i lati
            %possibili
            for l=(j+1):num_vertex
                %lato che collega il vertice j e quello dopo
%                 touch(ele(intersect_tetr(i).array(m).num_tetr,j)).elenco_edge;
%                 touch(ele(intersect_tetr(i).array(m).num_tetr,l)).elenco_edge;
                edge_tetra=intersect(touch(ele(intersect_tetr(i).array(m).num_tetr,j)).elenco_edge,touch(ele(intersect_tetr(i).array(m).num_tetr,l)).elenco_edge);

                for k=1:num_ele %scorro tutti i tetraedri    
                    if k~=intersect_tetr(i).array(m).num_tetr %non è lo stesso tetraedro
                        %controllo se quel tetraedro condivide quel lato
                        %find(a==b) mi restituisce zero(empty) se non trova l'elemento b in a,
                        %altrimenti mi restituisce la posizione in cui lo trova
                      
                        if isempty(find(ele(k,:)==ele(intersect_tetr(i).array(m).num_tetr,j)))==0 && ...
                                isempty(find(ele(k,:)==ele(intersect_tetr(i).array(m).num_tetr,l)))==0 %li trova entrambi 
                            %il tetraedro k condivide con il tetraedro tagliato m
                            %il latoedge_tetra. lo inserisco
                            if isempty(intersect_tetr(i).array(m).share(1).share_num_tetr) %non ho elemtenti in share tetr
                                intersect_tetr(i).array(m).share(1).share_num_tetr=k;
                                intersect_tetr(i).array(m).share(1).share_edge_tetr=edge_tetra;
                            else
                                %cerco se tretraedro già presente
                                flag=0; %flag diventa 1 se il tetra k lo trova già
                                for z=1:size(intersect_tetr(i).array(m).share,2) %z scorre i tringoli gia inseriti
                                    if k==intersect_tetr(i).array(m).share(z).share_num_tetr %triangolo k già presente alla posizione z
                                        intersect_tetr(i).array(m).share(z).share_edge_tetr(end+1)=edge_tetra;
                                        flag=1;
                                    end
                                end
                                if flag==0 %triangolo non trovato
                                    intersect_tetr(i).array(m).share(end+1).share_num_tetr=k;
                                    intersect_tetr(i).array(m).share(end).share_edge_tetr=edge_tetra;
                                end
                            end
                        end
                    end
                end  %scorro tetra
            end
        end
        
end


end

