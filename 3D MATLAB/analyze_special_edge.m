function [] = analyze_special_edge( i, num_intersect, special_edge, a)
% funzione che mi analizza tutti i nodi presenti in special edge. inserisce
% ogni nodo in tutti i tetraedri in intersect_tetra, quindi già tagliati, che lo possiedono come
% vertice.

global ele;
global touch;
global intersect_tetr;

for w=1:size(special_edge,2)
            
    %cerco i tetra che condividono quel vertice
    share_tetra=touch(special_edge(w)).elenco_tetra;

    for t=1:num_intersect
        if find(intersect_tetr(i).array(t).num_tetr==share_tetra)~=0 %il vertice special_edge(w) è nel tetradro t di intersect_tetra
            %cerco un lato del tetradro che ha quel vertice (uno
            %solo!)
            position=find(ele(intersect_tetr(i).array(t).num_tetr,:)==special_edge(w));
            %position mi da la posizione del vertice
            %special_edge(w) in ele. trovo il lato che lo collega
            %con il vertice alla posizione position+1
            if ~isempty(position) %se l'ha trovato in quel tetra

                eedge=intersect(touch(special_edge(w)).elenco_edge,touch(ele(intersect_tetr(i).array(t).num_tetr,a(position+1))).elenco_edge);

                %cerco se quel lato è già stato inserito per quel
                %tetra
                edge_already_intersect=0;% verifica che quel lato sià già presente
                v=1; %contatore della lunghezza di intersect_tetr(i).array(line_insert(m)).intersect_edge.num_edge
                if intersect_tetr(i).array(t).intersect_edge(1).num_edge>0 %non è il primo lato
                    while (intersect_tetr(i).array(t).intersect_edge(v).num_edge>0) %faccio un ciclo while perchè è una struct e non posso usare size del vettore
                        if intersect_tetr(i).array(t).intersect_edge(v).num_edge==eedge
                            %lato già presente alla posizione v qundi esco dal while   
                            edge_already_intersect=1;
                            break;
                        end
                        v=v+1;
                    end %while
                    if edge_already_intersect==0 %devo aggiungere quel lato
                        intersect_tetr(i).array(t).intersect_edge(v).num_edge=eedge;  
                        intersect_tetr(i).array(t).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                        intersect_tetr(i).array(t).intersect_edge(v+1).coord=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                    end 
                else %è il primo lato, v resta 1
                    intersect_tetr(i).array(t).intersect_edge(v).num_edge=eedge;  
                    intersect_tetr(i).array(t).intersect_edge(v+1).num_edge=[]; %aggiorno a vuoto a riga dopo così poi non mi da errori il while
                    intersect_tetr(i).array(t).intersect_edge(v+1).coord=[]; 
                end
                intersect_tetr(i).array(t).intersect_edge(v).coord(end+1)=special_edge(w);
            end %isempty
        end %if find
    end % t 
end %for w


end

