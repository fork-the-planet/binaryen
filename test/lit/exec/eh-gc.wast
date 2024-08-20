;; NOTE: Assertions have been generated by update_lit_checks.py --output=fuzz-exec and should not be edited.

;; RUN: wasm-opt %s -all --fuzz-exec -q -o /dev/null 2>&1 | filecheck %s

(module
 (tag $tag (param externref))

 ;; CHECK:      [fuzz-exec] calling catch-null
 (func $catch-null (export "catch-null")
  (block $tryend
   ;; The actual resulting value type is more refined than externref (it is a
   ;; bottom type) which we should not error on.
   (drop
    (block $catch (result externref)
      (try_table (catch $tag $catch)
       (throw $tag
        (ref.null noextern)
       )
      )
      (br $tryend)
    )
   )
  )
 )
)
;; CHECK:      [fuzz-exec] calling catch-null
;; CHECK-NEXT: [fuzz-exec] comparing catch-null
