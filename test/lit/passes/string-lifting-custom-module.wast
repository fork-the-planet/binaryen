;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; Similar to string-lifting but the strings are imported from a
;; custom module name.

;; RUN: foreach %s %t wasm-opt -all --string-lifting --pass-arg=string-constants-module@strings -S -o - | filecheck %s

(module
  ;; CHECK:      (type $0 (func))

  ;; CHECK:      (import "\'" "foo" (global $string_foo (ref extern)))
  (import "\'" "foo" (global $string_foo (ref extern)))

  ;; CHECK:      (import "strings" "bar" (global $string_bar (ref extern)))
  (import "strings" "bar" (global $string_bar (ref extern)))

  ;; CHECK:      (func $func (type $0)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (global.get $string_foo)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (string.const "bar")
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $func
    ;; The first string has the default "'" module name, but we overrode it, so
    ;; nothing changes.
    (drop
      (global.get $string_foo)
    )
    ;; Here we imported with the right one given the pass-arg, so we turn this
    ;; into a string.const.
    (drop
      (global.get $string_bar)
    )
  )
)
