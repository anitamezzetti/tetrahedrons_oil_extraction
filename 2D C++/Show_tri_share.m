function [ ] = Show_tri_share( num_edge,i,num_intersected )
%Mostra i triangoli che hanno in comune almeno un vertice con triangoli
%tagliati dalla traccia

global node;
global ele;
global intersect_triangle;

clf
Show(num_edge,i)
title('Triangoli con un vertice in comune con triangoli intersecati dalla traccia','Color',[0 0.5 0.5])
for m=1:1:num_intersected
    num_share=size(intersect_triangle(i).array(m).share);
    num_share=num_share(2);
    for f=1:1:num_share
        hold all
        plot([node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,1),1),node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,2),1)],[node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,1),2),node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,2),2)],'p--','Color',[0 0.5 0.5],'linewidth',2);
        plot([node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,1),1),node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,3),1)],[node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,1),2),node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,3),2)],'p--','Color',[0 0.5 0.5],'linewidth',2);
        plot([node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,2),1),node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,3),1)],[node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,2),2),node(ele(intersect_triangle(i).array(m).share(f).share_num_tri,3),2)],'p--','Color',[0 0.5 0.5],'linewidth',2);
    end

end

end

