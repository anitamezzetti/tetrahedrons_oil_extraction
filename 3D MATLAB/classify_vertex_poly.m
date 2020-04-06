function [] = classify_vertex_poly( i,num_intersect, num_edge_poly, num_vertex, num_dim,n, a,b )

global node;
global ele;
global points;
global poly;
global face;
global toll;
global touch;
global intersect_tetr;
global poly_share_face;
global total_node;

for tag=1:num_intersect
    intersect_tetr(i).array(tag).intersect_vertex_poly=[];
end

%ogni nodo del poligono pu� essere interno massimo a un tetraedro
%quindi controllo con un vettore di non cercarlo pi� volte
control_node_poly=zeros(1,num_edge_poly);

for tag=1:num_intersect
    %volume tetraedro
    v1=node(ele(tag,2),:)-node(ele(tag,1),:);
    v2=node(ele(tag,3),:)-node(ele(tag,1),:);
    v3=node(ele(tag,4),:)-node(ele(tag,1),:);
    vol=(1/6)*abs(dot(cross(v1,v2),v3));
    %scorro i vertici del poligono se non sono gi� stati inseriti
    %in un precedente tetraedro
    for g=1:num_edge_poly
        if control_node_poly(g)==0 %da controllare
            ab=[1 2 3 4 1 2];
            for m=1:num_vertex %volume somma tetraedri
                v1=node(ele(intersect_tetr(i).array(tag).num_tetr,ab(m)),:)-points(poly(i,g),:);
                v2=node(ele(intersect_tetr(i).array(tag).num_tetr,ab(m+1)),:)-points(poly(i,g),:);
                v3=node(ele(intersect_tetr(i).array(tag).num_tetr,ab(m+2)),:)-points(poly(i,g),:);
                vol2(m)=(1/6)*abs(dot(cross(v1,v2),v3));
            end
            vol2=sum(vol2);
            if abs(vol-vol2)<=toll %vertice interno al tetraedro
                control_node_poly(1,g)=1;
                old_node=total_node;
                [line_node]=add_node(points(poly(i,g),:));
                if old_node~=total_node %l'ha inserito come nuovo punto
                    %devo capire se si trova internamente ad una faccia
                    %trovo le facce (4 facce) del tetraedro
                    for q=1:num_vertex
                        %faccio l'intersezione fra le facce dei primi due nodi
                        %della faccia, poi interseco il risultato con le facce
                        %del terzo nodo
                        firststep=intersect(touch(ele(intersect_tetr(i).array(tag).num_tetr,a(q))).elenco_face,touch(ele(intersect_tetr(i).array(tag).num_tetr,a(q+1))).elenco_face);
                        face_tetra(q)=intersect(firststep,touch(ele(intersect_tetr(i).array(tag).num_tetr,a(q+2))).elenco_face);
                    end
                    in_face=0;
                    for f=1:num_vertex %scorro le facce del tetraedro
                        %area della faccia
                        area_face=norm(cross([node(face(face_tetra(f),2),:)-node(face(face_tetra(f),1),:)],[node(face(face_tetra(f),3),:)-node(face(face_tetra(f),1),:)]))/2;
                        %aree dei tre triangoli 
                        for h=1:num_dim
                               AXB(h)=norm(cross([node(face(face_tetra(f),h),:)-points(poly(i,g),:)],[node(face(face_tetra(f),b(h+1)),:)-points(poly(i,g),:)]))/2;  
                        end
                        area_tot=sum(AXB);
                        if abs(area_tot-area_face)<=toll %punto sulla faccia
                            %da inserire per i tetraedri che condividono quella faccia
                            %inserisco nel primo
                            in_face=1;
                            if isempty(intersect_tetr(i).array(tag).intersect_vertex_poly)
                                intersect_tetr(i).array(tag).intersect_vertex_poly(1)=line_node;
                            else 
                                intersect_tetr(i).array(tag).intersect_vertex_poly(end+1)=line_node;
                            end
                            if poly_share_face(face_tetra(f),2)~=-1 %ce n'� un altro
                                if isempty(intersect_tetr(i).array(tag).intersect_vertex_poly)
                                    intersect_tetr(i).array(tag).intersect_vertex_poly(1)=line_node;
                                else
                                    intersect_tetr(i).array(tag).intersect_vertex_poly(end+1)=line_node;
                                end
                            end
                        end

                      end %chiude f
                      
                      if in_face==0 % non appartiene a una faccia
                            %punto non sulla faccia ma comuque interno al tetraedro    
                            %inserire solo per quel tetraedro
                            if isempty(intersect_tetr(i).array(tag).intersect_vertex_poly)
                                intersect_tetr(i).array(tag).intersect_vertex_poly(1)=line_node;
                            else
                                intersect_tetr(i).array(tag).intersect_vertex_poly(end+1)=line_node;
                            end
                      end
                      
                end %chiude controllo se � un nuovo punto
            end %chiude controlli dei volumi
        end %chiude controllo se � da controllare
    end %chiude g   
end %chiude tag

end

