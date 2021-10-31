function plota_coordenograma(A = 0.0515, B = 0.1140, p = 0.02)
    % Plotar o coordenograma

    m = 1:0.01:10;

    ta_10 = (1/8)*((A./(m.^p - 1)) + B);
    ta_20 = (1/12)*((A./(m.^p - 1)) + B);
    ta_30 = (1/20)*((A./(m.^p - 1)) + B);

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
    hold on;
    plot([0,10], [0.4,0.4], '--k');
    hold on;
    plot([0,10], [0.3,0.3], '--k');
    hold on;
    plot([0,10], [0.2,0.2], '--k');
    % legend("Barra 30", "Barra 20", "Barra 10", "m = 1", "m = 2", "m = 3", "m = 4");
    text(5, 0.25, "Barra 10");
    text(5, 0.17, "Barra 20");
    text(5, 0.10, "Barra 30");
    xlabel("m = I/I_{pk}");
    ylabel("t_a [s]");
endfunction
