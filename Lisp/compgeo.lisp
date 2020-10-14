;;; Definizione di punto
(defun new-point (x y)
  (list x
        y))

;;; ricava la x da un punto
(defun x (point)
  (first point))

;;; ricava la y da un punto
(defun y (point)
  (second point))

;;; Calcola l'area di un triangolo * 2
(defun area2 (a b c)
  (let ((x1 (x a))
        (y1 (y a))
        (x2 (x b))
        (y2 (y b))
        (x3 (x c))
        (y3 (y c)))
    (- (mult-diff x2 x1 y3 y1)
       (mult-diff x3 x1 y2 y1))))

;;; Moltiplicazione di differenze
(defun mult-diff (x1 x2 y1 y2)
  (* (- x1 x2)
     (- y1 y2)))

;;; Svolta a sinistra oppure collineare
(defun left (a b c)
  (cond ((left-on a b c) t)
        ((is-coll a b c) t)
        (t nil)))

;;; Svolta a sinistra
(defun left-on (a b c)
  (cond ((> (area2 a b c) 0) t)
        (t nil)))

;;; Collineare
(defun is-coll (a b c)
  (cond ((= (area2 a b c) 0) t)
        (t nil)))

;;; Calcolo dell'angolo in radianti tra due punti
(defun angle2d (a b)
  (atan (- (y b)
           (y a))
        (- (x b)
           (x a))))

;;; Calcolo chiglie convesse
(defun convexh (points)
  (let ((center (lower-list (rest points) 
                            (first points)))) ; Trova il punto minimo
    (cond ((= (length points) 1) points)
          ((null points) nil)
          (t (let ((item-sorted (post-sorting 
                                (sorting (delete-item center points) 
                                         center)
                                center)))
               (reverse (accept-reject  ; Chiamata all'algoritmo ricorsivo
                         (rest item-sorted) ; Ordina per angolo
                         (cons (first item-sorted)
                               (cons center nil)))))))))

