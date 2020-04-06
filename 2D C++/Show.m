function Show(num_edge,i)
%Show crea la figura di triangolazione e della traccia che passa sulla
%triangolazione
%   Riceve in input il numero di lati e il numero della traccia in
%   considerazione
%   Usando le variabili globali crea la figura

%richiamo le variabili globali
global node;
global edge;
global points;
global traces;

clf
%f1= figure;                 %creo la figura
hold on                     %mantiene tutti i plot creati
axis equal                  %mantiene gli assi tutti uguali
axis([-0.2 1.2 -0.2 1.2])   %imposta le dimensioni prefissate degli assi

%ciclo per stampare sulla figura tutti i lati
for j=1:1:num_edge
    plot([node(edge(j,1),1),node(edge(j,2),1)],[node(edge(j,1),2),node(edge(j,2),2)],'k')
end

%ciclo per stampare sulla figura la traccia
% if i==1
     plot([points(traces(i,1),1),points(traces(i,2),1)],[points(traces(i,1),2),points(traces(i,2),2)],'r','linewidth',2)
% else
%     plot([points(traces(i,1),1),points(traces(i,2),1)],[points(traces(i,1),2),points(traces(i,2),2)],'g','linewidth',2)
% end

end

