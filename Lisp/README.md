## Chiglie Convesse (Convex Hulls)

SOLUZIONE ADOTTATA: “Graham’s Scan” (la scansione di Graham).

Sintassi:

    (convexh (read-points filename)) -> Result

--IMPORTANTE--
1) la funzione ritorna nil quando non è rispettata la sintassi nella definizione dei punti nel *filename*. Le righe nel file devono avere SOLO 2 numeri INTERI separati da UN SOLO tab. Tutte le possibili varianti di quanto scritto ritorneranno errore.
2) Nel file è possibile lasciare righe vuote che verranno ignorate nella computazione.
