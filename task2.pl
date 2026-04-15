% Задача 2 (варіант 16)
% Розбити список на підсписки по 1^1, 2^2, 3^3, ...

% --- Логіка ---

take_n(0, _, []) :- !.
take_n(_, [], []) :- !.
take_n(K, [H|T], [H|R]) :- K > 0, K1 is K-1, take_n(K1, T, R).

drop_n(0, List, List) :- !.
drop_n(_, [], []) :- !.
drop_n(K, [_|T], R) :- K > 0, K1 is K-1, drop_n(K1, T, R).

split_symmetric([], []) :- !.
split_symmetric(List, Result) :-
    split_go(List, 1, [], [], Result).

split_go([], _, Fronts, Backs, Result) :-
    reverse(Fronts, RF), append(RF, Backs, Result).
split_go(List, N, Fronts, Backs, Result) :-
    K is N ^ N,
    length(List, Len),
    Threshold is 2 * K,
    (   Len < Threshold
    ->  reverse(Fronts, RF), append(RF, [List|Backs], Result)
    ;   take_n(K, List, Front),
        drop_n(K, List, Rest1),
        length(Rest1, Len1),
        DC is Len1 - K,
        drop_n(DC, Rest1, Back),
        take_n(DC, Rest1, Rest2),
        N1 is N + 1,
        split_go(Rest2, N1, [Front|Fronts], [Back|Backs], Result)
    ).

% --- Зчитування списку ---
read_list(Xs) :-
    read_line_to_string(user_input, Line),
    split_string(Line, " \t", " \t", Parts),
    exclude(=(""), Parts, Parts1),
    (   Parts1 = []
    ->  Xs = []
    ;   (   maplist([S,X]>>(number_string(X,S), integer(X)), Parts1, Xs)
        ->  true
        ;   format("Помилка! Тільки цілі числа через пробіл.~nВведіть список: "),
            read_list(Xs)
        )
    ).

% --- Головна програма ---
:- initialization(main, main).

main :-
    format("Задача 2: Розбити список по 1^1, 2^2, 3^3, ...~n"),
    format("~`-t~55|~n"),
    format("Введіть числа через пробіл: "),
    read_list(Xs),
    split_symmetric(Xs, Result),
    format("Результат: ~w~n", [Result]).
