;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; Run without global effects, and run with, and also run with but discard them
;; first (to check that discard works; that should be the same as without).

;; RUN: foreach %s %t wasm-opt -all                                                    --vacuum -S -o - | filecheck %s --check-prefix WITHOUT
;; RUN: foreach %s %t wasm-opt -all --generate-global-effects                          --vacuum -S -o - | filecheck %s --check-prefix INCLUDE
;; RUN: foreach %s %t wasm-opt -all --generate-global-effects --discard-global-effects --vacuum -S -o - | filecheck %s --check-prefix DISCARD

(module

  ;; WITHOUT:      (type $0 (func))

  ;; WITHOUT:      (type $1 (func (result i32)))

  ;; WITHOUT:      (type $2 (func (param i32)))

  ;; WITHOUT:      (import "a" "b" (func $import (type $0)))

  ;; WITHOUT:      (tag $tag)
  ;; INCLUDE:      (type $0 (func))

  ;; INCLUDE:      (type $1 (func (result i32)))

  ;; INCLUDE:      (type $2 (func (param i32)))

  ;; INCLUDE:      (import "a" "b" (func $import (type $0)))

  ;; INCLUDE:      (tag $tag)
  ;; DISCARD:      (type $0 (func))

  ;; DISCARD:      (type $1 (func (result i32)))

  ;; DISCARD:      (type $2 (func (param i32)))

  ;; DISCARD:      (import "a" "b" (func $import (type $0)))

  ;; DISCARD:      (tag $tag)
  (tag $tag)

  (import "a" "b" (func $import))

  ;; WITHOUT:      (func $main (type $0)
  ;; WITHOUT-NEXT:  (call $nop)
  ;; WITHOUT-NEXT:  (call $unreachable)
  ;; WITHOUT-NEXT:  (call $call-nop)
  ;; WITHOUT-NEXT:  (call $call-unreachable)
  ;; WITHOUT-NEXT:  (drop
  ;; WITHOUT-NEXT:   (call $unimportant-effects)
  ;; WITHOUT-NEXT:  )
  ;; WITHOUT-NEXT:  (call $throw)
  ;; WITHOUT-NEXT:  (call $throw-and-import)
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $main (type $0)
  ;; INCLUDE-NEXT:  (call $unreachable)
  ;; INCLUDE-NEXT:  (call $call-unreachable)
  ;; INCLUDE-NEXT:  (call $throw)
  ;; INCLUDE-NEXT:  (call $throw-and-import)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $main (type $0)
  ;; DISCARD-NEXT:  (call $nop)
  ;; DISCARD-NEXT:  (call $unreachable)
  ;; DISCARD-NEXT:  (call $call-nop)
  ;; DISCARD-NEXT:  (call $call-unreachable)
  ;; DISCARD-NEXT:  (drop
  ;; DISCARD-NEXT:   (call $unimportant-effects)
  ;; DISCARD-NEXT:  )
  ;; DISCARD-NEXT:  (call $throw)
  ;; DISCARD-NEXT:  (call $throw-and-import)
  ;; DISCARD-NEXT: )
  (func $main
    ;; Calling a function with no effects can be optimized away in INCLUDE (but
    ;; not WITHOUT or DISCARD, where the global effect info is not available).
    (call $nop)
    ;; Calling a function with effects cannot.
    (call $unreachable)
    ;; Calling something that calls something with no effects can be optimized
    ;; away, since we compute transitive effects
    (call $call-nop)
    ;; Calling something that calls something with effects cannot.
    (call $call-unreachable)
    ;; Calling something that only has unimportant effects can be optimized
    ;; (see below for details).
    (drop
      (call $unimportant-effects)
    )
    ;; A throwing function cannot be removed.
    (call $throw)
    ;; A function that throws and calls an import definitely cannot be removed.
    (call $throw-and-import)
  )

  ;; WITHOUT:      (func $cycle (type $0)
  ;; WITHOUT-NEXT:  (call $cycle)
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $cycle (type $0)
  ;; INCLUDE-NEXT:  (call $cycle)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $cycle (type $0)
  ;; DISCARD-NEXT:  (call $cycle)
  ;; DISCARD-NEXT: )
  (func $cycle
    ;; Calling a function with no effects in a cycle cannot be optimized out -
    ;; this must keep hanging forever.
    (call $cycle)
  )

  ;; WITHOUT:      (func $cycle-1 (type $0)
  ;; WITHOUT-NEXT:  (call $cycle-2)
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $cycle-1 (type $0)
  ;; INCLUDE-NEXT:  (call $cycle-2)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $cycle-1 (type $0)
  ;; DISCARD-NEXT:  (call $cycle-2)
  ;; DISCARD-NEXT: )
  (func $cycle-1
    ;; $cycle-1 and -2 form a cycle together, in which no call can be removed.
    (call $cycle-2)
  )

  ;; WITHOUT:      (func $cycle-2 (type $0)
  ;; WITHOUT-NEXT:  (call $cycle-1)
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $cycle-2 (type $0)
  ;; INCLUDE-NEXT:  (call $cycle-1)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $cycle-2 (type $0)
  ;; DISCARD-NEXT:  (call $cycle-1)
  ;; DISCARD-NEXT: )
  (func $cycle-2
    (call $cycle-1)
  )

  ;; WITHOUT:      (func $nop (type $0)
  ;; WITHOUT-NEXT:  (nop)
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $nop (type $0)
  ;; INCLUDE-NEXT:  (nop)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $nop (type $0)
  ;; DISCARD-NEXT:  (nop)
  ;; DISCARD-NEXT: )
  (func $nop
    (nop)
  )

  ;; WITHOUT:      (func $unreachable (type $0)
  ;; WITHOUT-NEXT:  (unreachable)
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $unreachable (type $0)
  ;; INCLUDE-NEXT:  (unreachable)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $unreachable (type $0)
  ;; DISCARD-NEXT:  (unreachable)
  ;; DISCARD-NEXT: )
  (func $unreachable
    (unreachable)
  )

  ;; WITHOUT:      (func $call-nop (type $0)
  ;; WITHOUT-NEXT:  (call $nop)
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $call-nop (type $0)
  ;; INCLUDE-NEXT:  (nop)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $call-nop (type $0)
  ;; DISCARD-NEXT:  (call $nop)
  ;; DISCARD-NEXT: )
  (func $call-nop
    ;; This call to a nop can be optimized out, as above, in INCLUDE.
    (call $nop)
  )

  ;; WITHOUT:      (func $call-unreachable (type $0)
  ;; WITHOUT-NEXT:  (call $unreachable)
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $call-unreachable (type $0)
  ;; INCLUDE-NEXT:  (call $unreachable)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $call-unreachable (type $0)
  ;; DISCARD-NEXT:  (call $unreachable)
  ;; DISCARD-NEXT: )
  (func $call-unreachable
    (call $unreachable)
  )

  ;; WITHOUT:      (func $unimportant-effects (type $1) (result i32)
  ;; WITHOUT-NEXT:  (local $x i32)
  ;; WITHOUT-NEXT:  (local.set $x
  ;; WITHOUT-NEXT:   (i32.const 100)
  ;; WITHOUT-NEXT:  )
  ;; WITHOUT-NEXT:  (return
  ;; WITHOUT-NEXT:   (local.get $x)
  ;; WITHOUT-NEXT:  )
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $unimportant-effects (type $1) (result i32)
  ;; INCLUDE-NEXT:  (local $x i32)
  ;; INCLUDE-NEXT:  (local.set $x
  ;; INCLUDE-NEXT:   (i32.const 100)
  ;; INCLUDE-NEXT:  )
  ;; INCLUDE-NEXT:  (return
  ;; INCLUDE-NEXT:   (local.get $x)
  ;; INCLUDE-NEXT:  )
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $unimportant-effects (type $1) (result i32)
  ;; DISCARD-NEXT:  (local $x i32)
  ;; DISCARD-NEXT:  (local.set $x
  ;; DISCARD-NEXT:   (i32.const 100)
  ;; DISCARD-NEXT:  )
  ;; DISCARD-NEXT:  (return
  ;; DISCARD-NEXT:   (local.get $x)
  ;; DISCARD-NEXT:  )
  ;; DISCARD-NEXT: )
  (func $unimportant-effects (result i32)
    (local $x i32)
    ;; Operations on locals should not prevent optimization, as when we return
    ;; from the function they no longer matter.
    (local.set $x
      (i32.const 100)
    )
    ;; A return is an effect that no longer matters once we exit the function.
    (return
      (local.get $x)
    )
  )

  ;; WITHOUT:      (func $call-throw-and-catch (type $0)
  ;; WITHOUT-NEXT:  (try $try
  ;; WITHOUT-NEXT:   (do
  ;; WITHOUT-NEXT:    (call $throw)
  ;; WITHOUT-NEXT:   )
  ;; WITHOUT-NEXT:   (catch_all
  ;; WITHOUT-NEXT:    (nop)
  ;; WITHOUT-NEXT:   )
  ;; WITHOUT-NEXT:  )
  ;; WITHOUT-NEXT:  (try $try0
  ;; WITHOUT-NEXT:   (do
  ;; WITHOUT-NEXT:    (call $throw-and-import)
  ;; WITHOUT-NEXT:   )
  ;; WITHOUT-NEXT:   (catch_all
  ;; WITHOUT-NEXT:    (nop)
  ;; WITHOUT-NEXT:   )
  ;; WITHOUT-NEXT:  )
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $call-throw-and-catch (type $0)
  ;; INCLUDE-NEXT:  (try $try0
  ;; INCLUDE-NEXT:   (do
  ;; INCLUDE-NEXT:    (call $throw-and-import)
  ;; INCLUDE-NEXT:   )
  ;; INCLUDE-NEXT:   (catch_all
  ;; INCLUDE-NEXT:    (nop)
  ;; INCLUDE-NEXT:   )
  ;; INCLUDE-NEXT:  )
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $call-throw-and-catch (type $0)
  ;; DISCARD-NEXT:  (try $try
  ;; DISCARD-NEXT:   (do
  ;; DISCARD-NEXT:    (call $throw)
  ;; DISCARD-NEXT:   )
  ;; DISCARD-NEXT:   (catch_all
  ;; DISCARD-NEXT:    (nop)
  ;; DISCARD-NEXT:   )
  ;; DISCARD-NEXT:  )
  ;; DISCARD-NEXT:  (try $try0
  ;; DISCARD-NEXT:   (do
  ;; DISCARD-NEXT:    (call $throw-and-import)
  ;; DISCARD-NEXT:   )
  ;; DISCARD-NEXT:   (catch_all
  ;; DISCARD-NEXT:    (nop)
  ;; DISCARD-NEXT:   )
  ;; DISCARD-NEXT:  )
  ;; DISCARD-NEXT: )
  (func $call-throw-and-catch
    (try
      (do
        ;; This call cannot be optimized out, as the target throws. However, the
        ;; entire try-catch can be, since the call's only effect is to throw,
        ;; and the catch_all catches that.
        (call $throw)
      )
      (catch_all)
    )
    (try
      (do
        ;; This call both throws and calls an import, and cannot be removed.
        (call $throw-and-import)
      )
      (catch_all)
    )
  )

  ;; WITHOUT:      (func $call-unreachable-and-catch (type $0)
  ;; WITHOUT-NEXT:  (try $try
  ;; WITHOUT-NEXT:   (do
  ;; WITHOUT-NEXT:    (call $unreachable)
  ;; WITHOUT-NEXT:   )
  ;; WITHOUT-NEXT:   (catch_all
  ;; WITHOUT-NEXT:    (nop)
  ;; WITHOUT-NEXT:   )
  ;; WITHOUT-NEXT:  )
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $call-unreachable-and-catch (type $0)
  ;; INCLUDE-NEXT:  (call $unreachable)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $call-unreachable-and-catch (type $0)
  ;; DISCARD-NEXT:  (try $try
  ;; DISCARD-NEXT:   (do
  ;; DISCARD-NEXT:    (call $unreachable)
  ;; DISCARD-NEXT:   )
  ;; DISCARD-NEXT:   (catch_all
  ;; DISCARD-NEXT:    (nop)
  ;; DISCARD-NEXT:   )
  ;; DISCARD-NEXT:  )
  ;; DISCARD-NEXT: )
  (func $call-unreachable-and-catch
    (try
      (do
        ;; This call has a non-throw effect. We can optimize away the try-catch
        ;; (since no exception can be thrown anyhow), but we must leave the
        ;; call.
        (call $unreachable)
      )
      (catch_all)
    )
  )

  ;; WITHOUT:      (func $call-throw-or-unreachable-and-catch (type $2) (param $x i32)
  ;; WITHOUT-NEXT:  (try $try
  ;; WITHOUT-NEXT:   (do
  ;; WITHOUT-NEXT:    (if
  ;; WITHOUT-NEXT:     (local.get $x)
  ;; WITHOUT-NEXT:     (then
  ;; WITHOUT-NEXT:      (call $throw)
  ;; WITHOUT-NEXT:     )
  ;; WITHOUT-NEXT:     (else
  ;; WITHOUT-NEXT:      (call $unreachable)
  ;; WITHOUT-NEXT:     )
  ;; WITHOUT-NEXT:    )
  ;; WITHOUT-NEXT:   )
  ;; WITHOUT-NEXT:   (catch_all
  ;; WITHOUT-NEXT:    (nop)
  ;; WITHOUT-NEXT:   )
  ;; WITHOUT-NEXT:  )
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $call-throw-or-unreachable-and-catch (type $2) (param $x i32)
  ;; INCLUDE-NEXT:  (try $try
  ;; INCLUDE-NEXT:   (do
  ;; INCLUDE-NEXT:    (if
  ;; INCLUDE-NEXT:     (local.get $x)
  ;; INCLUDE-NEXT:     (then
  ;; INCLUDE-NEXT:      (call $throw)
  ;; INCLUDE-NEXT:     )
  ;; INCLUDE-NEXT:     (else
  ;; INCLUDE-NEXT:      (call $unreachable)
  ;; INCLUDE-NEXT:     )
  ;; INCLUDE-NEXT:    )
  ;; INCLUDE-NEXT:   )
  ;; INCLUDE-NEXT:   (catch_all
  ;; INCLUDE-NEXT:    (nop)
  ;; INCLUDE-NEXT:   )
  ;; INCLUDE-NEXT:  )
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $call-throw-or-unreachable-and-catch (type $2) (param $x i32)
  ;; DISCARD-NEXT:  (try $try
  ;; DISCARD-NEXT:   (do
  ;; DISCARD-NEXT:    (if
  ;; DISCARD-NEXT:     (local.get $x)
  ;; DISCARD-NEXT:     (then
  ;; DISCARD-NEXT:      (call $throw)
  ;; DISCARD-NEXT:     )
  ;; DISCARD-NEXT:     (else
  ;; DISCARD-NEXT:      (call $unreachable)
  ;; DISCARD-NEXT:     )
  ;; DISCARD-NEXT:    )
  ;; DISCARD-NEXT:   )
  ;; DISCARD-NEXT:   (catch_all
  ;; DISCARD-NEXT:    (nop)
  ;; DISCARD-NEXT:   )
  ;; DISCARD-NEXT:  )
  ;; DISCARD-NEXT: )
  (func $call-throw-or-unreachable-and-catch (param $x i32)
    ;; This try-catch-all's body will either call a throw or an unreachable.
    ;; Since we have both possible effects, we cannot optimize anything here.
    (try
      (do
        (if
          (local.get $x)
          (then
            (call $throw)
          )
          (else
            (call $unreachable)
          )
        )
      )
      (catch_all)
    )
  )

  ;; WITHOUT:      (func $throw (type $0)
  ;; WITHOUT-NEXT:  (throw $tag)
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $throw (type $0)
  ;; INCLUDE-NEXT:  (throw $tag)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $throw (type $0)
  ;; DISCARD-NEXT:  (throw $tag)
  ;; DISCARD-NEXT: )
  (func $throw
    (throw $tag)
  )

  ;; WITHOUT:      (func $throw-and-import (type $0)
  ;; WITHOUT-NEXT:  (throw $tag)
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $throw-and-import (type $0)
  ;; INCLUDE-NEXT:  (throw $tag)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $throw-and-import (type $0)
  ;; DISCARD-NEXT:  (throw $tag)
  ;; DISCARD-NEXT: )
  (func $throw-and-import
    (if
      (i32.const 1)
      (then
        (throw $tag)
      )
      (else
        (call $import)
      )
    )
  )

  ;; WITHOUT:      (func $cycle-with-unknown-call (type $0)
  ;; WITHOUT-NEXT:  (call $cycle-with-unknown-call)
  ;; WITHOUT-NEXT:  (call $import)
  ;; WITHOUT-NEXT: )
  ;; INCLUDE:      (func $cycle-with-unknown-call (type $0)
  ;; INCLUDE-NEXT:  (call $cycle-with-unknown-call)
  ;; INCLUDE-NEXT:  (call $import)
  ;; INCLUDE-NEXT: )
  ;; DISCARD:      (func $cycle-with-unknown-call (type $0)
  ;; DISCARD-NEXT:  (call $cycle-with-unknown-call)
  ;; DISCARD-NEXT:  (call $import)
  ;; DISCARD-NEXT: )
  (func $cycle-with-unknown-call
    ;; This function can not only call itself recursively, but also calls an
    ;; import. We should not remove anything here, and not error during the
    ;; analysis (this guards against a bug where the import would make us toss
    ;; away the effects object, and the infinite loop makes us set a property on
    ;; that object, so it must check the object still exists).
    (call $cycle-with-unknown-call)
    (call $import)
  )
)
