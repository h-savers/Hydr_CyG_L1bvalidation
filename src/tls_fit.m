function [a, b] = tls_fit(x, y)
% TLS_FIT  Stima i parametri della retta y = a*x + b
% usando Total Least Squares (errori su x e y)
%
% INPUT:
%   x, y : vettori colonna o riga
%
% OUTPUT:
%   a : coefficiente angolare
%   b : intercetta

    % Assicura vettori colonna
    x = x(:);
    y = y(:);
    finiti=find(isfinite(x)==1 & isfinite(y)==1) ;
    x=x(finiti) ; y=y(finiti) ; 
    % Centro i dati (importante per TLS)
    mx = mean(x);
    my = mean(y);

    Xc = x - mx;
    Yc = y - my;

    % Matrice dati
    A = [Xc Yc];

    % SVD
    [~, ~, V] = svd(A, 0);

    % Direzione della retta = prima componente principale
    dir = V(:,1);

    % Coefficiente angolare
    a = dir(2) / dir(1);

    % Intercetta
    b = my - a * mx;
end 