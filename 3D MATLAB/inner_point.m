function [ flag ] = inner_point( i, num_edge_poly,area_poly, X ,n)
%funzione che dato il poligono e un punto mi dice se quel punto è interno
%al poligono
%output=flag 1 se interno o sul bordo, 0 se esterno, -1 se non è sul piano

    global points;
    global poly;
    global toll;
    
     for g=1:(num_edge_poly-1)
           AXB(g)=norm(cross([points(poly(i,g),:)-X],[points(poly(i,g+1),:)-X]))/2;
     end
     AXB(g+1)=norm(cross([points(poly(i,g+1),:)-X],[points(poly(i,1),:)-X]))/2;
     %controlla che le due aree siano uguali
     flag=-1;
     
     %punto sul piano ma esterno
     if abs(dot(n,(X-points(poly(i,1),:))))<toll
         flag=0;
     end
     
     %punto interno al poligono
     if abs(sum(AXB)-sum(area_poly))<=toll
            flag=1;
     end
     

end

