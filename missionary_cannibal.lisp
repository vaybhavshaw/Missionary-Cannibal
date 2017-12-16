;;;; VAYBHAV SHAW	shaw0162@umn.edu
;;;; LISP Assignment Question 1
;;;; Missionary Cannibal Problem
;;;; December 7, 2017
;;;; FILE NAME : missionary_cannibal.lisp

;;;;;;;;; INSTRUCTIONS TO RUN ;;;;;;;;;;
;; Navigate to the location of the file
;; RUN	clisp missionary_cannibal.lisp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; User input of the number of missionaries/cannibals and the boat size
(print "Enter the number of Missionaries and Cannibals: " )
(defvar number-mis-can (read)) 
(print "Enter the Boat Size : " )
(defvar size-of-boat (read)) 

;;;;;;;;;;;;;;;;;;;;;;;;;;; Goal State Definition ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (index 0 -> 0 missionaries on left bank) 
;; (index 1 -> 0 cannibals on the left bank) 
;; (index 2 -> location of the boat left bank -> 0 for left bank -> 1 for right bank)
(defvar goal '(0 0 0)) 

;;;;;;;;;;;;;;;;;;;;;;;;;;; Current State Definition ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (index 0 -> number of missionaries on left bank) 
;; (index 1 -> number of cannibals on the left bank) 
;; (index 2 -> current location of boat -> 0 for left bank -> 1 for right bank)
(defvar current-state '()) 


;;; Buiding the current-state list using the user input 
(push 0 current-state)
(push number-mis-can current-state)
(push number-mis-can current-state)

;;; total-missionaries : stores the initial number of missionaries on the left bank
(defvar total-missionaries (car current-state)) 

;;;;;;;;;;;;;;;;;;;; Variable : valid ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; global variable to store whether a given state is valid or not
;; 0 -> state not valid
;; 1 -> state is valid
(defparameter valid 1) 						   	


(defvar closed-list '()) 		 ;; list to store all the traversed states to avoid loops
(push current-state closed-list) ;; pushes the initial starting stated to the traversed list (closed-list) 
(defvar open-list '())			 ;; stores the available moves/states that the boat can take



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Function Name : vaild-state() ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Descriptions
;; 1. Checks whether a received state is a valid. 
;; 2. Sets global variable 'valid' to 1 if it is a valid state, else sets it as 0
;; 3. Determines which shore the boat is on
;; 4. Stores the number of missionaries in the state that is passed
;; 5  Stores the number of cannibals in the state that is passed 
;; 6. Stores the number of missionaries in the opposite bank	
;; 7. Stores the number of cannibals in the opposite bank
;; 8. Sets 'valid' to false if the number of Missionaries or Cannibals in the state are negative
;; 9. Sets 'valid' to false if the number of Missionaries < Cannibals, and the number of missionaries is not equal to 0
;; 10.Sets 'valid' to false if number of Missionaries < Cannibals on opposite bank, and the number of missionaries != 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun valid-state(state)
	(defparameter shore (caddr state))		 
	(defparameter missionaries (car state))	 
	(defparameter cannibals (cadr state))	 	
	(defparameter missionaries-opposite (- total-missionaries (car state)))	
	(defparameter cannibals-opposite (- total-missionaries (cadr state)))		

	(setf valid 1)																												   	
	(if ( or (< (car state) 0) (< (cadr state) 0))
		(setf valid 0)
	)

	(if (and (not (= missionaries 0)) (< missionaries cannibals)) 
		(setf valid 0)
	)

	(if (and (not (= missionaries-opposite 0)) (< missionaries-opposite cannibals-opposite)) 
		(setf valid 0)
	)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Function : generate-states ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Details
;; 1. Variable 'new-state' : Stores the temporary state that is created, which if valid is added to the open-list
;; 2. Variable 'boat-pos'  : Stores the current position fo the boat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun generate-states(state i j)
	(defparameter new-state (list 0 0 0)) 
	(defparameter boat-pos (nth 2 state))
	
	;;; Creates the new state space if the boat is on the left bank
	(if (= boat-pos 0)
		(progn
			(setf (nth 0 new-state) (- (car state) i))
			(setf (nth 1 new-state) (- (cadr state) j))
			(setf (nth 2 new-state) 1)
		)
	)

	;;; Creates the new state space if the boat is on the right bank
	(if (= boat-pos 1)
		(progn
			(setf (nth 0 new-state) (+ (car state) i))
			(setf (nth 1 new-state) (+ (cadr state) j))
			(setf (nth 2 new-state) 0)
		)
	)

	;;; Calls the valid-state function to check the validity of the 'new-state'
	(valid-state new-state)  
	
	;;; Adds new-state to open-list if the new-state is not present in the closed-list and if it is valid
	(defparameter val (position new-state closed-list :test #'equal))
	(if ( and (= valid 1) (eq val Nil))
		(progn
			(push new-state open-list)
		)
	)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Function : state-combinations ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Details
;; 1. Generates all possible (missionary, cannibal) combinations that can be sent across the river, depending upon the boat size
;; 2. Passes the (missionary, cannibal) combinations to generate-states() for generating children states
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
(defun state-combinations(state)
	(setf open-list '())
	(loop for i from 0 to size-of-boat
	do (
			loop for j from 0 to size-of-boat
			do (progn
					(if (and (not (and (= i 0) (= j 0))) (<= (+ i j) size-of-boat))
						(generate-states state i j)	 
					)

			   )
			
		)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;; Funtion : state-print ;;;;;;;;;;;;;;;;;;;;;;
;; Details : Printing the moves that are stores in the closed-list ;;
(defun state-print(closed-list)
	(if (equal closed-list Nil)
		(exit)
	)

	(defparameter state (car closed-list))
	(defparameter next-state (cadr closed-list))
	(defparameter m-movement (- (car state)(car next-state)))
	(defparameter c-movement (- (cadr state)(cadr next-state)))
	(if (eq (caddr closed-list) Nil)
		(progn
			(format t "(~a,~a) ---------- (~a,~a) ---------> (~a,~a) ~%" 
			(car state) (cadr state) m-movement c-movement total-missionaries total-missionaries)
			(exit)
		)
	)
	(if(= (caddr state) 0)
		(progn
			(format t "(~a,~a) ---------- (~a,~a) ---------> (~a,~a) ~%" 
			(car state) (cadr state) m-movement c-movement (- total-missionaries (car state)) (- total-missionaries (cadr state)))
		)
	)
	(if(= (caddr state) 1)
		(progn
			(format t "(~a,~a) <--------- (~a,~a) ---------- (~a,~a) ~%" 
			(car state) (cadr state) m-movement c-movement (- total-missionaries (car state)) (- total-missionaries (cadr state)))
		)
	)

	(setf closed-list (cdr closed-list))
	(state-print closed-list)

) ;; end of state-print()


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Generative Loop ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Details  :-
;; 1. Loop executes until the goal state is reached
;; 2. Passes current-state to the state-combinations() to generate states and take the most optimal move 
;; 3. Sorts the generated open-list() in ascending order based on number of missionaries
;; 4. If the number of missionaries being sent is equal for a number of states, it sorts those sates based on the number of cannibals
;; Variable 'pop-val' : Stores the most optimal state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(loop
	(state-combinations current-state)				
	(sort open-list #'<= :key #'first)				
	
	
	(defparameter  new-child (car open-list))		
	(defparameter fchild (nth 0 new-child))
	(defparameter sort-list '())
	(loop for x in open-list
		do (progn
				(defparameter nthval (nth 0 x))
				(if (= nthval fchild)
					(push x sort-list)
				)
			)
	)
	(sort sort-list #'<= :key #'second)

	(defparameter pop-val (pop sort-list))	
	(push pop-val closed-list)				;; adding pop-val to closed-state, as it will be called next
	(setf current-state pop-val)			;; assigning pop-val to current-state
	(when (equal pop-val '(0 0 1))(return)) ;; check for the goal-state
)


;; reversing closed-list to store the exact order of the traversal	
(setf closed-list (reverse closed-list))							

(format t "~%LEFT BANK -------- MOVEMENT -------- RIGHT BANK ~%") 		

;; Calling function : state-print()  to print the order of the traversed states
(state-print closed-list)												



