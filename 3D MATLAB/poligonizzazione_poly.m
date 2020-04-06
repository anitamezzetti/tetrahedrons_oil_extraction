function [ polig_poly, M ,color ] = poligonizzazione_poly( i, num_intersect, n , num_points, num_vertex, num_edge_poly)

    global node;
    global points;
    global poly;
    global intersect_tetr;

    v1=points(poly(i,2),:)-points(poly(i,1),:);
    v2=cross(v1,n);
    %nuova base: v1 v2 n
    M=[v1' v2' n'];
    

    %new_points:coord dei vertici proiettati
    for k=1:num_points
        bb=points(k,:)';
        new_points(k,:)=[M\bb]';
    end %k
    new_points=new_points(:,1:2); %taglia gli zeri della terza coordinata

    %disegno il poligono
    figure(2)
    for k=1:num_vertex
        x(k)=new_points(poly(i,k),1);
        y(k)=new_points(poly(i,k),2);
    end
    
    color=rand(1,3);
    axis equal
    axis([-3 3 -3 3])
    title('divisione frattura')
    fill(x,y,color, 'FaceAlpha', 0.4)

    for v=1:num_intersect %scorre i tetraedri intersecati
        u=0;
        o=0;
        tot_intersection=0;
        polig_poly(v).num_tetra=[];
        polig_poly(v).coord=[];
        %ogni tetraedro questo vettore verrà svuotato perchè è
        %solo di appoggio, contiene nelle prime tre posizioni le coordinate
        %cartesiane dei punti e nella quarta posizione il numero del
        %nodo(mi servono nello stesso vettore per dopo quando devo
        %ordinarli)
        
        vertex_newcoord=[];
        for l=1:size(intersect_tetr(i).array(v).intersect_edge,2) %scorre i lati tagliati per quel tetraedro

            %per ogni intersecato ho  vertici intersecati sui lati e quelli
            %intersecati sulle facce: li salvo in vertex_newcoord
            %bisogna controllare prima che intersect edge non sia vuoto per
            %quel tetraedro 
            if ~(isempty(intersect_tetr(i).array(v).intersect_edge(l).coord)) && ~(isempty(intersect_tetr(i).array(v).num_tetr))
                for o=1:size(intersect_tetr(i).array(v).intersect_edge(l).coord,2)
                    %salvo il valore del nodo in vertec_intersect per sapere poi a quali punto si 
                    %riferiscono le coordinate ruotate in vertex_newcoord e ruoto direttamente le cordinate nel
                    %nuovo sistema di riferimento
                    vertex_newcoord(tot_intersection+o,4)=intersect_tetr(i).array(v).intersect_edge(l).coord(o);
                    bb=node(vertex_newcoord(tot_intersection+o,4),:)';
                    vertex_newcoord(tot_intersection+o,1:3)=[M\bb]';
                end %chiude o
            end %chiude if empty ~
            tot_intersection=tot_intersection+o;
        end %chiude l
        tot_intersection=size(vertex_newcoord,1);
        for l=1:size(intersect_tetr(i).array(v).intersect_face,2) %scorre le facce tagliate per quel tetraedro
                %controllo prima che non sia vuoto
                if ~(isempty(intersect_tetr(i).array(v).intersect_face(l).coord)) %se non è vuoto entra
                    for u=1:size(intersect_tetr(i).array(v).intersect_face(l).coord,2)
                        %uguale a prima
                        yy=intersect_tetr(i).array(v).intersect_face(l).coord(u);
                        vertex_newcoord(tot_intersection+u,4)=yy;
                        bb=node(vertex_newcoord(tot_intersection+u,4),:)';
                        vertex_newcoord(u+tot_intersection,1:3)=[M\bb];
                    end %chiude u
                end %chiude if empty ~
                tot_intersection=tot_intersection+u;
        end %chiude l
        %inserisco i punti di intersect_vertex_poly se ci sono
        if ~isempty(intersect_tetr(i).array(v).intersect_vertex_poly)
            for l=1:size(intersect_tetr(i).array(v).intersect_vertex_poly,2)
                vertex_newcoord(tot_intersection+l,4)=intersect_tetr(i).array(v).intersect_vertex_poly(l);
                vertex_newcoord(tot_intersection+l,1:3)=node(intersect_tetr(i).array(v).intersect_vertex_poly(l),:);
                bb=node(vertex_newcoord(tot_intersection+1,4),:)';
                vertex_newcoord(tot_intersection+1,1:3)=[M\bb];
            end
        end
        %tolgo i doppi
        vertex_newcoord=unique(vertex_newcoord,'rows');
        tot_intersection=size(vertex_newcoord,1);
       
        %se i punti sono più di tre devono essere ordinati
        if tot_intersection>3
            [polig_poly ,vertex_newcoord] = ordering_vertex( i,tot_intersection,v,intersect_tetr(i).array(v).num_tetr,vertex_newcoord,polig_poly ); 
        elseif tot_intersection==3 %altrimenti si inseriscono direttamente nella struttura della poligonazione
            polig_poly(v).num_tetra=intersect_tetr(i).array(v).num_tetr;
            polig_poly(v).coord(1:size(vertex_newcoord,1))=vertex_newcoord(:,4); %vengono messi a caso non in senso antiorario
            
        end %se sono due o uno berrone non vuole che li consideriamo neanche come segmenti
        
        
        %disegno
        
        hold all
        %scrivo i numeri
        for y=1:num_edge_poly
            figure(2);text(new_points(y,1),new_points(y,2), cellstr(num2str(poly(i,y))) , 'Fontsize',15 );
        end
        
        %coloro
        if size(polig_poly(v).coord,2)>=3
            color(v,:)=rand(1,3);
            figure(2);fill(vertex_newcoord(:,1),vertex_newcoord(:,2) , color(v,:));
            X=[];
            Y=[];
            Z=[];
            for d=1:size(polig_poly(v).coord,2)
                X(d) = node(polig_poly(v).coord(d),1);
                Y(d) = node(polig_poly(v).coord(d),2);
                Z(d) = node(polig_poly(v).coord(d),3);
            end
            figure(1);fill3(X,Y,Z,color(v,:));
        elseif size(polig_poly(v).coord,2)==2
            color=rand(1,3);
            %disegno in figura 1
            %edge=polig_poly(v).coord
            p3 = node(polig_poly(v).coord(1), :);
            p4 = node(polig_poly(v).coord(2), :);
            figure(1);drawCylinder([p3 p4 .05], 'FaceColor', color(v,:));
            figure(2);plot (vertex_newcoord(:,1),vertex_newcoord(:,2),'LineWidth',6,'MarkerEdgeColor', color);
        end

        for y=1:size(polig_poly(v).coord,2)
            figure(2);text(vertex_newcoord(y,1),vertex_newcoord(y,2), cellstr(num2str(polig_poly(v).coord(y))),  'Fontsize',15 );
        end

    end %v che scorre num intersect

end

