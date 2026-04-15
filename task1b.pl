% Task 1b (variant 8) / Задача 1-б (варіант 8)
% Keep elements at positions equal to squares of integers.
% Залишити елементи на позиціях, що відповідають квадратам цілих чисел.
% Positions / Позиції: 1, 4, 9, 16, 25, ...

:- initialization(main, main).

% --- Logic / Логіка ---

% keep_squares(+List, -Result)
% Entry point / Точка входу
keep_squares(List, Result) :- keep_squares(List, 1, 1, Result).

% keep_squares(+Rest, +CurrentPos, +NextSquareIndex, -Result)
% Current position matches a square / Поточна позиція є квадратом — береємо елемент
keep_squares([], _, _, []).
keep_squares([H|T], Pos, SqIdx, [H|R]) :-
    Sq is SqIdx * SqIdx,
    Pos =:= Sq, !,
    Next is Pos + 1,
    NextSq is SqIdx + 1,
    keep_squares(T, Next, NextSq, R).
% Current position is not a square / Поточна позиція не є квадратом — пропускаємо
keep_squares([_|T], Pos, SqIdx, R) :-
    Next is Pos + 1,
    keep_squares(T, Next, SqIdx, R).

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
    format("Task 1b: Keep elements at square positions (1, 4, 9, 16, ...)~n"),
    format("~`-t~50|~n"),
    format("Enter numbers separated by spaces: "),
    read_list(Xs),
    keep_squares(Xs, Result),
    format("Result: ~w~n", [Result]).
