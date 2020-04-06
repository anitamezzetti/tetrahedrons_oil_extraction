function [ ] = Show_tri_intersect( num_edge,i,num_intersected )
%Mostra i lati dei triangoli intersecati

global node;
global ele;
global intersect_triangle;

clf
Show(num_edge,i)
title('Triangoli intersecati dalla traccia','Color','b')
for f=1:num_intersected
    hold all
    plot([node(ele(intersect_triangle(i).array(f).num_tri,1),1),node(ele(intersect_triangle(i).array(f).num_tri,2),1)],[node(ele(intersect_triangle(i).array(f).num_tri,1),2),node(ele(intersect_triangle(i).array(f).num_tri,2),2)],'pb--','linewidth',2);
    plot([node(ele(intersect_triangle(i).array(f).num_tri,1),1),node(ele(intersect_triangle(i).array(f).num_tri,3),1)],[node(ele(intersect_triangle(i).array(f).num_tri,1),2),node(ele(intersect_triangle(i).array(f).num_tri,3),2)],'pb--','linewidth',2);
    plot([node(ele(intersect_triangle(i).array(f).num_tri,2),1),node(ele(intersect_triangle(i).array(f).num_tri,3),1)],[node(ele(intersect_triangle(i).array(f).num_tri,2),2),node(ele(intersect_triangle(i).array(f).num_tri,3),2)],'pb--','linewidth',2);
end

end

