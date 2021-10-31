close all;
fclose all;
clear all;
clc;

filename = 'B2rele30';

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

% MT = 1;

switch(barra_detectada)
  case(10)
    Ipk=Ipk10;
    MT = 1/5;
  case(20)
    Ipk=Ipk20;
    MT = 1/8;
  case(30)
    Ipk=Ipk30;
    MT = 1/14;
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
m = sqrt(2)*max([valor_maximo_fase_A valor_maximo_fase_B valor_maximo_fase_C])/Ipk
if (m > 1)
  tempo_Atuacao_Extremamente_Inversa = MT*((A(1)./(m.^p(1) - 1)) + B(1)); % Extremamente Inversa
  tempo_Atuacao_Muito_Inversa = MT*((A(2)./(m.^p(2) - 1)) + B(2)); % Muito Inversa
  tempo_Atuacao_Moderadamente_Inversa = MT*((A(3)./(m.^p(3) - 1)) + B(3)); % Moderadamente inversa
  
  disp(["\nTempo de atuacao para curva extremamente inversa " num2str(tempo_Atuacao_Extremamente_Inversa) " s"])
  disp(["Tempo de atuacao para curva muito inversa " num2str(tempo_Atuacao_Muito_Inversa) " s"])% tempo_Atuacao_Muito_Inversa = (A(2)./(m.*p(2) - 1)) + B(2); % Muito Inversa
  disp(["Tempo de atuacao para curva moderadamente inversa " num2str(tempo_Atuacao_Moderadamente_Inversa) " s"])% tempo_Atuacao_Moderadamente_Inversa = (A(3)./(m.*p(3) - 1)) + B(3); % Moderadamente inversa
else
  disp("\nNao ha situacao sobrecorrente (m <= 1), rele nao atua");
endif

% Plotar o coordenograma

m = 1:0.01:10;

ta_10 = (1/5)*((A(3)./(m.^p(3) - 1)) + B(3));
ta_20 = (1/8)*((A(3)./(m.^p(3) - 1)) + B(3));
ta_30 = (1/14)*((A(3)./(m.^p(3) - 1)) + B(3));

figure;
plot(m, ta_30, m, ta_20, m, ta_10);
title('Coordenograma');
% legend("Barra 30", "Barra 20", "Barra 10");
xlim([0, 6]);
ylim([0, 1]);
xticks([0, 1, 2, 3, 4, 5, 6]);
yticks([0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]);
hold on;
x = 1;
plot([x,x], [-10,10], '--k');
hold on;
x2 = 2;
plot([x2,x2], [-10,10], '--k');
hold on;
x3 = 3;
plot([x3,x3], [-10,10], '--k');
hold on;
plot([0,10], [0.5,0.5], '--k');
% legend("Barra 30", "Barra 20", "Barra 10", "m = 1", "m = 2", "m = 3", "m = 4");
text(5, 0.37, "Barra 10");
text(5, 0.25, "Barra 20");
text(5, 0.15, "Barra 30");
xlabel("m = I/I_{pk}");
ylabel("t_a [s]");