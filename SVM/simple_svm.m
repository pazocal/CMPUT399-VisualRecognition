% Illustrates a simple SV classifer
close all;
clear all;
separable=0;

if separable==1,
    % separable case
    n=25;
    x1 = 100*rand(n,1);
    x2 = 100*rand(n,1);
    % training labels
    figure(1),hold on;
    y=zeros(n,1);
    for i=1:n,
        if 0.4*x1(i)+30>x2(i),
            y(i) = 1;
            plot(x1(i),x2(i),'+');
        else
            y(i) = -1;
            plot(x1(i),x2(i),'r.');
        end
    end
    hold off;
else
    % non-separable case
    load gaussian_mixture_data;
    n=length(y);
    figure(1),plot(x1(1:100),x2(1:100),'+');
    figure(1),hold on, plot(x1(101:200),x2(101:200),'r.'); hold off; drawnow;
end
% construxt Gram matrix (Kernel matrix)
K = zeros(n,n);
for i=1:n,
    for j=1:n,
        K(i,j) = x1(i)*x1(j) + x2(i)*x2(j); % this a linear kernel, it could be more sophisticated
    end
end
C=0.1; % a parameter, you actually don't need it for the separable case
alpha = quadprog(diag(y)*K*diag(y),-ones(n,1),eye(n),C*ones(n,1),y',0,zeros(n,1),Inf*ones(n,1));

% support vectors
tol=0.0001;
sv = zeros(length(y),1);
figure(1),hold on;
for i=1:length(y),
    if alpha(i)>tol,
        sv(i)=1;
        plot(x1(i),x2(i),'o');
    end
end
hold off;

% computing offset
b = 0;
for i=1:length(y),
    if sv(i),
        b = b + y(i);
        for j=1:length(y),
            if sv(j),
                b = b - alpha(j)*y(j)*K(i,j);
            end
        end
    end
end
b = b/sum(sv);

% now constructing the hyper plane (in this case a straight line)
b1 = sum((((sv.*alpha).*y).*x1));
b2 = sum((((sv.*alpha).*y).*x2));

px = (min(x1):max(x1))';
py = -(b1/b2)*px - (b/b2);
figure(1); hold on; plot(px,py,'g'); hold off; axis image;