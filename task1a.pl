% Задача 1-а (варіант 8): Зі списку вилучити N найбільших його елементів.

:- set_prolog_flag(encoding, utf8).
:- catch(set_stream(user_input, encoding(utf8)), _, true).
:- catch(set_stream(user_output, encoding(utf8)), _, true).
:- catch(set_stream(user_error, encoding(utf8)), _, true).
:- initialization(main, main).

insert_desc(X, [], [X]) :- !.
insert_desc(X, [H|T], [X,H|T]) :- X >= H, !.
insert_desc(X, [H|T], [H|R]) :- insert_desc(X, T, R).

sort_desc([], []).
sort_desc([H|T], Sorted) :-
    sort_desc(T, ST), insert_desc(H, ST, Sorted).

take_n(0, _, []) :- !.
take_n(_, [], []) :- !.
take_n(K, [H|T], [H|R]) :- K > 0, K1 is K-1, take_n(K1, T, R).

remove_all([], _, []).
remove_all([H|T], Rem, R)     :- member(H, Rem), !, remove_all(T, Rem, R).
remove_all([H|T], Rem, [H|R]) :- remove_all(T, Rem, R).

remove_n_largest(List, N, Result) :-
    list_to_set(List, Unique),
    sort_desc(Unique, Sorted),
    take_n(N, Sorted, ToRemove),
    remove_all(List, ToRemove, Result).

read_n(N) :-
    read_line_to_string(user_input, Line),
    (   number_string(N0, Line), integer(N0), N0 >= 0
    ->  N = N0
    ;   format("Error! Enter a non-negative integer.~nEnter N: "),
        read_n(N)
    ).

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
    format("Task 1a: Remove N largest elements from the list~n"),
    format("~`-t~50|~n"),
    format("Enter N: "),
    read_n(N),
    format("Enter numbers separated by spaces: "),
    read_list(Xs),
    remove_n_largest(Xs, N, Result),
    format("Result: ~w~n", [Result]).
