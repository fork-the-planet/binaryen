;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.

;; Check that TypeUpdating::handleNonDefaultableLocals handles locals with exact
;; reference types correctly, and in particular that it preserves the exactness
;; of the types.

;; RUN: wasm-opt %s -all --coalesce-locals -S -o - | filecheck %s

(module
 ;; CHECK:      (func $test (type $0) (param $0 (exact i31ref)) (result (ref exact i31))
 ;; CHECK-NEXT:  (local $1 (exact i31ref))
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (ref.as_non_null
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (block $l
 ;; CHECK-NEXT:   (local.set $1
 ;; CHECK-NEXT:    (ref.as_non_null
 ;; CHECK-NEXT:     (local.get $0)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (ref.as_non_null
 ;; CHECK-NEXT:   (local.get $1)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $test (param (exact i31ref)) (result (ref exact i31))
  (local $l (ref exact i31))
  ;; This dead set will be optimized out.
  (local.set $l
   (ref.as_non_null
    (local.get 0)
   )
  )
  (block $l
   ;; This remaining set does not structurally dominate the get.
   (local.set $l
    (ref.as_non_null
     (local.get 0)
    )
   )
  )
  ;; This will have to be fixed up and the local made nullable.
  (local.get $l)
 )
)
