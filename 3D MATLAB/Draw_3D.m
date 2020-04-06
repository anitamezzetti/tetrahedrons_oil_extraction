function [] = Draw_3D(num_edge_poly)

    global node;
    global edge;
    global face;
    global points;
    global poly;

    view(3);
    a=drawPolyhedron(node,face);
    set(a,'facealpha',.2);
    hold on;
    axis equal;
    width = .05;
    radius = .1;

    for i = 1:size(edge, 1)
        p1 = node(edge(i, 1), :);
        p2 = node(edge(i, 2), :);
        drawCylinder([p1 p2 width], 'FaceColor', 'y');
    end
    for i = 1:size(node, 1)
        num=i;
        drawSphere([node(i, :) radius], 'FaceColor', 'b','MarkerSize',0.5);
        text(node(i,1),node(i,2),node(i,3), cellstr(num2str(num))  , 'Fontsize',24 );
    end
    
    %disegno poligono
    hold on
    for k=1:num_edge_poly
        X(k) = points(poly(k),1);
        Y(k) = points(poly(k),2);
        Z(k)= points(poly(k),3);
    end
    b=fill3(X,Y,Z,'g' );
    set(b,'facealpha',.2);
    
    xlabel('x')
    ylabel('y')
    zlabel('z')
    
end

