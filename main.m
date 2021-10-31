% ------------------------------------------------------------------------------------------- %
%   PEA 3412 - Tarefa 3
  
%   Grupo G:
%    - Gabriel Fernandes Rosa Bojikian, 9349221
%    - Maurício Kenji Sanda, 10773190
%    - Pedro César Igarashi, 10812071
%
% ------------------------------------------------------------------------------------------- %
close all;
fclose all;
clear all;
clc;

% Para ler algum arquivo .csv, digite o nome dele sem o sufixo na variável seguinte filename
% Exemplo: Para ler o arquivo 'A1rele10.csv', escreva 'A1rele10' na variável filename
filename = 'G1rele10';

barra_detectada = detecta_barra(filename);

[temp_iaL_iedF, temp_ibL_iedF, temp_icL_iedF ] = adquire_sinal(filename);

% Modelamento das curva moderadamente inversa da família IEEE ANSI

m = 1:0.001:5;
A = 0.0515;
B = 0.1140;
p = 0.02;

% Correntes de pickup

Ipk30 = 212.5;
Ipk20 = 390;
Ipk10 = 555;

% Vamos agora utilizar a corrente de pickup e o multiplicador
% de tempo adequados para cada barra

switch(barra_detectada)
  case(10)
    Ipk=Ipk10;
    MT = 1/8;
  case(20)
    Ipk=Ipk20;
    MT = 1/12;
  case(30)
    Ipk=Ipk30;
    MT = 1/20;
  otherwise
    Ipk = -999;
endswitch

% Vamos descobrir o valor máximo da corrente em cada fase
faseA_amplitude = [temp_iaL_iedF.magnitude];
faseB_amplitude = [temp_ibL_iedF.magnitude];
faseC_amplitude = [temp_icL_iedF.magnitude];

[valor_maximo_fase_A max_index] = max(faseA_amplitude);
[valor_maximo_fase_B max_index] = max(faseB_amplitude);
[valor_maximo_fase_C max_index] = max(faseC_amplitude);

% Vamos fazer os cálculos e gerar o relatório para o usuário

disp(["\n\nAnalise de atuacao dos reles na barra " num2str(barra_detectada) "\n"]);

disp("Valores RMS maximos de corrente: ");
disp(["   Fase A: " num2str(valor_maximo_fase_A) " A"]);
disp(["   Fase B: " num2str(valor_maximo_fase_B) " A"]);
disp(["   Fase C: " num2str(valor_maximo_fase_C) " A"]);
disp(["Corrente de pickup da barra " num2str(barra_detectada) ": " num2str(Ipk) " A"]);

% Calculo do tempo de atuacao para a familia de curvas ANSI
I_max = max([valor_maximo_fase_A valor_maximo_fase_B valor_maximo_fase_C]);
m = I_max/Ipk;

if (m > 1)
  tempo_Atuacao_Moderadamente_Inversa = MT*((A./(m.^p - 1)) + B); % Moderadamente inversa
  
  disp(["Tempo de atuacao para curva moderadamente inversa " num2str(tempo_Atuacao_Moderadamente_Inversa) " s"])% tempo_Atuacao_Moderadamente_Inversa = (A(3)./(m.*p(3) - 1)) + B(3); % Moderadamente inversa
else
  disp("\nNao ha situacao sobrecorrente (m <= 1), rele nao atua");
endif