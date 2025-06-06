;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt -all %s -S -o - | filecheck %s


(module
 ;; CHECK:      (type $function (func (param i64)))
 (type $function (func (param i64)))
 ;; CHECK:      (type $cont (cont $function))
 (type $cont (cont $function))
 ;; CHECK:      (type $function_2 (func (param i32 (ref $cont))))
 (type $function_2 (func (param i32 (ref $cont))))
 ;; CHECK:      (type $cont_2 (cont $function_2))
 (type $cont_2 (cont $function_2))
 ;; CHECK:      (tag $tag (type $4))
 (tag $tag)

 ;; CHECK:      (func $switch (type $5) (param $c (ref $cont_2)) (result i64)
 ;; CHECK-NEXT:  (switch $cont_2 $tag
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:   (local.get $c)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $switch (param $c (ref $cont_2)) (result i64)
  (switch $cont_2 $tag
   (i32.const 0)
   (local.get $c)
  )
 )
)
