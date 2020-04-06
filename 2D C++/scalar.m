function [s1,s2] = scalar(i,j,n)
%questa funzione calcola il prodotto scalare tra la normale alla traccia e
%il vettore congiungente l'estremo 1 della traccia e i vari vertici del
%lato

global edge;
global node;
global points;
global traces;

%segmento ti e x1
e1=[node(edge(j,1),1)-points(traces(i,1),1),node(edge(j,1),2)-points(traces(i,1),2)];
%segmento ti e x2
e2=[node(edge(j,2),1)-points(traces(i,1),1),node(edge(j,2),2)-points(traces(i,1),2)];
%faccio i due prodotti scalari fra n*e1 e n*e2
s1= n(1)*e1(1)+n(2)*e1(2);
s2= n(1)*e2(1)+n(2)*e2(2);
end

