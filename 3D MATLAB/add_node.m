function [ line_node ] = add_node( X )
%controlla che il nodo non sia già stato inserito. se è nuovo lo aggiunge a
%node e retituisce la posizione in cui l'ha aggiunto. altrimenbti
%restituisce dove l0ha trovato
    global total_node;
    global node;
    global toll

    found=0;
    for  y=1:total_node
         if abs(node(y,:)-X)<toll %  non preciso isequal(node(y,:),X)==1
                line_node=y; %non è da inserire
                found=1;
                break;
         end  
    end
    if found==0
        total_node=total_node+1;
        node(total_node,:)=X; %aggiorno node
        line_node=total_node;
    end    
end