;;; Leggi da file la lista di punti
(defun read-points (filename)
  (let ((input (with-open-file 
                   (in filename :direction :input :if-does-not-exist :error) 
                 (read-list-from in))))
    (sort (verify (remove-duplicate (convert (remove nil (split input)))))  
          #'< :key #'car)))

;;; Rimuovi i punti duplicati
(defun remove-duplicate (L)
  (cond ((null L) L)
        ((member (car L) (cdr L) :test #'equalp)
         (remove-duplicate (cdr L)))
        (t (cons (car L) (remove-duplicate (cdr L))))))

;;; Verifica la sintassi del file
(defun verify (input)
  (let ((input2 (check (arity input))))
    (cond ((find 'e input2) (prin1 "Errore. Sintassi dei punti errata") nil)
          (t input))))

;;; Verifica l'arieta' delle righe
(defun arity (lst)
  (cond ((null lst) nil)
        (t (cons (cond ((/= (list-length (first lst)) 2) 'e)
                       (t (first lst))) 
                 (arity (rest lst))))))

;;; Verifica la presenza di errori
(defun check (lst)
  (cond ((null lst) nil)
        (t (cons (cond ((equal (first lst) 'e) 'e)
                       ((find 'e (first lst)) 'e)
                       (t (first lst))) 
                 (check (rest lst))))))

(defun read-list-from (input-stream)
  (let ((e (read-line input-stream nil 'eof)))
    (unless (eq e 'eof)
      (cons (coerce e 'list) (read-list-from input-stream)))))

;;; Esegui lo split dell'input
(defun split (lst) 
  (cond ((null lst) nil)
        (t (cons (cond ((equal (first (first lst)) #\Tab) (list "e"))
                       ((equal (last (first lst)) '(#\Tab)) (list "e"))
                       (t (split2 (first lst))))
                 (split (rest lst))))))

(defun split2 (lst)
  (cond ((null (first lst)) nil)
        ((equal (first lst) #\Tab) (cons (word (rest lst)) 
                                         (split2 (word2 (rest lst)))))
        (t (cons (word lst) (split2 (word2 lst))))))

(defun word (word)
  (cond ((or (equal (first word) #\Tab)
             (null (first word))) nil)
        (t (concatenate 'string 
                        (string (first word)) 
                        (word (rest word))))))

(defun word2 (wrest)
  (cond ((or (equal (first wrest) #\Tab) 
             (null (first wrest))) wrest)
        (t (word2 (rest wrest)))))

;;; Verifica se una stringa rappresenta un numero
(defun is-a-number (string)
  (integerp (read-from-string (substitute #\. #\, 
                                          (substitute #\- #\Space string)))))

(defun convert (lst) 
  (cond ((null lst) nil)
        (t (cons (convert2 (first lst)) (convert (rest lst))))))

(defun convert2 (lst)
  (cond ((null (first lst)) nil)
        ((is-a-number (first lst)) 
         (cons (read-from-string (first lst)) 
               (convert2 (rest lst))))
        (t (cons 'e nil))))

;;; Trova il punto minimo
(defun lower-list (points min)
  (cond ((null points) min)
        (t (lower-list (rest points) 
                       (min-yx (first points) min)))))

;;; Prendi il punto con y minore (a parita' di y, con x minore)
(defun min-yx (a b)
  (cond ((< (y a) (y b)) a)
        ((< (y b) (y a)) b)
        ((< (x a) (x b)) a)
        (t b)))

;;; Rimuovi elemento dalla lista
(defun delete-item (item list)
  (cond ((null list) nil)
        ((equal item (first list)) (rest list))
        (t (cons (first list) (delete-item item (rest list))))))

;;; Ordina i punti per angolo
(defun sorting (points center)
  (let ((pair-angle (add-angle center 
                               (sort (sort points #'< :key #'second) 
                                     #'< :key #'first))))
    (remove-angle (sort pair-angle #'< :key #'cdr))))

;;; Aggiustamento finale dell'ordinamento
(defun post-sorting (points center)
  (let ((new-points 
         (delete-item center
                      (concatenate 'list 
                                   (reverse (get-sublist1 
                                             (reverse 
                                              (append points (list center)))))
                                   (get-sublist2 
                                    (reverse 
                                     (append points (list center))))))))
    (cond ((= (length new-points)
              (length points)) new-points)
          (t points))))

(defun get-sublist1 (points)
  (cond ((= (length points) 1) nil)
        ((= (x (first points)) (x (second points))) (get-sublist1 
                                                     (rest points)))
        (t (rest points))))

(defun get-sublist2 (points)
  (cond ((= (length points) 1) nil)
        ((= (x (first points)) (x (second points))) (cons (first points)
                                                          (get-sublist2 
                                                           (rest points))))
        (t (list (first points)))))

(defun add-angle (center points)
  (cond ((null points) nil)
        (t (cons (cons (first points) 
                       (angle2d center (first points))) 
                 (add-angle center (rest points))))))

(defun remove-angle (points)
  (cond ((null points) nil)
        (t (cons (first (first points)) 
                 (remove-angle (rest points))))))

;;; Algoritmo accetta/rifiuta i punti
(defun accept-reject (points stack)
  (cond ((null points) stack)
        ((left (first (rest stack)) (first stack) (first points))
         (left-coll (first (rest stack)) 
                    (first stack) 
                    (first points) 
                    (rest stack) 
                    (rest points)) )
        (t (accept-reject points (rest stack)))))

;;; Diversa gestione di punti collineari e svolta a sinistra
(defun left-coll (a b c stack points)
  (cond ((left-on a b c) (accept-reject points (cons c 
                                                     (cons b stack))))
        ((is-coll a b c) (accept-reject points (cons (farther a b c) 
                                                     (cons (closer a b c) 
                                                           stack))))))

;;; Trova il punto piu' lontano da un punto dato
(defun farther (a b c)
  (cond ((= (x a) (x b) (x c)) (cond ((= (abs (- (y b) (y a))) 
                                         (max (abs (- (y b) (y a)))
                                              (abs (- (y c) (y a))))) b)
                                     (t c)))
        ((= (abs (- (x b) (x a))) 
            (max (abs (- (x b) (x a)))
                 (abs (- (x c) (x a))))) b)
        (t c)))

;;; Trova il punto piu' vicino da un punto dato
(defun closer (a b c)
  (cond ((= (x a) (x b) (x c)) (cond ((= (abs (- (y b) (y a))) 
                                         (min (abs (- (y b) (y a)))
                                              (abs (- (y c) (y a))))) b)
                                     (t c)))
        ((= (abs (- (x b) (x a))) 
            (min (abs (- (x b) (x a)))
                 (abs (- (x c) (x a))))) b)
        (t c)))