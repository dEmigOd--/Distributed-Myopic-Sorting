flips = 20;
trials = 1000000;

tic;
outcomes = randi(6, trials, flips);

[rows_e, cols_e] = ind2sub([trials flips], find(cumsum(cumsum(mod(outcomes, 2), 2), 2) == 1));
[rows, cols] = ind2sub([trials flips], find(cumsum(cumsum(outcomes == 6, 2), 2) == 1));

non_even = zeros(trials, 1);
non_even(rows_e) = cols_e;

sixes = zeros(trials, 1);
sixes(rows) = cols;

good_rows = sixes(sixes < non_even);
toc;
fprintf('Num of trials %.2f\n', mean(good_rows(good_rows > 0)));


tic;
good_trials = 0;
sum_attempts = 0;
for i = 1 : trials
    not_six_and_even = true;
    tries = 0;
    while(not_six_and_even)
        next_attempt = randi(6);
        tries = tries + 1;
        if(mod(next_attempt, 2) == 1)
            break;
        end
        if(next_attempt == 6)
            good_trials = good_trials + 1;
            sum_attempts = sum_attempts + tries;
            break;
        end
    end
end

toc;

fprintf('Num of trials %.2f\n', sum_attempts / good_trials);
