% ------------------------------------------------------------------------------
% 1. Profilaxia do caso de simulacao
% ------------------------------------------------------------------------------
close all;
fclose all;
clear all;
% ------------------------------------------------------------------------------
% 2. Leitura do caso de simulacao
% ------------------------------------------------------------------------------
filename = 'G1rele30';

function [temp_iaL_iedF, temp_ibL_iedF, temp_icL_iedF ] = adquireSinal(filename)
  matriz = csvread([filename '.csv']);
  tempo = matriz(:,1);  % Sinal temporal no arquivo
  IAL   = matriz(:,2);  % Corrente da fase A no terminal local
  IBL   = matriz(:,3);  % Corrente da fase B no terminal local
  ICL   = matriz(:,4);  % Corrente da fase C no terminal local
  % ------------------------------------------------------------------------------
  % 3. Configuracao do rele de protecao
  % ------------------------------------------------------------------------------
  % 3.1 Configuracoes sobre o sistema e sobre a amostragem
  f          = 60;                 % Frequencia do sistema de potencia
  na         = 16;                 % Numero de amostras por ciclo
  fa         = na*f;               % Frequencia de amostragem
  Ta         = 1/fa;               % Periodo de amostragem
  ciclosbuff = 4;                  % Numero de ciclos armazenados no buffer
  tambuffer  = ciclosbuff*na;      % Numero de amostras no buffer
  iaL_ied    = zeros(1,tambuffer); % Tamanho do buffer para corrente na fase A do terminal local 
  ibL_ied    = zeros(1,tambuffer); % Tamanho do buffer para corrente na fase B do terminal local 
  icL_ied    = zeros(1,tambuffer); % Tamanho do buffer para corrente na fase C do terminal local
  % ------------------------------------------------------------------------------
  % 3.2 Especificacao do filtro de entrada do IED
  %     a) Dados do filtro Butterworth
  fp            = 90;  % Frequencia maxima da banda de passagem, em [Hz]
  hc            = 16;   % Harmonica que se deseja eliminar
  fs            = hc*f;% Frequencia da banda de rejeicao, em [Hz]
  Amax          = 3; % Atenuacao fora da banda de passagem, [dB]
  Amin          = 32; % Atenuacao fora da banda de passagem, [dB]
  %     b) Ordem de um filtro Butterworth
  % [f_order, wc] = buttord(2*pi*fp/(pi*fa), 2*pi*60*hc/(pi*fa), Amin, Amax);
  %[f_order, wc] = buttord(2*pi*fp/(2*pi*fa), 2*pi*60*hc/(2*pi*fa), 0.1, Aten);
  %     c) Cria o filtro
  % [num, den]    = butter(f_order, wc);
  %     d) Cria a funcao de transferencia
  % filtro        = tf(num,den);
  % ------------------------------------------------------------------------------
  % 3.3 Configuracoes sobre as funcoes de protecao
  %     a) Sobrecorrente
  curva = []; % Familia e tipo de curva escolhida (IEEE ou IEC)
  Ipk   = []; % Corrente de pickup (neste caso pode ser em termos de valores primarios
  Dt    = []; % Delta de tempo para coordenacao entre as protecoes
  % ------------------------------------------------------------------------------
  % 4. Filtragem analogica e reamostragem do sinal
  %    a) Filtragem do sinal
  % IALf = filter(num, den, IAL); % Filtragem do sinal de corrente da fase A do terminal local
  % IBLf = filter(num, den, IBL); % Filtragem do sinal de corrente da fase B do terminal local
  % ICLf = filter(num, den, ICL); % Filtragem do sinal de corrente da fase C do terminal local
  % IARf = filter(num, den, IAR); % Filtragem do sinal de corrente da fase A do terminal remoto
  % IBRf = filter(num, den, IBR); % Filtragem do sinal de corrente da fase B do terminal remoto
  % ICRf = filter(num, den, ICR); % Filtragem do sinal de corrente da fase C do terminal remoto
  IALf = filtro_analogico(0, IAL, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax); % Filtragem do sinal de corrente da fase A do terminal local
  IBLf = filtro_analogico(0, IBL, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax); % Filtragem do sinal de corrente da fase B do terminal local
  ICLf = filtro_analogico(0, ICL, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax); % Filtragem do sinal de corrente da fase C do terminal local
  %    b) Reamostragem do sinal (como o sinal original possui 32 amostras por ciclo, 
  %       basta fazer a decimacao convencional, caso contrario seria necessario o resample
  %       com alguma tecnica de PDS, do tipo "zero padding")
  cont = 1;
  for aux=1:length(IALf)
    if mod(aux,2)
      tempor(cont) = (aux-1)*Ta;
      IALfr(cont)  = IALf(aux);
      IBLfr(cont)  = IBLf(aux); 
      ICLfr(cont)  = ICLf(aux);
      cont         = cont + 1;
    end
  end
  % ------------------------------------------------------------------------------
  % 4. Processamento da protecao (na vida real eh um loop infinito do tipo ]
  %    'while (1)'
  % ------------------------------------------------------------------------------
  tam       = 1;
  posbuffer = 1;
  while tam<=length(tempor)
    % ----------------------------------------------------------------------------
    % 4.1 Armazenagem das amostras no buffer do IED (verificando se chegou no 
    %     final do tamanho dele (caso contrario tem que comecar a sobrescrever as 
    %     amostras mais antigas
    % ----------------------------------------------------------------------------
    if posbuffer>tambuffer
      posbuffer = 1;
    end
    iaL_ied(posbuffer) = IALfr(tam); % Buffer de corrente da fase A no terminal Local
    ibL_ied(posbuffer) = IBLfr(tam); % Buffer de corrente da fase B no terminal Local
    icL_ied(posbuffer) = ICLfr(tam); % Buffer de corrente da fase C no terminal Local
    % ----------------------------------------------------------------------------
    % 4.2 Monta o vetor de correntes para c�lculo de Fourier
    % ----------------------------------------------------------------------------
    if posbuffer<na    
      iaL_iedF(posbuffer) = fourier([iaL_ied(tambuffer-(na-posbuffer)+1:tambuffer) iaL_ied(1:posbuffer)],na,fa,f);
      ibL_iedF(posbuffer) = fourier([ibL_ied(tambuffer-(na-posbuffer)+1:tambuffer) ibL_ied(1:posbuffer)],na,fa,f);
      icL_iedF(posbuffer) = fourier([icL_ied(tambuffer-(na-posbuffer)+1:tambuffer) icL_ied(1:posbuffer)],na,fa,f);
    else
      iaL_iedF(posbuffer) = fourier(iaL_ied(posbuffer-na+1:posbuffer),na,fa,f);
      ibL_iedF(posbuffer) = fourier(ibL_ied(posbuffer-na+1:posbuffer),na,fa,f);
      icL_iedF(posbuffer) = fourier(icL_ied(posbuffer-na+1:posbuffer),na,fa,f);
    end
    fprintf('Amostra: %03.f de %03.f amostras\n',tam, length(tempor));
    % ----------------------------------------------------------------------------
    % ATENCAO - Apenas para teste aqui!!!
    % ----------------------------------------------------------------------------
    temp_iaL_iedF(tam) = iaL_iedF(posbuffer);
    temp_ibL_iedF(tam) = ibL_iedF(posbuffer);
    temp_icL_iedF(tam) = icL_iedF(posbuffer);
    % ----------------------------------------------------------------------------
    posbuffer = posbuffer + 1;
    tam       = tam + 1;
  end

  neutro = IALfr + IBLfr + ICLfr;

  figure;
  subplot(4, 1, 1);
  plot(IALfr,'r');
  hold on
  plot(sqrt(2)*[temp_iaL_iedF.magnitude],'k');
  title(["Fase A - " filename]);

  subplot(4, 1, 2);
  plot(IBLfr,'g');
  hold on
  plot(sqrt(2)*[temp_ibL_iedF.magnitude],'k');
  title(["Fase B - " filename]);

  subplot(4, 1, 3);
  plot(ICLfr,'b');
  hold on
  plot(sqrt(2)*[temp_icL_iedF.magnitude],'k');
  title(["Fase C - " filename]);

  subplot(4, 1, 4);
  plot(neutro);
  title(["Corrente de neutro - " filename]);
endfunction
[temp_iaL_iedF, temp_ibL_iedF, temp_icL_iedF ] = adquireSinal(filename);

% Modelamento das curvas da família IEEE ANSI

m = 1:0.001:5;
A = [28.2, 19.61, 0.0515];
B = [0.1217, 0.491, 0.1140];
p = [2, 2, 0.02];

% Vamos plotar elas para ver o seu aspecto
ta1 = (A(1)./(m.^p(1) - 1)) + B(1);
ta2 = (A(2)./(m.^p(2) - 1)) + B(2);
ta3 = (A(3)./(m.^p(3) - 1)) + B(3);

figure;
plot(m, ta1, m, ta2, m, ta3);
xlim([0, 5]);
ylim([0, 100]);
legend("Extremamente inversa", "Muito inversa", "Moderadamente inversa");
xlabel('m = I/Ipk');
ylabel('ta [s]');
title('Curvas do grupo ANSI');

% Para determinar quanto tempo demora para atuar a proteção, vamos achar o máximo
% valor de corrente para cada barra e quando esse máximo ocorre. Após isso, vamos
% verificar em quanto tempo atuariam as proteções de cada barra e verificar se o
% projeto está adequado

% Correntes de pickup

Ipk30 = 212.5;
Ipk20 = 390;
Ipk10 = 555;

% Momento de corrente máxima na fase A, barra 30
faseA_amplitude = [temp_iaL_iedF.magnitude];

[max_value max_index] = max(faseA_amplitude);

% Razão entre corrente de pickup e Corrente máxima do sinal

m = sqrt(2)*max_value/Ipk30;
if (m > 1)
  % Tempo de atuação do relé da barra 30:
  tempo_Atuacao_Extremamente_Inversa = (A(1)./(m.*p(1) - 1)) + B(1) % Extremamente Inversa
  tempo_Atuacao_Muito_Inversa = (A(2)./(m.*p(2) - 1)) + B(2) % Muito Inversa
  tempo_Atuacao_Moderadamente_Inversa = (A(3)./(m.*p(3) - 1)) + B(3) % Moderadamente inversa
else
  disp("m <= 1, tempo de atuacao -> + Inf");
endif