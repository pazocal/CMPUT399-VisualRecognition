function [Gx,Gy] = my_forloop_gradient(G)

[h,w] = size(G);
Gx = zeros(h,w);
Gy = zeros(h,w);
for u=2:h-1,
    for v=2:w-1,
        Gx(u,v) = (G(u,v+1) - G(u,v-1))/2;
        Gy(u,v) = (G(u+1,v) - G(u-1,v))/2;
    end
end

end

