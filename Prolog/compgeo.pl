%%% Moltiplicazione di differenze
mult_diff(X1, X2, Y1, Y2, Ris) :-
	Parz1 is X1 - X2,
	Parz2 is Y1 - Y2,
	Ris is Parz1 * Parz2.

%%% Calcola l'area di un triangolo * 2
area2(point(X1, Y1), point(X2, Y2), point(X3, Y3), Area) :-
	mult_diff(X2, X1, Y3, Y1, Parz1),
	mult_diff(X3, X1, Y2, Y1, Parz2),
	Area is Parz1 - Parz2.

%%% Svolta a sinistra oppure collineare
left(point(X1, Y1), point(X2, Y2), point(X3, Y3)) :-
	lefton(point(X1, Y1), point(X2, Y2), point(X3, Y3)),
	!.
left(point(X1, Y1), point(X2, Y2), point(X3, Y3)) :-
	coll(point(X1, Y1), point(X2, Y2), point(X3, Y3)),
	!.
left(_, _, _) :-
	!,
	fail.

%%% Svolta a sinistra
lefton(point(X1, Y1), point(X2, Y2), point(X3, Y3)) :-
	area2(point(X1, Y1), point(X2, Y2), point(X3, Y3), Area),
	Area > 0.

%%% Collineare
coll(point(X1, Y1), point(X2, Y2), point(X3, Y3)) :-
	area2(point(X1, Y1), point(X2, Y2), point(X3, Y3), Area),
	Area == 0.

%%% Calcolo dell'angolo in radianti tra due punti
angle2d(point(X1, Y1), point(X2, Y2), Angle) :-
	Delta_y is Y2 - Y1,
	Delta_x is X2 - X1,
	Angle is atan(Delta_y, Delta_x).

%%% Calcolo chiglie convesse
convexh(Points, Points) :-
	length(Points, 1),
	!.
convexh(Points, Result) :-
	lower_list(Points, Center),			% Trova il punto minimo
	sorting(Points, Center, Points_2),	        % Ordina per angolo
	post_sorting(Points_2, Center, [H | T]),	% Ordina per angolo
	push(Center, [], Stack),
	push(H, Stack, Stack2),
	accept_reject(T, Stack2, Result_1),   % Chiamata all'algoritmo ricorsivo
	reverse(Result_1, Result).            % Reverse sulla lista finale

