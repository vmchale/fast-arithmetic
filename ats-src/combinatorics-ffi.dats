#include "share/atspre_staload.hats"
#include "ats-src/combinatorics.dats"

%{^
#define ATS_MEMALLOC_LIBC
#include "ccomp/runtime/pats_ccomp_memalloc_libc.h"
#include "ccomp/runtime/pats_ccomp_runtime_memalloc.c"
%}

#define ATS_MAINATSFLAG 1

extern
fun choose_ats {n : nat}{ m : nat | m <= n } : (int(n), int(m)) -> Intinf =
  "mac#"

extern
fun permutations_ats {n : nat}{ m : nat | m <= n } : (int(n), int(m)) -> Intinf =
  "mac#"

extern
fun double_factorial_ats {n : nat} : int(n) -> Intinf =
  "mac#"

implement choose_ats (n, k) =
  choose(n, k)

implement permutations_ats (n, k) =
  choose(n, k)

implement double_factorial_ats (m) =
  dfact(m)