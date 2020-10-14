
## Introduzione

Il calcolo delle chiglie convesse (convex hulls) è uno degli algoritmi fondamentali della geometria computazionale. L’algoritmo ha numerosissime applicazioni e, una volta implementate correttamente alcune primitive geometriche, è di una semplicità sorprendente. Vengono implementate due librerie, una in Common Lisp e una in Prolog che forniscono un’implementazione dell’algoritmo per il calcolo delle chiglie convesse.

## Definizioni

Dato un insieme di punti P, l’insieme è convesso se, presi due punti qualunque p e q ∈ P, il segmento pq è completamente all’interno di P. La convex hull di P è il più piccolo insieme convesso che contiene tutti i punti di P. Nel seguito useremo la notazione CHp per indicare la convex hull di P.
La CHp ha le seguenti proprietà.
- È la forma più semplice che “approssima” un insieme di punti.
- È il perimetro più corto che delimita P.
- È il poligono di area minore che copre tutti i punti di P.  

## Intuizione
Il dispositivo “meccanico” per calcolare CHp è costituito da una tavola di legno, chiodi, martello ed un elastico.

## Soluzione
Vi sono molte soluzioni al problema del calcolo di CHp. Se consideriamo un insieme di punti P come input con |P| = N, allora il miglior algoritmo ha complessità temporale O(Nlg(N)). Una sua implementazione usa il cosiddetto “Graham’s Scan” (la scansione di Graham).
Si sceglie il punto s ∈ P con l’ordinata minore (in caso di pareggio si sceglie quello con l’ascissa minore).
Si ordinano i rimanenti punti secondo l’angolo polare che formano con s, in modo da ottenere un poligono semplice (anche se non convesso).
Si considerano i punti in ordine e si scartano quelli che imporrebbero una “svolta a destra”.

## Input (ed Output)

Il progetto deve prevedere una funzione (un predicato) che legga da file (*filename*) una serie di punti e ritorni una lista di punti (*points*). 
Il contenuto di *filename* è costituito da un numero pari d’interi, due per riga, separati da un carattere di tabulazione. 
Ad esempio, questo è un file di test corretto:

    0	6
    3	7
    4	6
    4	5
    3	4
    2	4
    5	0
    -42	0
    -2	1