%%% Leggi da file la lista di punti
read_points(Filename, Points) :-
	nonvar(Filename),
	csv_read_file(Filename, Points_Temp,
		      [separator(0'\t), arity(2), match_arity(false), functor(point)]),
	remove_duplicate(Points_Temp, Points2),
	delete(Points2, point(''), Points),
	verify_arity(Points),
	verify_points(Points).

%%% Verifica l'arieta' delle righe
verify_arity([]) :-
	!.
verify_arity([point(_, _) | T]) :-
	!,
	verify_arity(T).
verify_arity(_) :-
	!,
	writef("Errore. Arieta' delle righe errata"),
	fail.

%%% Verifica la correttezza dei punti
verify_points([]) :-
	!.
verify_points([point(X, Y)|T]) :-
	integer(X),
	integer(Y),
	!,
	verify_points(T).
verify_points(_) :-
	!,
	writef("Errore. I punti devono essere rappresentati da numeri interi"),
	fail.

%%% Rimuovi i punti duplicati
remove_duplicate(Points, New_Points) :-
	sort(Points, New_Points).

%%% Trova il punto minimo
lower_list([L|Ls], Min) :-
	lower_list(Ls, L, Min).
lower_list([], Min, Min) :-
	!.
lower_list([L|Ls], Min0, Min) :-
	min_yx(L, Min0, Min1),
	lower_list(Ls, Min1, Min).

%%% Prendi il punto con y minore (a parita' di y, con x minore)
min_yx(point(X1, Y1), point(_, Y2), point(X1, Y1)) :-
	Y1 < Y2,
	!.
min_yx(point(_, Y1), point(X2, Y2), point(X2, Y2)) :-
	Y2 < Y1,
	!.
min_yx(point(X1, Y1), point(X2, _), point(X1, Y1)) :-
	X1 < X2,
	!.
min_yx(point(_, _), point(X2, Y2), point(X2, Y2)) :-
	!.

%%% Ordina i punti per angolo
sorting(Points, Center, New_Points) :-
	delete(Points, Center, Points2),
	add_angle(Points2, Center, Points_angle),
	sort(2, @=<, Points_angle, Points_angle_sorted),
	remove_angle(Points_angle_sorted, New_Points).

post_sorting(Points, Center, New_Points) :-
	append(Points, [Center], Points2),
	reverse(Points2, Point2),
	get_sublist(Point2, Point3, Sublist),
	reverse(Point3, Point4),
	append(Point4, Sublist, New_Points_2),
	delete(New_Points_2, Center, New_Points),
	length(New_Points, N),
	length(Points, N1),
	N = N1,
	!.
post_sorting(Points, _, Points) :-
	!.

get_sublist([point(_, _)], [], []) :- !.
get_sublist([point(X, Y), point(X, Y1) | T],
	    T1, [point(X, Y) | T2]) :-
	get_sublist([point(X, Y1) | T], T1, T2),
	!.
get_sublist([point(X, Y), point(X1, Y1) | T],
	    [point(X1, Y1) | T], [point(X, Y)]) :-
	!.

add_angle([], _, []) :-
	!.
add_angle([H|T], Center, [[H, Angle]|T1]) :-
	angle2d(Center, H, Angle),
	add_angle(T, Center, T1).

remove_angle([], []) :-
	!.
remove_angle([[H, _]|T], [H|T1]) :-
	remove_angle(T, T1).

%%% Algoritmo accetta/rifiuta i punti
accept_reject([], Stack, Stack) :-
	!.
accept_reject([Point3 | T], Stack, Result) :-
	pop(Point2, Stack, Stack2),
	top(Point1, Stack2),
	left(Point1, Point2, Point3),
	!,
	left_coll(Point1, Point2, Point3, Stack2, T, Result).
accept_reject([Point3 | T], Stack, Result) :-
	pop(_, Stack, Stack2),
	accept_reject([Point3 | T], Stack2, Result),
	!.

%%% Diversa gestione di punti collineari e svolta a sinistra
left_coll(Point1, Point2, Point3, Stack, T, Result) :-
	lefton(Point1, Point2, Point3),
	!,
	push(Point2, Stack, Stack2),
	push(Point3, Stack2, Stack3),
	accept_reject(T, Stack3, Result).
left_coll(Point1, Point2, Point3, Stack, T, Result) :-
	coll(Point1, Point2, Point3),
	!,
	farther(Point1, Point2, Point3, Farther, Other),
	push(Other, Stack, Stack2),
	push(Farther, Stack2, Stack3),
	accept_reject(T, Stack3, Result).

%%% Trova il punto piu' lontano da un punto dato
farther(point(X, Y), point(X, Y1), point(X, Y2),
	point(X, Y1), point(X, Y2)) :-
	Y1_Temp is Y1 - Y,
	Y2_Temp is Y2 - Y,
	Y1_abs is abs(Y1_Temp),
	Y2_abs is abs(Y2_Temp),
	Y1_abs is max(Y1_abs, Y2_abs),
	!.
farther(point(X, _), point(X, Y1), point(X, Y2),
	point(X, Y2), point(X, Y1)) :-
	!.
farther(point(X, _), point(X1, Y1), point(X2, Y2),
	point(X3, Y3), point(X4, Y4)) :-
	X1_Temp is X1 - X,
	X2_Temp is X2 - X,
	X1_abs is abs(X1_Temp),
	X2_abs is abs(X2_Temp),
	farther_abs(X1_abs, X2_abs, point(X1, Y1),
		    point(X2, Y2), point(X3, Y3), point(X4, Y4)),
	!.
farther_abs(X1_abs, X2_abs, point(X1, Y1),
	    point(X2, Y2), point(X1, Y1), point(X2, Y2)) :-
	X1_abs is max(X1_abs, X2_abs),
	!.
farther_abs(X1_abs, X2_abs, point(X1, Y1),
	    point(X2, Y2), point(X2, Y2), point(X1, Y1)) :-
	X2_abs is max(X1_abs, X2_abs),
	!.

%%% Rimuovi il top dallo stack
pop(E, [E | Es], Es).
%%% Leggi il top dello stack
top(E, [E | _]).
%%% Inserisci un elemento nello stack
push(E, Es, [E | Es]).