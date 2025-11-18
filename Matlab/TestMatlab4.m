trials = 500000;
runs = 200;

sum_iter = 0;
succ_iter = 0;

tic;
for i=1:trials
    decimal_seq = randi(10, runs, 1) - 1;
    
    for j=1:runs
        digit = randi(6);
        if(digit == decimal_seq(j))
            sum_iter = sum_iter + j;
            succ_iter = succ_iter + 1;
            break;
        end
    end
end
fprintf('Average iter until succ hit is %.4f\n', sum_iter / succ_iter);
fprintf('Failed attempts = %d\n', trials - succ_iter);
toc;