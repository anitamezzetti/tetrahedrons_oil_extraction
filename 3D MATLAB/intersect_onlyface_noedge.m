function [num_intersect ] = intersect_onlyface_noedge(n, i,j,num_edge_poly ,edge_face,a,b,num_dim, t,w,num_intersect,num_neighbour)

    global node;
    global points;
    global poly;
    global face;
    global toll;
    global intersect_tetr;
    global poly_share_face;
    toll=10^-14;

    if t(w)==inf %paralleli lato poligono e faccia tetraedro
        %se lato poligono parallelo faccia non ho intersezione
        %con lato del tetraedro solo se è tutto dentro o tutto
        %esterno la faccia, quindi controllo che entrambi i vertici del
        %lato siano interni alla faccia e non sul bordo
        
        %area della faccia
        area_face=norm(cross([node(face(j,2),:)-node(face(j,1),:)],[node(face(j,3),:)-node(face(j,1),:)]))/2;

        %X1 è il primo vertice del lato del poligono, X2 il
        %secondo
        X1=points(poly(i,b(w)),:);
        X2=points(poly(i,b(w+1)),:); 
        %calcolo le aree per vedere se sono interni
        for g=1:num_dim
               AX1B(g)=norm(cross([node(face(j,g),:)-X1],[node(face(j,a(g+1)),:)-X1]))/2;
               AX2B(g)=norm(cross([node(face(j,g),:)-X2],[node(face(j,a(g+1)),:)-X2]))/2;     
        end
        X12=[X1;X2];
        aree=[sum(AX1B),sum(AX2B)];
        
        for x=1:2 %scorro i due vertici del lato del poligono
            if abs(aree(x)-area_face)<=toll %vertice interno e controllo che non siano sul bordo

                boundery=0; %è sul bordo?
                for l=1:num_dim %scorro i lati della faccia
                    if abs(cross(node(face(j,a(l)),:)-node(face(j,a(l+1)),:),node(face(j,a(l)),:)-X12(x,:)))<=toll
                    boundery=1;
                    end
                 end %chiudo scorro i lati della faccia con l
                if boundery==0 %non è sul bordo
                    %tetraedri che condividono quella faccia: poly_share_face
                    [line_insert,p,num_intersect] = insert_only_tetra(i,p,poly_share_face(j,1),num_intersect,num_neighbour);

                    %controllo se quella faccia è già stata inserita per quel
                    %tetraedro
                    flag=0;
                    for g=1:size(intersect_tetr(i).array(line_insert).intersect_face,2)
                        if intersect_tetr(i).array(line_insert).intersect_face(g)==j
                            flag=g; %dove ha trovato la faccia, anche se l'ha già inserita la reinserisce allo stesso posto per evitare ulteriori controlli
                        end
                    end
                    if flag==0 %faccia non trovata
                        flag=size(intersect_tetr(i).array(line_insert).intersect_face,2)+1; %primo posto libero 
                    end
                    [line_node1] = add_node(X12(x,:));
                    intersect_tetr(i).array(line_insert).intersect_face(flag).coord(end+1)= line_node1;
                    intersect_tetr(i).array(line_insert).intersect_face(flag).num_face=j;

                    if poly_share_face(j,2)~=-1 %poly_share_face contiene i tetra che condividono una certa faccia
                        [line_insert,p,num_intersect] = insert_only_tetra(i,p,poly_share_face(j,2),num_intersect,num_neighbour);

                        %controllo se quella faccia è già stata inserita per quel
                        %tetraedro
                        flag=0;
                        for g=1:size(intersect_tetr(i).array(line_insert).intersect_face,2)
                            if intersect_tetr(i).array(line_insert).intersect_face(g)==j
                                flag=g;
                            end
                        end
                        if flag==0 %faccia non trovata
                            flag=size(intersect_tetr(i).array(line_insert).intersect_face,2)+1; %primo posto libero
                        end
                        intersect_tetr(i).array(line_insert).intersect_face(flag).coord(end+1)= line_node1;
                        intersect_tetr(i).array(line_insert).intersect_face(flag).num_face=j;
                    end
                end   %chiude boundery
            end %punto interno o sul bordo
        end %chiude for x
    else %lato poly non parallelo piano faccia

        if t(w)>=-toll &&  t(w)<=1+toll  

            %controllo se punto interno faccia con l'area
            X=points(poly(i,b(w)),:)+t(w)*(points(poly(i,b(w+1)),:)-points(poly(i,b(w)),:));
            %però non deve essere sul bordo perchè a me interessa solo che
            %sia interna alla faccia
            boundery=0;
            for l=1:num_dim %scorro i lati della faccia
                if abs(cross(node(face(j,a(l)),:)-node(face(j,a(l+1)),:),node(face(j,a(l)),:)-X))<=toll
                    boundery=1;
                end
             end %chiudo scorro i lati della faccia con l
             
             if boundery==0 %il punto di interseione non è sul bordo perchè se è sul bordo non voglio nulla
                area_face=norm(cross([node(face(j,2),:)-node(face(j,1),:)],[node(face(j,3),:)-node(face(j,1),:)]))/2;                     
                for g=1:num_dim %area col punto
                   AXB(g)=norm(cross([node(face(j,g),:)-X],[node(face(j,a(g+1)),:)-X]))/2;
                end

                if abs(sum(AXB)-area_face)<=toll %lato poly interno e salvo le cordinate
                    [line_insert,num_intersect] = insert_only_tetra(i,poly_share_face(j,1),num_intersect,num_neighbour);

                    %controllo se quella faccia è già stata inserita per quel
                    %tetraedro
                    flag1=0;
                    for g=1:size(intersect_tetr(i).array(line_insert).intersect_face,2)
                        if isequal(intersect_tetr(i).array(line_insert).intersect_face(g),j)
                            flag1=g;
                        end
                    end

                    if flag1==0 %faccia non trovata
                        Y=intersect_tetr(i).array(line_insert).intersect_face.num_face;
                        if norm(Y,Inf)>0 %c'è già almeno un numero se la norma infinito del vettore è maggiore di zero
                            flag=size(intersect_tetr(i).array(line_insert).intersect_face,2)+1; %primo posto libero
                        else
                            flag=1;
                        end
                        %inizializzo la nuova faccia
                        intersect_tetr(i).array(line_insert).intersect_face(flag).coord=[];
                        intersect_tetr(i).array(line_insert).intersect_face(flag).num_face=[];
                    end
                    [line_node] = add_node(X);
                    intersect_tetr(i).array(line_insert).intersect_face(flag).coord(end+1)= line_node;
                    intersect_tetr(i).array(line_insert).intersect_face(flag).num_face=j;

                    if poly_share_face(j,2)~=-1
                        %controllo se quella faccia è già stata inserita per quel
                        %tetraedro
                        flag=0;
                        for g=1:size(intersect_tetr(i).array(line_insert).intersect_face,2)
                            if isequal(intersect_tetr(i).array(line_insert).intersect_face(g),j)
                                flag=g;
                            end
                        end

                        if flag==0 %faccia non trovata
                            [line_insert,num_intersect] = insert_only_tetra(i,poly_share_face(j,2),num_intersect,num_neighbour);
                            if isnumeric(intersect_tetr(i).array(line_insert).intersect_face)==0
                                flag=1; %se non ha ancora inserito nulla il primo posto libero è uno
                            else
                                flag=size(intersect_tetr(i).array(line_insert).intersect_face,2)+1; %primo posto libero
                            end
                        end
                        intersect_tetr(i).array(line_insert).intersect_face(flag).num_face=j;
                        intersect_tetr(i).array(line_insert).intersect_face(flag).coord(end+1)= line_node;
                    end


                end %if punto interno
             end %chiude boundery
        end %t(w) fra 0 e 1
    end %end t)w) numerico o no
end

