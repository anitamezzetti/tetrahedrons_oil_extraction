function [p] = Insert(j,i,p,x1,x2)
%Questa funzione inserisce nella struttura intersect i triangoli tagliati e
%le relative coordinate curvilinee di intersezone con la traccia

    global edge;
    global intersect_triangle;
    global touch;
    global toll;
    
    b=intersect(touch(edge(j,1)).elenco_tri,touch(edge(j,2)).elenco_tri); %abbiamo salvato la variabile intersect perchè dovendola 
    size_b=size(b); %numero dei triangoli che condividono il lato edge(j)
    %riusare due volte, il costo computazionale di salvare una
    %variabile di al massimo due elementi è minore che fare due
    %volte una intersect
    if p==1
       p=p+size_b(2);
       for v=1:1:size_b(2) %primo o primi due triangoli inseriti
           intersect_triangle(i).array(v).num_tri=b(v);
           intersect_triangle(i).array(v).coord(1)=x2;
           intersect_triangle(i).array(v).intersect_edge=-1;
           if x1>toll && x1<1-toll
               intersect_triangle(i).array(v).intersect_edge=j;                            
           end
               
       end
    else
        for z=1:1:size_b(2) %controlla trinagolo per triangolo i due triangoli
            %t c'è gia, è x2
            flag=0;
            for v=1:1:p-1 %essendo p>1 p non rischia di essere 0. 
            %il for di v controlla che il triangolo non sia già presente
                if intersect_triangle(i).array(v).num_tri==b(z)
                    %non rinseriamo il triangolo già presente,
                    %dobbiamo mettere nella struttura interset la
                    %coordinata curvilinea t
                    intersect_triangle(i).array(v).coord(end+1)=x2;
                    if x1>toll && x1<1-toll
                        if intersect_triangle(i).array(v).intersect_edge(end)==-1;
                            intersect_triangle(i).array(v).intersect_edge(end)=j;      
                        else
                            intersect_triangle(i).array(v).intersect_edge(end+1)=j;
                        end
                        
                    end
                    flag=1;
                end
            end
            if flag==0 %inserisco il nuovo triangolo
                intersect_triangle(i).array(p).num_tri=b(z);
                intersect_triangle(i).array(p).coord(1)=x2;
                intersect_triangle(i).array(p).intersect_edge=-1;
                if x1>toll && x1<1-toll
                       intersect_triangle(i).array(p).intersect_edge=j;                            
                end
                p=p+1; 
            end
        end
    end
end