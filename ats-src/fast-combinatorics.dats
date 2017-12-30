#define ATS_MAINATSFLAG 1

#include "share/atspre_staload.hats"

staload "libats/SATS/Number/real.sats"
staload "libats/SATS/Number/float.sats"
staload "libats/libc/SATS/math.sats"

fnx fact {n : nat} .<n>. (k : int(n)) :<> int =
  case+ k of
    | 0 => 1
    | k =>> fact(k - 1) * k

fnx dfact {n : nat} .<n>. (k : int(n)) :<> int =
  case+ k of
    | 0 => 1
    | 1 => 1
    | k =>> k * dfact(k - 2)

// TODO make this more versatile?
fn choose {n : nat}{ m : nat | m <= n } (n : int(n), k : int(m)) : int =
  let
    fun numerator_loop { m : nat | m > 1 } .<m>. (i : int(m)) : int =
      case+ i of
        | 1 => n
        | 2 => (n - 1) * n
        | i =>> (n + 1 - i) * numerator_loop(i - 1)
  in
    case+ k of
      | 0 => 1
      | 1 => n
      | k =>> numerator_loop(k) / fact(k)
  end

fun is_prime(k : intGt(0)) : bool =
  let
    var pre_bound: int = g0float2int(sqrt_float(g0int2float_int_float(k)))
    var bound = g1ofg0(pre_bound) : [ n : nat ] int(n) 
    
    fun loop {n : nat}{ m : nat | m >= n } .<m - n>. (i : int(n), bound : int(m)) : bool =
      if i mod k = 0 then
        false
      else
        if i < bound then
          true && loop(i + 1, bound)
        else
          true
  in
    loop(1, bound)
  end

extern
fun choose_ats {n : nat}{ m : nat | m <= n } : (int(n), int(m)) -> int =
  "mac#"

implement choose_ats (n, k) =
  choose(n, k)

extern
fun double_factorial {n : nat} : int(n) -> int =
  "mac#"

implement double_factorial (m) =
  dfact(m)

extern
fun factorial_ats {n : nat} : int(n) -> int =
  "mac#"

implement factorial_ats (m) =
  fact(m)
