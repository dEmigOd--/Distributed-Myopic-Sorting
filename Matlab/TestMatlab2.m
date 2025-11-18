%% testing the simple ball-box moving problem

% t = 0
% |   |  | **| 
% |---|  |---|
%
% t = 1
% | * |  | * |
% |---|  |---|

close all;

num_runs = 1000;

n_start = 20;
n_step = 20;
n_end = 400;

figure;
hold on;
for m = 3:5:30
    results = zeros(num_runs, size(n_start:n_step:n_end, 2));
    for n = n_start:n_step:n_end
        results(:, (n - n_start) / n_step + 1) = RunSims(m, n, num_runs);
    end
    plot((n_start:n_step:n_end)', mean(results, 1));
end
hold off;


m_start = 20;
m_step = 20;
m_end = 400;
figure;
hold on;

for n = 4:16:70
    results = zeros(num_runs, size(n_start:n_step:n_end, 2));
    for m = m_start:m_step:m_end
        results(:, (m - m_start) / m_step + 1) = RunSims(m, n, num_runs);
    end
    plot((m_start:m_step:m_end)', mean(results, 1));
end
hold off;

function [results] = RunSims(m, n, runs)
    results = zeros(runs, 1);
    for run = 1:runs
        bars_ = sort(randperm(m + n - 1, m - 1))';
        balls = diff([0; bars_; m + n]) - 1;
        results(run) = RunSim(balls);
    end
end

function [iterations] = RunSim(balls)
    n = sum(balls, 1);
    iterations = 0;
    while (balls(1) ~= n)
        move = balls > 0;
        balls = balls + [move(2:end); 0] - [0; move(2: end)];
        iterations = iterations + 1;
    end
end