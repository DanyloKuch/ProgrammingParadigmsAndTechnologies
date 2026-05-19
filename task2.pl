% Task 2 (variant 16) / Задача 2 (варіант 16)
% Split list into sublists by sizes 1^1, 2^2, 3^3, ...
% Розбити список на підсписки розміром 1^1, 2^2, 3^3, ...
% Taking from front and back alternately.
% Беремо з початку і кінця по черзі.
%
% Example / Приклад: [1..10] -> [[1],[2,3,4,5],[6,7,8,9],[10]]

:- initialization(main, main).

% --- Logic / Логіка ---

% Take first K elements / Взяти перші K елементів
take_n(0, _, []) :- !.
take_n(_, [], []) :- !.
take_n(K, [H|T], [H|R]) :- K > 0, K1 is K-1, take_n(K1, T, R).

% Drop first K elements / Пропустити перші K елементів
drop_n(0, List, List) :- !.
drop_n(_, [], []) :- !.
drop_n(K, [_|T], R) :- K > 0, K1 is K-1, drop_n(K1, T, R).

% Entry point / Точка входу
% split_symmetric(+List, -Result)
split_symmetric([], []) :- !.
split_symmetric(List, Result) :- split_go(List, 1, [], [], Result).

% split_go(+Rest, +N, +FrontsAcc, +BacksAcc, -Result)
% Fronts — front chunks in reverse order / фронтові шматки у зворотньому порядку
% Backs  — back chunks in correct order  / задні шматки у прямому порядку
split_go([], _, Fronts, Backs, Result) :-
    reverse(Fronts, RF), append(RF, Backs, Result).
split_go(List, N, Fronts, Backs, Result) :-
    K is N ^ N,
    length(List, Len),
    Threshold is 2 * K,
    (   Len < Threshold
    ->  % Remainder too small to split — put it all in one sublist
        % Залишок занадто малий — кладемо все одним підсписком
        reverse(Fronts, RF), append(RF, [List|Backs], Result)
    ;   take_n(K, List, Front),          % front chunk / фронтовий шматок
        drop_n(K, List, Rest1),
        length(Rest1, Len1),
        DC is Len1 - K,
        drop_n(DC, Rest1, Back),         % back chunk / задній шматок
        take_n(DC, Rest1, Rest2),        % remaining middle / залишок посередині
        N1 is N + 1,
        split_go(Rest2, N1, [Front|Fronts], [Back|Backs], Result)
    ).

% --- Input / Введення ---

% Read list of integers / Зчитати список цілих чисел
read_list(Xs) :-
    read_line_to_string(user_input, Line),
    split_string(Line, " \t", " \t", Parts),
    exclude(=(""), Parts, Parts1),
    (   Parts1 = []
    ->  Xs = []
    ;   (   maplist([S,X]>>(number_string(X,S), integer(X)), Parts1, Xs)
        ->  true
        ;   format("Error! Enter integers separated by spaces.~nEnter list: "),
            read_list(Xs)
        )
    ).

% --- Main / Головна програма ---
main :-
    format("Task 2: Split list by 1^1, 2^2, 3^3, ... (front and back)~n"),
    format("~`-t~50|~n"),
    format("Enter numbers separated by spaces: "),
    read_list(Xs),
    split_symmetric(Xs, Result),
    format("Result: ~w~n", [Result]).
