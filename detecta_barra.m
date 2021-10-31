function [barra_detectada] = detecta_barra(filename)
    if(isempty(strfind(filename, "10")) == 0) % 0 is true
        barra_detectada = 10;
    elseif(isempty(strfind(filename, "20")) == 0) % 0 is true
        barra_detectada = 20;
    elseif(isempty(strfind(filename, "30")) == 0) % 0 is true
        barra_detectada = 30;
    else
        error("Barra nao existente no circuito - Barras validas: 10, 20, 30");
    endif
endfunction