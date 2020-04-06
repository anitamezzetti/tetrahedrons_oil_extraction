function [ ] = Show_sottotri( num_edge,i,num_intersected )
%Stampa la sottotriangolazione

global node;
global intersect_triangle;

clf
Show(num_edge,i)
title('Sottotriangolazione generata dalla intersezione della traccia','Color','b')
for m=1:1:num_intersected
    num_tri=size(intersect_triangle(i).array(m).tri);
    num_tri=num_tri(2);
    for f=1:1:num_tri
        hold all
        plot([node(intersect_triangle(i).array(m).tri(f).vert_tri(1),1),node(intersect_triangle(i).array(m).tri(f).vert_tri(2),1)],[node(intersect_triangle(i).array(m).tri(f).vert_tri(1),2),node(intersect_triangle(i).array(m).tri(f).vert_tri(2),2)],'pb--','linewidth',2);
        plot([node(intersect_triangle(i).array(m).tri(f).vert_tri(1),1),node(intersect_triangle(i).array(m).tri(f).vert_tri(3),1)],[node(intersect_triangle(i).array(m).tri(f).vert_tri(1),2),node(intersect_triangle(i).array(m).tri(f).vert_tri(3),2)],'pb--','linewidth',2);
        plot([node(intersect_triangle(i).array(m).tri(f).vert_tri(2),1),node(intersect_triangle(i).array(m).tri(f).vert_tri(3),1)],[node(intersect_triangle(i).array(m).tri(f).vert_tri(2),2),node(intersect_triangle(i).array(m).tri(f).vert_tri(3),2)],'pb--','linewidth',2);
    end
end
end

