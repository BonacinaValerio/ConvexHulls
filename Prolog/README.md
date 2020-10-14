## Chiglie Convesse (Convex Hulls)

SOLUZIONE ADOTTATA: “Graham’s Scan” (la scansione di Graham).

Sintassi:

    read_points(filename, Points),
    convexh(Points, CH).

--IMPORTANTE--
1) Il predicato fallisce quando non è rispettata la sintassi nella definizione dei punti nel *filename*. Le righe nel file devono avere SOLO 2 numeri INTERI separati da UN SOLO tab. Tutte le possibili varianti di quanto scritto ritorneranno errore.
2) Nel file è possibile lasciare righe vuote che verranno ignorate nella computazione.
