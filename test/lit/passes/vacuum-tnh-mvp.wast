;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --vacuum -tnh -S -o - | filecheck %s

(module
  (memory 1 1)

  ;; CHECK:      (func $block-unreachable-but-call
  ;; CHECK-NEXT:  (i32.store
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $block-unreachable-but-call)
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  (func $block-unreachable-but-call
    ;; A call cannot be removed, even if it leads to a trap, since it might have
    ;; non-trap effects (like mayNotReturn). We can remove the store after it,
    ;; though.
    ;;
    ;; This duplicates a test in vacuum-tnh but in MVP mode (to check for a
    ;; possible bug with the throws effect which varies based on features).
    (i32.store
      (i32.const 0)
      (i32.const 1)
    )
    (call $block-unreachable-but-call)
    (i32.store
      (i32.const 2)
      (i32.const 3)
    )
    (unreachable)
  )
)