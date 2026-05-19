% Задача 1-б (варіант 8): Залишити у списку елементи, позиції яких є квадратами цілих чисел (1, 4, 9, 16, 25, ...).

:- set_prolog_flag(encoding, utf8).
:- catch(set_stream(user_input, encoding(utf8)), _, true).
:- catch(set_stream(user_output, encoding(utf8)), _, true).
:- catch(set_stream(user_error, encoding(utf8)), _, true).
:- initialization(main, main).

keep_squares(List, Result) :- keep_squares(List, 1, 1, Result).

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

main :-
    format("Task 1b: Keep elements at square positions (1, 4, 9, 16, ...)~n"),
    format("~`-t~50|~n"),
    format("Enter numbers separated by spaces: "),
    read_list(Xs),
    keep_squares(Xs, Result),
    format("Result: ~w~n", [Result]).
