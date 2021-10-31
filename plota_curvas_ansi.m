function plota_curvas_ansi(m, A, B, p)
    % Vamos plotar elas para ver o seu aspecto
    ta1 = (A(1)./(m.^p(1) - 1)) + B(1);
    ta2 = (A(2)./(m.^p(2) - 1)) + B(2);
    ta3 = (A(3)./(m.^p(3) - 1)) + B(3);

    figure;
    plot(m, ta1, m, ta2, m, ta3);
    xlim([0, 5]);
    ylim([0, 20]);
    legend("Extremamente inversa", "Muito inversa", "Moderadamente inversa");
    xlabel('m = I/Ipk');
    ylabel('ta [s]');
    title('Curvas da familia ANSI');
    hold on;
    x = 1;
    plot([x,x], [-10,40], '--k');
    legend("Extremamente inversa", "Muito inversa", "Moderadamente inversa", "m = 1");
endfunction