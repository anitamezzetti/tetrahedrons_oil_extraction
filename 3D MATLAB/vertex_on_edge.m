function [ vertexonedge ] = vertex_on_edge( poly, num_edge_poly, edge )
%funzione che verifica se i vertici poly siano interni a edge
%output: una flag vertex on edge che vale 0 se nessun vertice del poligono
%appartiene al lato, il lato del poli se si
    global node;
    global edge;
    global points;
    global poly;
    global toll;

    vertexonedge=-1;
    vertex_edge=-1;
    
    %ciclo che scorre i vertici della traccia
    for k=1:num_edge_poly
        %per ogni vertice ci chiediamo se appartiene alla retta
        %passante per quel lato. per far questo il prodotto
        %vettoriale fra il veertice-edge(j,1) e
        %vertice-edge(j,2) deve essere nullo
        
        prod_vett=cross((points(poly(k),:)-node(edge(1),:)),(points(poly(k),:)-node(edge(2),:)));
       
        %se prod_vett diverso da zero quel vertice non
        %appartiene sicuro al lato, se vale zero vedo con
        %t(coordinata parametrica di dove cade il vertice del
        %poligono rispetto al lato) se il vertice è interno al
        %lato

        if abs(prod_vett)<toll
            t=(points(poly(k),:)-node(edge(1),:))/(node(edge(2),:)-node(edge(1),:));
            if t>-toll && t<1+toll
                vertexonedge=num_edge_poly; %vertie poligono interno                
            end     

        end
    end

end

