; extends

; Highlight Rust expressions that allocate on the heap.
;
; This is a best-effort, pattern-based list. A real allocation happens inside a
; function body, so it is invisible to the syntax tree: `Vec::new()` does not
; allocate, `vec![1, 2]` does, and `Foo::new()` may or may not. rust-analyzer
; exposes no "allocates" marker either, so the patterns below are limited to
; constructs from the standard library whose behaviour is known.
;
; Captured as `@rust.alloc`. The matching highlight group is defined in
; lua/plugins/rust.lua.
;
; Known over-reporting: `.clone()` on a `Copy` type, `.collect()` into a
; non-allocating collection, and `with_capacity(0)` allocate nothing.

; Macros that build an owned value: vec![...], format!(...)
((macro_invocation
  macro: (identifier) @rust.alloc)
  (#any-of? @rust.alloc "vec" "format"))

; Constructors that always allocate: Box::new, Rc::new, Arc::new, CString::new
(call_expression
  function: (scoped_identifier
    path: (identifier) @_owner
    name: (identifier) @_name) @rust.alloc
  (#any-of? @_owner "Box" "Rc" "Arc" "CString")
  (#eq? @_name "new"))

; Owned values built from borrowed data: String::from, PathBuf::from, ...
; The owner is checked because a bare `from` is far too broad; `u64::from` and
; `Duration::from_secs` allocate nothing.
; `Vec::new`, `String::new` and `HashMap::new` are deliberately absent: they
; allocate nothing until the first element is pushed.
(call_expression
  function: (scoped_identifier
    path: (identifier) @_owner
    name: (identifier) @_name) @rust.alloc
  (#any-of? @_owner
    "String" "PathBuf" "OsString" "Vec" "VecDeque" "HashMap" "HashSet"
    "BTreeMap" "BTreeSet" "BinaryHeap")
  (#eq? @_name "from"))

; The same, written fully qualified: `std::path::PathBuf::from("/tmp")`. Here
; the path is itself a `scoped_identifier`, so the owner is its final segment.
(call_expression
  function: (scoped_identifier
    path: (scoped_identifier
      name: (identifier) @_owner)
    name: (identifier) @_name) @rust.alloc
  (#any-of? @_owner
    "String" "PathBuf" "OsString" "Vec" "VecDeque" "HashMap" "HashSet"
    "BTreeMap" "BTreeSet" "BinaryHeap")
  (#eq? @_name "from"))

; Reserved capacity and iterator collection. The owner is left unconstrained
; here: these two names allocate whoever calls them, and skipping `path:` also
; matches turbofish forms such as `Vec::<u8>::with_capacity(8)`, where the path
; is a `generic_type` rather than a plain identifier.
(call_expression
  function: (scoped_identifier
    name: (identifier) @_name) @rust.alloc
  (#any-of? @_name "with_capacity" "from_iter"))

; The same two, called with an explicit type argument:
; `Vec::with_capacity::<u8>(8)`
(call_expression
  function: (generic_function
    function: (scoped_identifier
      name: (identifier) @_name)) @rust.alloc
  (#any-of? @_name "with_capacity" "from_iter"))

; Methods that hand back an owned, heap-backed value
((call_expression
  function: (field_expression
    field: (field_identifier) @rust.alloc))
  (#any-of? @rust.alloc
    "to_string" "to_owned" "to_vec" "to_path_buf" "clone" "collect"
    "into_boxed_slice" "into_boxed_str" "into_vec" "into_string"
    "repeat" "concat" "join"))
