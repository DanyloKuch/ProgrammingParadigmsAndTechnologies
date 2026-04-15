% Задача 1-б (варіант 8)
% Залишити у списку елементи у позиціях, що відповідають квадратам цілих чисел.
% Позиції: 1, 4, 9, 16, 25, ...

% --- Логіка ---

keep_squares(List, Result) :-
    keep_squares(List, 1, 1, Result).

keep_squares([], _, _, []).
keep_squares([H|T], Pos, SqIdx, [H|R]) :-
    Sq is SqIdx * SqIdx,
    Pos =:= Sq, !,
    Next is Pos + 1,
    NextSq is SqIdx + 1,
    keep_squares(T, Next, NextSq, R).
keep_squares([_|T], Pos, SqIdx, R) :-
    Next is Pos + 1,
    keep_squares(T, Next, SqIdx, R).

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
    format("Задача 1-б: Залишити елементи на позиціях-квадратах (1,4,9,16,...)~n"),
    format("~`-t~55|~n"),
    format("Введіть числа через пробіл: "),
    read_list(Xs),
    keep_squares(Xs, Result),
    format("Результат: ~w~n", [Result]).
