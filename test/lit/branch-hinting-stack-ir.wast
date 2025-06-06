;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; Enable StackIR opts with --shrink-level=1, and verify we can roundtrip an
;; annotation on stacky code.

;; RUN: wasm-opt -all --shrink-level=1 --roundtrip %s -S -o - | filecheck %s

(module
 ;; CHECK:      (type $0 (func))

 ;; CHECK:      (func $empty-if (type $0)
 ;; CHECK-NEXT:  (local $1 i32)
 ;; CHECK-NEXT:  (local $scratch i32)
 ;; CHECK-NEXT:  (@metadata.code.branch_hint "\00")
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (block (result i32)
 ;; CHECK-NEXT:    (local.set $scratch
 ;; CHECK-NEXT:     (i32.const 0)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (drop
 ;; CHECK-NEXT:     (i32.const 1)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (local.get $scratch)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (else
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $empty-if
  (local $1 i32)
  ;; Several stack IR opts work here, leading to the if arms being empty (nops
  ;; removed) and the local.set/get vanishing, leaving stacky code like this:
  ;;
  ;;  i32.const 0  ;; read by the if, past the other const and drop
  ;;  i32.const 1
  ;;  drop
  ;;  if
  ;;  else
  ;;  end
  ;;
  ;; As a result we have a segment before us that was heavily modified (with the
  ;; local.set), and the if body is empty. This should not cause an error when
  ;; computing the if's binary location for the hint, and the hint should
  ;; remain.
  (local.set $1
   (i32.const 0)
  )
  (drop
   (i32.const 1)
  )
  (@metadata.code.branch_hint "\00")
  (if
   (local.get $1)
   (then
    (nop)
   )
   (else
    (nop)
   )
  )
 )
)

