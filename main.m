close all;
fclose all;
clear all;
clc;

filename = 'G2rele30';

if(isempty(strfind(filename, "10")) == 0) % 0 is true
  barra_detectada = 10;
elseif(isempty(strfind(filename, "20")) == 0) % 0 is true
  barra_detectada = 20;
elseif(isempty(strfind(filename, "30")) == 0) % 0 is true
  barra_detectada = 30;
endif

[temp_iaL_iedF, temp_ibL_iedF, temp_icL_iedF ] = adquire_sinal(filename);

% Modelamento das curvas da família IEEE ANSI

m = 1:0.001:5;
A = [28.2, 19.61, 0.0515];
B = [0.1217, 0.491, 0.1140];
p = [2, 2, 0.02];

plota_curvas_ansi(m, A, B, p);

% Para determinar quanto tempo demora para atuar a proteção, vamos achar o máximo
% valor de corrente para cada barra e em quanto tempo ela atua, baseado na função
% de proteção projetada.

% Correntes de pickup

Ipk30 = 212.5;
Ipk20 = 390;
Ipk10 = 555;

% Momento de corrente máxima na fase A, barra 30
faseA_amplitude = [temp_iaL_iedF.magnitude];
faseB_amplitude = [temp_ibL_iedF.magnitude];
faseC_amplitude = [temp_icL_iedF.magnitude];

[valor_maximo_fase_A max_index] = max(faseA_amplitude);
[valor_maximo_fase_B max_index] = max(faseB_amplitude);
[valor_maximo_fase_C max_index] = max(faseC_amplitude);

switch(barra_detectada)
  case(10)
    Ipk=Ipk10;
  case(20)
    Ipk=Ipk20;
  case(30)
    Ipk=Ipk30;
  otherwise
    Ipk = -999;
endswitch

disp(["\n\nAnalise de atuacao dos reles na barra " num2str(barra_detectada) "\n"]);

disp("Valores quadraticos medios maximos de corrente: ");
disp(["   Fase A: " num2str(valor_maximo_fase_A) " A"]);
disp(["   Fase B: " num2str(valor_maximo_fase_B) " A"]);
disp(["   Fase C: " num2str(valor_maximo_fase_C) " A"]);
disp(["Corrente de pickup da barra " num2str(barra_detectada) ": " num2str(Ipk)]);

% Calculo do tempo de atuacao para a familia de curvas ANSI
m = sqrt(2)*max([valor_maximo_fase_A valor_maximo_fase_B valor_maximo_fase_C])/Ipk;
if (m > 1)
  tempo_Atuacao_Extremamente_Inversa = (A(1)./(m.*p(1) - 1)) + B(1); % Extremamente Inversa
  tempo_Atuacao_Muito_Inversa = (A(2)./(m.*p(2) - 1)) + B(2); % Muito Inversa
  tempo_Atuacao_Moderadamente_Inversa = (A(3)./(m.*p(3) - 1)) + B(3); % Moderadamente inversa
  
  disp(["\nTempo de atuacao para curva extremamente inversa " num2str(tempo_Atuacao_Extremamente_Inversa) " s"])
  disp(["Tempo de atuacao para curva muito inversa " num2str(tempo_Atuacao_Muito_Inversa) " s"])% tempo_Atuacao_Muito_Inversa = (A(2)./(m.*p(2) - 1)) + B(2); % Muito Inversa
  disp(["Tempo de atuacao para curva moderadamente inversa " num2str(tempo_Atuacao_Moderadamente_Inversa) " s"])% tempo_Atuacao_Moderadamente_Inversa = (A(3)./(m.*p(3) - 1)) + B(3); % Moderadamente inversa
else
  disp("\nNao ha situacao de falha (m <= 1), rele nao atua");
endif