function [ ] = Show_poly( num_edge,i,num_intersected )
%Stampa la poligonalizzazione

global node;
global intersect_triangle;

clf
Show(num_edge,i)
title('Poligonazione generata dal taglio della traccia','Color','g')
for m=1:1:num_intersected
    num_poly=size(intersect_triangle(i).array(m).poly);
    num_poly=num_poly(2);
    for f=1:1:num_poly
        num_vert_poly=size(intersect_triangle(i).array(m).poly(f).vert_poly);
        num_vert_poly=num_vert_poly(2);
        hold all
        for k=1:1:(num_vert_poly-1)
            plot([node(intersect_triangle(i).array(m).poly(f).vert_poly(k),1),node(intersect_triangle(i).array(m).poly(f).vert_poly(k+1),1)],[node(intersect_triangle(i).array(m).poly(f).vert_poly(k),2),node(intersect_triangle(i).array(m).poly(f).vert_poly(k+1),2)],'pg--','linewidth',2);
        end
        plot([node(intersect_triangle(i).array(m).poly(f).vert_poly(num_vert_poly),1),node(intersect_triangle(i).array(m).poly(f).vert_poly(1),1)],[node(intersect_triangle(i).array(m).poly(f).vert_poly(num_vert_poly),2),node(intersect_triangle(i).array(m).poly(f).vert_poly(1),2)],'pg--','linewidth',2);
    end

end

end
