;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; RUN: wasm-merge %s first %s.second second --rename-export-conflicts -all -S -o - | filecheck %s

;; Test that we fuse imports to exports across modules.
;;
;; We test functions and memories here, and not every possible entity in a
;; comprehensive way, since they all go through the same code path. (But we test
;; two to at least verify we differentiate them.)
;;
;; We also test importing memories and tags from another file than the
;; first one, which was initially broken.

(module
  ;; The first two imports here will be resolved to direct calls into the
  ;; second module's merged contents.
  (import "second" "foo" (func $other.foo))

  (import "second" "bar" (func $other.bar))

  (import "second" "mem" (memory $other.mem 1))

  ;; This import will remain unresolved.
  ;; CHECK:      (type $0 (func))

  ;; CHECK:      (type $1 (func (result i32)))

  ;; CHECK:      (import "third" "missing" (func $other.missing (type $0)))
  (import "third" "missing" (func $other.missing))

  ;; CHECK:      (memory $first.mem 2)

  ;; CHECK:      (memory $second.mem 2)

  ;; CHECK:      (tag $exn (type $0))

  ;; CHECK:      (export "foo" (func $first.foo))

  ;; CHECK:      (export "bar" (func $bar))

  ;; CHECK:      (export "keepalive" (func $keepalive))

  ;; CHECK:      (export "exn" (tag $exn))

  ;; CHECK:      (export "mem" (memory $first.mem))

  ;; CHECK:      (export "foo_5" (func $second.foo))

  ;; CHECK:      (export "bar_6" (func $bar_6))

  ;; CHECK:      (export "keepalive2" (func $keepalive2))

  ;; CHECK:      (export "keepalive3" (func $keepalive3))

  ;; CHECK:      (export "mem_9" (memory $second.mem))

  ;; CHECK:      (func $first.foo (type $0)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $second.foo)
  ;; CHECK-NEXT: )
  (func $first.foo (export "foo")
    (drop
      (i32.const 1)
    )
    (call $other.foo)
  )

  ;; CHECK:      (func $bar (type $0)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 2)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $bar_6)
  ;; CHECK-NEXT:  (call $other.missing)
  ;; CHECK-NEXT: )
  (func $bar (export "bar")
    (drop
      (i32.const 2)
    )
    (call $other.bar)
    (call $other.missing)
  )

  ;; CHECK:      (func $keepalive (type $1) (result i32)
  ;; CHECK-NEXT:  (i32.load $second.mem
  ;; CHECK-NEXT:   (i32.const 10)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $keepalive (export "keepalive") (result i32)
    ;; Load from the memory imported from the second module.
    (i32.load $other.mem
      (i32.const 10)
    )
  )

  (memory $first.mem 2)

  (export "mem" (memory $first.mem))

  (tag $exn (export "exn"))
)
;; CHECK:      (func $second.foo (type $0)
;; CHECK-NEXT:  (call $first.foo)
;; CHECK-NEXT:  (drop
;; CHECK-NEXT:   (i32.const 3)
;; CHECK-NEXT:  )
;; CHECK-NEXT: )

;; CHECK:      (func $bar_6 (type $0)
;; CHECK-NEXT:  (call $bar)
;; CHECK-NEXT:  (drop
;; CHECK-NEXT:   (i32.const 4)
;; CHECK-NEXT:  )
;; CHECK-NEXT: )

;; CHECK:      (func $keepalive2 (type $1) (result i32)
;; CHECK-NEXT:  (i32.load $first.mem
;; CHECK-NEXT:   (i32.const 10)
;; CHECK-NEXT:  )
;; CHECK-NEXT: )

;; CHECK:      (func $keepalive3 (type $0)
;; CHECK-NEXT:  (throw $exn)
;; CHECK-NEXT: )
