(define (domain sokorobotto)
(:requirements :typing)
	(:types shipment order saleitem
          location
          robot pallette - object
  )

  (:predicates

    ;orders
    (orders ?o - order ?i - saleitem)

    ;shipment
    (unstarted ?s - shipment)
    (finished ?s - shipment)  ; added to track if the shipment is finished
    (ships ?s - shipment ?o - order)
    (includes ?s - shipment ?i - saleitem)

    ;objects
    (contains ?p - pallette ?i - saleitem)
    (free ?r - robot)

    ;location
    (at ?ob - object ?l - location)
    (no-pallette ?l - location)
    (no-robot ?l - location)
    
    (connected ?l - location ?l - location)
    (packing-location ?l - location)
    (available ?l - location)
    	
  )
  

  ; move robot from one location to another
  (:action move_robot

    :parameters (?l1 - location ?l2 - location ?r - robot)
    :precondition (and (at ?r ?l1) (not (no-robot ?l1)) (free ?r) (connected ?l1 ?l2) 
                       (not (at ?r ?l2)) (no-robot ?l2) )
    :effect (and (at ?r ?l2)
                 (not (no-robot ?l2))
                 (not (at ?r ?l1))  
                 (no-robot ?l1)
            )
  )
   
  ; robot moves palette from one location to another
  (:action move_palette

    :parameters (?l1 - location ?l2 - location ?r - robot ?p - pallette)
    :precondition (and (free ?r) (not (no-robot ?l1)) (at ?r ?l1)
                       (not (no-pallette ?l1)) (at ?p ?l1) (connected ?l1 ?l2) 
                       (no-robot ?l2) (not (at ?r ?l2))
                       (no-pallette ?l2) (not (at ?p ?l2))
                  )
    :effect (and (no-robot ?l1) 
                 (no-pallette ?l1)
                 (not (no-robot ?l2))
                 (not (no-pallette ?l2))
                 (at ?r ?l2)
                 (at ?p ?l2)
                 (not (at ?r ?l1))
                 (not (at ?p ?l1))
            )
  )
  
  ; start the shipment of one order
  (:action start_ship
    :parameters (?l - location ?s - shipment ?o - order)
    :precondition (and (ships ?s ?o) (unstarted ?s) (not (finished ?s)) 
                       (packing-location ?l) (available ?l)
                  )
    :effect (and (not (unstarted ?s))
                 (not (available ?l))
            )
  )

  ; add items to the shipment from the pallette   
  (:action add_to_ship
    :parameters (?l - location ?s - shipment ?o - order ?i - saleitem ?p - pallette)
    :precondition (and (ships ?s ?o) (orders ?o ?i) (not (includes ?s ?i))  
                       (packing-location ?l)
                       (at ?p ?l) (contains ?p ?i)  
                  )
    :effect (and (includes ?s ?i) 
                 (not (contains ?p ?i))
            )
  )
   
  ; finish the shipment of order 
  (:action finish_ship
    :parameters (?l - location ?s - shipment ?o - order)
    :precondition (and (ships ?s ?o) (not (unstarted ?s)) (not (finished ?s)))
    :effect (and (finished ?s) 
                 (available ?l) 
            )
  )

)