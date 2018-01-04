#include "share/atspre_staload.hats"
#include "ats-src/numerics.dats"
#include "contrib/atscntrb-hx-intinf/DATS/intinf_t.dats"
#include "contrib/atscntrb-hx-intinf/DATS/intinf_vt.dats"

staload "libats/libc/SATS/math.sats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/atscntrb-hx-intinf/SATS/intinf.sats"
staload "contrib/atscntrb-hx-intinf/SATS/intinf_t.sats"

#define ATS_MAINATSFLAG 1

// Existential types for even and odd numbers. These are only usable with the
// ATS library.
typedef Even = [ n : nat ] int(2 * n)

typedef Odd = [ n : nat ] int(2 * n+1)

// m | n
fn divides(m : int, n : int) :<> bool =
  n % m = 0

fnx gcd {k : nat}{l : nat} (m : int(l), n : int(k)) : int =
  if n > 0 then
    gcd(n, witness(m % n))
  else
    m

fn lcm {k : nat}{l : nat} (m : int(l), n : int(k)) : int =
  (m / gcd(m, n)) * n

// stream all divisors of an integer.
fn divisors(n : intGte(1)) : stream_vt(int) =
  let
    fun loop {k : nat}{ m : nat | m > 0 && k >= m } .<k-m>. (n : int(k), acc : int(m)) : stream_vt(int) =
      if acc >= n then
        $ldelay(stream_vt_cons(acc, $ldelay(stream_vt_nil)))
      else
        if n % acc = 0 then
          $ldelay(stream_vt_cons(n, loop(n, acc + 1)))
        else
          $ldelay(stream_vt_nil)
  in
    loop(n, 1)
  end

fn count_divisors(n : intGte(1)) :<> int =
  let
    fun loop {k : nat}{ m : nat | m > 0 && k >= m } .<k-m>. (n : int(k), acc : int(m)) :<> int =
      if acc >= n then
        1
      else
        if n % acc = 0 then
          1 + loop(n, acc + 1)
        else
          loop(n, acc + 1)
  in
    loop(n, 1)
  end

fn sum_divisors(n : intGte(1)) :<> int =
  let
    fun loop {k : nat}{ m : nat | m > 0 && k >= m } .<k-m>. (n : int(k), acc : int(m)) :<> int =
      if acc >= n then
        0
      else
        if n % acc = 0 then
          acc + loop(n, acc + 1)
        else
          loop(n, acc + 1)
  in
    loop(n, 1)
  end

// TODO proofs of correctness like HX for fibonacci numbers?
fn is_perfect(n : intGte(1)) :<> bool =
  sum_divisors(n) = n

// distinct prime divisors
fn little_omega(n : intGte(1)) :<> int =
  let
    fun loop {k : nat}{ m : nat | m > 0 && k >= m } .<k-m>. (n : int(k), acc : int(m)) :<> int =
      if acc >= n then
        if is_prime(n) then
          1
        else
          0
      else
        if n % acc = 0 && is_prime(acc) then
          1 + loop(n, acc + 1)
        else
          loop(n, acc + 1)
  in
    loop(n, 1)
  end

// Euler's totient function.
fn totient(n : intGte(1)) : int =
  case+ n of
    | 1 => 1
    | n =>> 
      begin
        let
          fnx loop { k : nat | k >= 2 }{ m : nat | m > 0 && k >= m } .<k-m>. (i : int(m), n : int(k)) : int =
            if i >= n then
              if is_prime(n) then
                n - 1
              else
                n
            else
              if n % i = 0 && is_prime(i) && i != n then
                (loop(i + 1, n) / i) * (i - 1)
              else
                loop(i + 1, n)
        in
          loop(1, n)
        end
      end

// The sum of all φ(m) for m between 1 and n 
fun totient_sum(n : intGte(1)) : Intinf =
  let
    fnx loop { n : nat | n >= 1 }{ m : nat | m >= n } .<m-n>. (i : int(n), bound : int(m)) : Intinf =
      if i < bound then
        loop(i + 1, bound) + witness(totient(i))
      else
        int2intinf(witness(totient(i)))
  in
    loop(1, n)
  end