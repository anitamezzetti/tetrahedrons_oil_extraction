function [ flag ] = already_control( X, control)
%controlla che non sia gi� stato controllato
%output= flag=0 non controllato, flag=1 gi� controllato


    %aggiorna come lato gi� controllato e controlla che non sia gi�
    %stato controllato:
    size_control=size(control);
    size_control=size_control(2);

    %devo cercare se � gia stato controllato solo se la
    %control arriva a X, altrimenti mi da errore
    flag=0;
    
    if size_control>=X
        if control(X)==2 || control(X)==1 %dovrebbe essere 2 controllato 1 intersecato
            flag=1;
        end                    
    end %se size minore flag resta zero perch� non � stato controllato

end

