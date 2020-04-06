function [  ] = touch_3D(num_node,num_ele,num_vertex,num_edge,num_faces)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
global ele;
global edge;
global face;
global touch;


for i=1:1:num_node
    touch(i).num_tetra=0;
    touch(i).num_node=0;
    touch(i).elenco_edge=[];
    touch(i).elenco_face=[];
end
for j=1:1:num_ele
    for k=1:1:num_vertex
        touch(ele(j,k)).num_tetra=touch(ele(j,k)).num_tetra+1;
        touch(ele(j,k)).elenco_tetra(touch(ele(j,k)).num_tetra)=j;
    end
end
for j=1:num_edge
    touch(edge(j,1)).elenco_edge(end+1)=j;
    touch(edge(j,2)).elenco_edge(end+1)=j;
    touch(edge(j,1)).num_node=touch(edge(j,1)).num_node+1;
    touch(edge(j,1)).elenco_node(touch(edge(j,1)).num_node)=edge(j,2);
    touch(edge(j,2)).num_node=touch(edge(j,2)).num_node+1;
    touch(edge(j,2)).elenco_node(touch(edge(j,2)).num_node)=edge(j,1);
end
for j=1:num_faces
    touch(face(j,1)).elenco_face(end+1)=j;
    touch(face(j,2)).elenco_face(end+1)=j;
    touch(face(j,3)).elenco_face(end+1)=j;
end

end

