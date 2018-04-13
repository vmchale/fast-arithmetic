import qualified Math.Combinat.Numbers                 as Ext
import qualified Math.NumberTheory.ArithmeticFunctions as Ext
import           Math.NumberTheory.Moduli.Jacobi       (JacobiSymbol (..))
import qualified Math.NumberTheory.Moduli.Jacobi       as Ext
import qualified Math.NumberTheory.MoebiusInversion    as Ext
import           Numeric.Combinatorics
import           Numeric.Integer
import           Numeric.NumberTheory
import           Numeric.Pure
import           Test.Hspec
import           Test.Hspec.QuickCheck
import           Test.QuickCheck                       hiding (choose)

{-# SPECIALIZE hsIsPrime :: Int -> Bool #-}

hsIsPrime :: (Integral a) => a -> Bool
hsIsPrime 1 = False
hsIsPrime x = all ((/=0) . (x `rem`)) [2..up]
    where up = floor (sqrt (fromIntegral x :: Float))

toInt :: JacobiSymbol -> Int
toInt MinusOne = -1
toInt Zero     = 0
toInt One      = 1

tooBig :: Int -> Int -> Bool
tooBig x y = go x y >= 2 ^ (16 :: Integer)
    where
        go :: Int -> Int -> Integer
        go m n = fromIntegral m ^ (fromIntegral n :: Integer)

agree :: (Eq a, Show b, Integral b, Arbitrary b) => String -> (b -> a) -> (b -> a) -> SpecWith ()
agree s f g = describe s $
    prop "should agree with the pure Haskell function" $
        \n -> n < 1 || f n == g n

main :: IO ()
main = hspec $ parallel $ do

    sequence_ $ zipWith3 agree
        ["totient", "tau", "littleOmega", "sumDivisors"]
        [totient, tau, littleOmega, sumDivisors]
        [Ext.totient, Ext.tau, Ext.smallOmega, Ext.sigma 1]

    sequence_ $ zipWith3 agree
        ["isPrime"]
        [isPrime]
        [hsIsPrime]

    describe "jacobi" $
        it "should match the arithmoi function" $
            toInt (Ext.jacobi (15 :: Int) 19) `shouldBe` toInt (Ext.jacobi (15 :: Int) 19)
    describe "totient" $
        prop "should be equal to p-1 for p prime" $
            \p -> p < 1 || not (isPrime p) || totient p == p - 1
    describe "derangement" $
        prop "should be equal to [n!/e]" $
            \n -> n < 1 || n > 18 || (derangement n :: Integer) == floor ((fromIntegral (Ext.factorial (fromIntegral n :: Int) :: Integer) :: Double) / exp 1 + 0.5)
    describe "totient" $
        prop "should satisfy Fermat's little theorem" $
            \a m -> a < 1 || m < 2 || gcd a m /= 1 || tooBig a m || (a ^ totient m) `mod` m == 1
    describe "doubleFactorial" $
        prop "should agree" $
            \a -> a < 0 || doubleFactorial a == Ext.doubleFactorial a
    describe "catalan" $
        prop "should agree" $
            \a -> a < 0 || catalan a == Ext.catalan a
    describe "factorial" $
        prop "should agree" $
            \a -> a < 0 || factorial a == Ext.factorial a
    describe "choose" $
        prop "should agree" $
            \a -> a < 0 || choose 101 a == Ext.binomial 101 a
    describe "derangement" $
        prop "should agree" $
            \a -> a < 0 || derangement a == hsDerangement a
    describe "totientSum" $
        prop "should agree" $
            \a -> a < 1 || totientSum a == Ext.totientSum a
