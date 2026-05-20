% Task 3 (Variant 3) / Задача 3 (варіант 3)
% Given a natural k, list all words of length at most k that are
% Для заданого натурального k знайти всі слова довжини не більше k,
% accepted by the DFA. Output them in shortlex order.
% які допускаються автоматом. Вивести у shortlex-порядку.

:- set_prolog_flag(encoding, utf8).
:- catch(set_stream(user_input, encoding(utf8)), _, true).
:- catch(set_stream(user_output, encoding(utf8)), _, true).
:- catch(set_stream(user_error, encoding(utf8)), _, true).
:- initialization(main, main).

% --- Preset DFAs / Готові автомати ---
% dfa_preset(Name, States, Alphabet, Start, Accepts, Transitions)

dfa_preset(m1,
    [0, 1, 2], [a, b], 0, [2],
    [ (0,a,1), (0,b,0),
      (1,a,2), (1,b,0),
      (2,a,2), (2,b,2) ]).

dfa_preset(m2,
    [0, 1], [a, b], 0, [0],
    [ (0,a,1), (0,b,1),
      (1,a,0), (1,b,0) ]).

dfa_preset(m3,
    [0, 1, 2], [a, b], 0, [2],
    [ (0,a,1), (0,b,0),
      (1,a,1), (1,b,2),
      (2,a,1), (2,b,0) ]).

% --- DFA run / Прогін автомата ---

step(Trans, Q, A, Q1) :- member((Q, A, Q1), Trans).

run_from(_,     Q, [],     Q).
run_from(Trans, Q, [C|Cs], Final) :-
    step(Trans, Q, C, Q1),
    run_from(Trans, Q1, Cs, Final).

accepts_dfa(Q0, Accepts, Trans, Word) :-
    run_from(Trans, Q0, Word, QF),
    member(QF, Accepts).

% --- Word enumeration / Перерахування слів ---

word_of_length(0, _,     []).
word_of_length(N, Sigma, [C|W]) :-
    N > 0,
    N1 is N - 1,
    member(C, Sigma),
    word_of_length(N1, Sigma, W).

accepted_up_to(Sigma, Q0, Accepts, Trans, K, Words) :-
    findall(W,
            ( between(0, K, N),
              word_of_length(N, Sigma, W),
              accepts_dfa(Q0, Accepts, Trans, W) ),
            Words).

% --- Pretty printing of a word ---

word_atom([],   '<eps>') :- !.
word_atom(Word, Atom) :- atomic_list_concat(Word, '', Atom).

% --- Reading helpers / Допоміжне читання ---

read_tokens(Tokens) :-
    read_line_to_string(user_input, Line),
    split_string(Line, " \t", " \t", Parts),
    exclude(=(""), Parts, Tokens).

read_atoms(Atoms) :-
    read_tokens(Parts),
    maplist(atom_string, Atoms, Parts).

read_ints(Ints) :-
    read_tokens(Parts),
    maplist([S,N]>>(number_string(N,S), integer(N)), Parts, Ints).

read_int(N) :-
    read_line_to_string(user_input, Line),
    (   number_string(N0, Line), integer(N0)
    ->  N = N0
    ;   format("  (треба ціле число) повтори: "),
        read_int(N)
    ).

% Read transitions until empty line. Format: "State Symbol Next".
read_transitions(Trans) :-
    read_line_to_string(user_input, Line),
    (   Line == ""
    ->  Trans = []
    ;   split_string(Line, " \t", " \t", Parts),
        exclude(=(""), Parts, [QS, AS, Q1S | _]),
        number_string(Q, QS), integer(Q),
        atom_string(A, AS),
        number_string(Q1, Q1S), integer(Q1),
        read_transitions(Rest),
        Trans = [(Q,A,Q1) | Rest]
    ;   format("  (помилка формату, пропущено)~n"),
        read_transitions(Trans)
    ).

% --- DFA acquisition / Отримання DFA ---

get_dfa(States, Sigma, Q0, Accepts, Trans) :-
    nl,
    format("Режим:~n"),
    format("  1 — preset DFA (m1: містить \"aa\"; m2: парна довжина; m3: закінчується на \"ab\")~n"),
    format("  2 — ручний ввід DFA~n"),
    format("Вибір [1/2]: "),
    read_line_to_string(user_input, Mode),
    (   Mode == "1"
    ->  format("Назва preset DFA (m1/m2/m3): "),
        read_line_to_string(user_input, NameStr),
        atom_string(Name, NameStr),
        (   dfa_preset(Name, States, Sigma, Q0, Accepts, Trans)
        ->  true
        ;   format("Невідома назва.~n"), fail
        )
    ;   Mode == "2"
    ->  format("Алфавіт (символи через пробіл, напр. a b): "),
        read_atoms(Sigma),
        format("Стани (цілі через пробіл, напр. 0 1 2): "),
        read_ints(States),
        format("Початковий стан: "),
        read_int(Q0),
        format("Прийнятні стани (через пробіл): "),
        read_ints(Accepts),
        format("Переходи, по одному на рядок у форматі \"стан символ наступний\",~nпорожній рядок — завершити:~n"),
        read_transitions(Trans)
    ;   format("Невідомий режим.~n"), fail
    ).

show_dfa(States, Sigma, Q0, Accepts, Trans) :-
    format("Обраний автомат:~n"),
    format("  states:   ~w~n", [States]),
    format("  alphabet: ~w~n", [Sigma]),
    format("  start:    ~w~n", [Q0]),
    format("  accept:   ~w~n", [Accepts]),
    format("  delta:~n"),
    forall(member((Q,A,Q1), Trans),
           format("    ~w --~w--> ~w~n", [Q, A, Q1])).

% --- Main ---

main :-
    format("Task 3 (Variant 3): всі слова довжини <= k, що приймаються DFA~n"),
    format("Порядок: shortlex (спочатку коротші, потім лексикографічно)~n"),
    format("~`-t~65|~n"),
    (   get_dfa(States, Sigma, Q0, Accepts, Trans)
    ->  show_dfa(States, Sigma, Q0, Accepts, Trans),
        format("Введи k (макс. довжина слова): "),
        read_int(K),
        accepted_up_to(Sigma, Q0, Accepts, Trans, K, Words),
        length(Words, N),
        format("~nЗнайдено ~w прийнятих слів довжини <= ~w:~n", [N, K]),
        (   Words = []
        ->  format("  (немає)~n")
        ;   forall(member(W, Words),
                   ( word_atom(W, Atom), format("  ~w~n", [Atom]) ))
        )
    ;   true
    ).
