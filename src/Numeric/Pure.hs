{-# LANGUAGE CPP #-}

-- | Pure Haskell functions. These tend to be more general than the equivalents
-- in ATS.
module Numeric.Pure ( -- * Useful functions
                      derangement
                    -- * Functions exported for testing and benchmarking
                    , hsIsPrime
                    , hsFibonacci
                    ) where

#if __GLASGOW_HASKELL__ <= 784
import           Control.Applicative
#endif

{-# SPECIALIZE hsIsPrime :: Int -> Bool #-}

-- | See [here](http://mathworld.wolfram.com/Derangement.html).
--
-- > λ:> fmap derangement [0..10] :: [Integer]
-- > [1,0,1,2,9,44,265,1854,14833,133496,1334961]
derangement :: (Integral a) => Int -> a
derangement n = derangements !! n

derangements :: (Integral a) => [a]
derangements = fmap snd g
    where g = (0, 1) : (1, 0) : zipWith (\(_, n) (i, m) -> (i + 1, i * (n + m))) g (tail g)

hsIsPrime :: (Integral a) => a -> Bool
hsIsPrime 1 = False
hsIsPrime x = all ((/=0) . (x `mod`)) [2..m]
    where m = floor (sqrt (fromIntegral x :: Float))

fibs :: (Integral a) => [a]
fibs = 1 : 1 : zipWith (+) fibs (tail fibs)

hsFibonacci :: (Integral a) => Int -> a
hsFibonacci = (fibs !!)
