{-# LANGUAGE FlexibleInstances #-}

-- (c) Alex McLean and contributors 2022
-- Shared under the terms of the GNU Public License v3.0

-- Please do not edit this file directly, it's generated from
-- bin/generate-composers.hs

module Sound.Tidal.Signal.Compose where

import Prelude hiding ((<*), (*>))
import Control.Monad (forM)
import Data.Bits

import qualified Data.Map.Strict as Map

import Sound.Tidal.Types
import Sound.Tidal.Signal.Base

-- ************************************************************ --
-- Hack to allow 'union' to be used on any value

-- class for types that support a left-biased union
class Unionable a where
  union :: a -> a -> a

-- default union is just to take the left hand side..
instance Unionable a where
  union = const

instance {-# OVERLAPPING #-} Unionable ValueMap where
  union = Map.union

-- ************************************************************ --

opMix :: Applicative t => (a -> b -> c) -> t a -> t b -> t c
opMix f a b = f <$> a <*> b

opIn :: (a -> b -> c) -> Signal a -> Signal b -> Signal c
opIn f a b = f <$> a <* b
  
opOut :: (a -> b -> c) -> Signal a -> Signal b -> Signal c
opOut f a b = f <$> a *> b

opSqueeze :: (a -> b -> c) -> Signal a -> Signal b -> Signal c
opSqueeze f a b = squeezeJoin $ fmap (\a -> fmap (\b -> f a b)  b) a
  
opSqueezeOut :: (a -> b -> c) -> Signal a -> Signal b -> Signal c
opSqueezeOut f pata patb = squeezeJoin $ fmap (\a -> fmap (\b -> f b a)  pata) patb

opTrig :: (a -> b -> c) -> Signal a -> Signal b -> Signal c
opTrig f a b = trigJoin $ fmap (\a -> fmap (\b -> f a b)  b) a
  
opTrigzero :: (a -> b -> c) -> Signal a -> Signal b -> Signal c
opTrigzero f a b = trigzeroJoin $ fmap (\a -> fmap (\b -> f a b)  b) a

-- ************************************************************ --

-- Aliases

(#) :: Unionable b => Signal b -> Signal b -> Signal b
(#) = (|=)

struct :: Unionable a => Signal Bool -> Signal a -> Signal a
struct = flip keepifOut

structAll :: Unionable a => Signal a -> Signal a -> Signal a
structAll = flip keepOut

mask :: Unionable a => Signal Bool -> Signal a -> Signal a
mask = flip keepifIn

maskAll :: Unionable a => Signal a -> Signal a -> Signal a
maskAll = flip keepIn

reset :: Unionable a => Signal Bool -> Signal a -> Signal a
reset = flip keepifTrig

resetAll :: Unionable a => Signal a -> Signal a -> Signal a
resetAll = flip keepTrig

restart :: Unionable a => Signal Bool -> Signal a -> Signal a
restart = flip keepifTrigzero

restartAll :: Unionable a => Signal a -> Signal a -> Signal a
restartAll = flip keepTrigzero

-- ************************************************************ --

-- set

setMix, (|=|) :: Unionable a => Signal a -> Signal a -> Signal a
setMix pata patb = opMix (flip union) pata patb
(|=|) = setMix

setIn, (|=) :: Unionable a => Signal a -> Signal a -> Signal a
setIn pata patb = opIn (flip union) pata patb
(|=) = setIn

setOut, (=|) :: Unionable a => Signal a -> Signal a -> Signal a
setOut pata patb = opOut (flip union) pata patb
(=|) = setOut

setSqueeze, (||=) :: Unionable a => Signal a -> Signal a -> Signal a
setSqueeze pata patb = opSqueeze (flip union) pata patb
(||=) = setSqueeze

setSqueezeOut, (=||) :: Unionable a => Signal a -> Signal a -> Signal a
setSqueezeOut pata patb = opSqueezeOut (flip union) pata patb
(=||) = setSqueezeOut

setTrig, (!=) :: Unionable a => Signal a -> Signal a -> Signal a
setTrig pata patb = opTrig (flip union) pata patb
(!=) = setTrig

setTrigzero, (!!=) :: Unionable a => Signal a -> Signal a -> Signal a
setTrigzero pata patb = opTrigzero (flip union) pata patb
(!!=) = setTrigzero

infix 4 |=|, |=, =|, ||=, =||, !=, !!=

-- keep

keepMix, (|.|) :: Unionable a => Signal a -> Signal a -> Signal a
keepMix pata patb = opMix (union) pata patb
(|.|) = keepMix

keepIn, (|.) :: Unionable a => Signal a -> Signal a -> Signal a
keepIn pata patb = opIn (union) pata patb
(|.) = keepIn

keepOut, (.|) :: Unionable a => Signal a -> Signal a -> Signal a
keepOut pata patb = opOut (union) pata patb
(.|) = keepOut

keepSqueeze, (||.) :: Unionable a => Signal a -> Signal a -> Signal a
keepSqueeze pata patb = opSqueeze (union) pata patb
(||.) = keepSqueeze

keepSqueezeOut, (.||) :: Unionable a => Signal a -> Signal a -> Signal a
keepSqueezeOut pata patb = opSqueezeOut (union) pata patb
(.||) = keepSqueezeOut

keepTrig, (!.) :: Unionable a => Signal a -> Signal a -> Signal a
keepTrig pata patb = opTrig (union) pata patb
(!.) = keepTrig

keepTrigzero, (!!.) :: Unionable a => Signal a -> Signal a -> Signal a
keepTrigzero pata patb = opTrigzero (union) pata patb
(!!.) = keepTrigzero

infix 4 |.|, |., .|, ||., .||, !., !!.

-- keepif

keepifMix, (|?|) :: Unionable a => Signal a -> Signal Bool -> Signal a
keepifMix pata patb = filterJusts $ opMix (\a b -> if b then Just a else Nothing) pata patb
(|?|) = keepifMix

keepifIn, (|?) :: Unionable a => Signal a -> Signal Bool -> Signal a
keepifIn pata patb = filterJusts $ opIn (\a b -> if b then Just a else Nothing) pata patb
(|?) = keepifIn

keepifOut, (?|) :: Unionable a => Signal a -> Signal Bool -> Signal a
keepifOut pata patb = filterJusts $ opOut (\a b -> if b then Just a else Nothing) pata patb
(?|) = keepifOut

keepifSqueeze, (||?) :: Unionable a => Signal a -> Signal Bool -> Signal a
keepifSqueeze pata patb = filterJusts $ opSqueeze (\a b -> if b then Just a else Nothing) pata patb
(||?) = keepifSqueeze

keepifSqueezeOut, (?||) :: Unionable a => Signal a -> Signal Bool -> Signal a
keepifSqueezeOut pata patb = filterJusts $ opSqueezeOut (\a b -> if b then Just a else Nothing) pata patb
(?||) = keepifSqueezeOut

keepifTrig, (!?) :: Unionable a => Signal a -> Signal Bool -> Signal a
keepifTrig pata patb = filterJusts $ opTrig (\a b -> if b then Just a else Nothing) pata patb
(!?) = keepifTrig

keepifTrigzero, (!!?) :: Unionable a => Signal a -> Signal Bool -> Signal a
keepifTrigzero pata patb = filterJusts $ opTrigzero (\a b -> if b then Just a else Nothing) pata patb
(!!?) = keepifTrigzero

infix 4 |?|, |?, ?|, ||?, ?||, !?, !!?

-- add

addMix, (|+|) :: Num a => Signal a -> Signal a -> Signal a
addMix pata patb = opMix (+) pata patb
(|+|) = addMix

addIn, (|+) :: Num a => Signal a -> Signal a -> Signal a
addIn pata patb = opIn (+) pata patb
(|+) = addIn

addOut, (+|) :: Num a => Signal a -> Signal a -> Signal a
addOut pata patb = opOut (+) pata patb
(+|) = addOut

addSqueeze, (||+) :: Num a => Signal a -> Signal a -> Signal a
addSqueeze pata patb = opSqueeze (+) pata patb
(||+) = addSqueeze

addSqueezeOut, (+||) :: Num a => Signal a -> Signal a -> Signal a
addSqueezeOut pata patb = opSqueezeOut (+) pata patb
(+||) = addSqueezeOut

addTrig, (!+) :: Num a => Signal a -> Signal a -> Signal a
addTrig pata patb = opTrig (+) pata patb
(!+) = addTrig

addTrigzero, (!!+) :: Num a => Signal a -> Signal a -> Signal a
addTrigzero pata patb = opTrigzero (+) pata patb
(!!+) = addTrigzero

infix 4 |+|, |+, +|, ||+, +||, !+, !!+

-- sub

subMix, (|-|) :: Num a => Signal a -> Signal a -> Signal a
subMix pata patb = opMix (-) pata patb
(|-|) = subMix

subIn, (|-) :: Num a => Signal a -> Signal a -> Signal a
subIn pata patb = opIn (-) pata patb
(|-) = subIn

subOut, (-|) :: Num a => Signal a -> Signal a -> Signal a
subOut pata patb = opOut (-) pata patb
(-|) = subOut

subSqueeze, (||-) :: Num a => Signal a -> Signal a -> Signal a
subSqueeze pata patb = opSqueeze (-) pata patb
(||-) = subSqueeze

subSqueezeOut, (-||) :: Num a => Signal a -> Signal a -> Signal a
subSqueezeOut pata patb = opSqueezeOut (-) pata patb
(-||) = subSqueezeOut

subTrig, (!-) :: Num a => Signal a -> Signal a -> Signal a
subTrig pata patb = opTrig (-) pata patb
(!-) = subTrig

subTrigzero, (!!-) :: Num a => Signal a -> Signal a -> Signal a
subTrigzero pata patb = opTrigzero (-) pata patb
(!!-) = subTrigzero

infix 4 |-|, |-, -|, ||-, -||, !-, !!-

-- mul

mulMix, (|*|) :: Num a => Signal a -> Signal a -> Signal a
mulMix pata patb = opMix (*) pata patb
(|*|) = mulMix

mulIn, (|*) :: Num a => Signal a -> Signal a -> Signal a
mulIn pata patb = opIn (*) pata patb
(|*) = mulIn

mulOut, (*|) :: Num a => Signal a -> Signal a -> Signal a
mulOut pata patb = opOut (*) pata patb
(*|) = mulOut

mulSqueeze, (||*) :: Num a => Signal a -> Signal a -> Signal a
mulSqueeze pata patb = opSqueeze (*) pata patb
(||*) = mulSqueeze

mulSqueezeOut, (*||) :: Num a => Signal a -> Signal a -> Signal a
mulSqueezeOut pata patb = opSqueezeOut (*) pata patb
(*||) = mulSqueezeOut

mulTrig, (!*) :: Num a => Signal a -> Signal a -> Signal a
mulTrig pata patb = opTrig (*) pata patb
(!*) = mulTrig

mulTrigzero, (!!*) :: Num a => Signal a -> Signal a -> Signal a
mulTrigzero pata patb = opTrigzero (*) pata patb
(!!*) = mulTrigzero

infix 4 |*|, |*, *|, ||*, *||, !*, !!*

-- div

divMix, (|/|) :: Fractional a => Signal a -> Signal a -> Signal a
divMix pata patb = opMix (/) pata patb
(|/|) = divMix

divIn, (|/) :: Fractional a => Signal a -> Signal a -> Signal a
divIn pata patb = opIn (/) pata patb
(|/) = divIn

divOut, (/|) :: Fractional a => Signal a -> Signal a -> Signal a
divOut pata patb = opOut (/) pata patb
(/|) = divOut

divSqueeze, (||/) :: Fractional a => Signal a -> Signal a -> Signal a
divSqueeze pata patb = opSqueeze (/) pata patb
(||/) = divSqueeze

divSqueezeOut, (/||) :: Fractional a => Signal a -> Signal a -> Signal a
divSqueezeOut pata patb = opSqueezeOut (/) pata patb
(/||) = divSqueezeOut

divTrig, (!/) :: Fractional a => Signal a -> Signal a -> Signal a
divTrig pata patb = opTrig (/) pata patb
(!/) = divTrig

divTrigzero, (!!/) :: Fractional a => Signal a -> Signal a -> Signal a
divTrigzero pata patb = opTrigzero (/) pata patb
(!!/) = divTrigzero

infix 4 |/|, |/, /|, ||/, /||, !/, !!/

-- mod

modMix, (|%|) :: Integral a => Signal a -> Signal a -> Signal a
modMix pata patb = opMix (mod) pata patb
(|%|) = modMix

modIn, (|%) :: Integral a => Signal a -> Signal a -> Signal a
modIn pata patb = opIn (mod) pata patb
(|%) = modIn

modOut, (%|) :: Integral a => Signal a -> Signal a -> Signal a
modOut pata patb = opOut (mod) pata patb
(%|) = modOut

modSqueeze, (||%) :: Integral a => Signal a -> Signal a -> Signal a
modSqueeze pata patb = opSqueeze (mod) pata patb
(||%) = modSqueeze

modSqueezeOut, (%||) :: Integral a => Signal a -> Signal a -> Signal a
modSqueezeOut pata patb = opSqueezeOut (mod) pata patb
(%||) = modSqueezeOut

modTrig, (!%) :: Integral a => Signal a -> Signal a -> Signal a
modTrig pata patb = opTrig (mod) pata patb
(!%) = modTrig

modTrigzero, (!!%) :: Integral a => Signal a -> Signal a -> Signal a
modTrigzero pata patb = opTrigzero (mod) pata patb
(!!%) = modTrigzero

infix 4 |%|, |%, %|, ||%, %||, !%, !!%

-- pow

powMix, (|^|) :: Integral a => Signal a -> Signal a -> Signal a
powMix pata patb = opMix (^) pata patb
(|^|) = powMix

powIn, (|^) :: Integral a => Signal a -> Signal a -> Signal a
powIn pata patb = opIn (^) pata patb
(|^) = powIn

powOut, (^|) :: Integral a => Signal a -> Signal a -> Signal a
powOut pata patb = opOut (^) pata patb
(^|) = powOut

powSqueeze, (||^) :: Integral a => Signal a -> Signal a -> Signal a
powSqueeze pata patb = opSqueeze (^) pata patb
(||^) = powSqueeze

powSqueezeOut, (^||) :: Integral a => Signal a -> Signal a -> Signal a
powSqueezeOut pata patb = opSqueezeOut (^) pata patb
(^||) = powSqueezeOut

powTrig, (!^) :: Integral a => Signal a -> Signal a -> Signal a
powTrig pata patb = opTrig (^) pata patb
(!^) = powTrig

powTrigzero, (!!^) :: Integral a => Signal a -> Signal a -> Signal a
powTrigzero pata patb = opTrigzero (^) pata patb
(!!^) = powTrigzero

infix 4 |^|, |^, ^|, ||^, ^||, !^, !!^

-- powf

powfMix, (|**|) :: Floating a => Signal a -> Signal a -> Signal a
powfMix pata patb = opMix (**) pata patb
(|**|) = powfMix

powfIn, (|**) :: Floating a => Signal a -> Signal a -> Signal a
powfIn pata patb = opIn (**) pata patb
(|**) = powfIn

powfOut, (**|) :: Floating a => Signal a -> Signal a -> Signal a
powfOut pata patb = opOut (**) pata patb
(**|) = powfOut

powfSqueeze, (||**) :: Floating a => Signal a -> Signal a -> Signal a
powfSqueeze pata patb = opSqueeze (**) pata patb
(||**) = powfSqueeze

powfSqueezeOut, (**||) :: Floating a => Signal a -> Signal a -> Signal a
powfSqueezeOut pata patb = opSqueezeOut (**) pata patb
(**||) = powfSqueezeOut

powfTrig, (!**) :: Floating a => Signal a -> Signal a -> Signal a
powfTrig pata patb = opTrig (**) pata patb
(!**) = powfTrig

powfTrigzero, (!!**) :: Floating a => Signal a -> Signal a -> Signal a
powfTrigzero pata patb = opTrigzero (**) pata patb
(!!**) = powfTrigzero

infix 4 |**|, |**, **|, ||**, **||, !**, !!**

-- concat

concatMix, (|++|) :: Signal String -> Signal String -> Signal String
concatMix pata patb = opMix (++) pata patb
(|++|) = concatMix

concatIn, (|++) :: Signal String -> Signal String -> Signal String
concatIn pata patb = opIn (++) pata patb
(|++) = concatIn

concatOut, (++|) :: Signal String -> Signal String -> Signal String
concatOut pata patb = opOut (++) pata patb
(++|) = concatOut

concatSqueeze, (||++) :: Signal String -> Signal String -> Signal String
concatSqueeze pata patb = opSqueeze (++) pata patb
(||++) = concatSqueeze

concatSqueezeOut, (++||) :: Signal String -> Signal String -> Signal String
concatSqueezeOut pata patb = opSqueezeOut (++) pata patb
(++||) = concatSqueezeOut

concatTrig, (!++) :: Signal String -> Signal String -> Signal String
concatTrig pata patb = opTrig (++) pata patb
(!++) = concatTrig

concatTrigzero, (!!++) :: Signal String -> Signal String -> Signal String
concatTrigzero pata patb = opTrigzero (++) pata patb
(!!++) = concatTrigzero

infix 4 |++|, |++, ++|, ||++, ++||, !++, !!++

-- band

bandMix, (|.&.|) :: Bits a => Signal a -> Signal a -> Signal a
bandMix pata patb = opMix (.&.) pata patb
(|.&.|) = bandMix

bandIn, (|.&.) :: Bits a => Signal a -> Signal a -> Signal a
bandIn pata patb = opIn (.&.) pata patb
(|.&.) = bandIn

bandOut, (.&.|) :: Bits a => Signal a -> Signal a -> Signal a
bandOut pata patb = opOut (.&.) pata patb
(.&.|) = bandOut

bandSqueeze, (||.&.) :: Bits a => Signal a -> Signal a -> Signal a
bandSqueeze pata patb = opSqueeze (.&.) pata patb
(||.&.) = bandSqueeze

bandSqueezeOut, (.&.||) :: Bits a => Signal a -> Signal a -> Signal a
bandSqueezeOut pata patb = opSqueezeOut (.&.) pata patb
(.&.||) = bandSqueezeOut

bandTrig, (!.&.) :: Bits a => Signal a -> Signal a -> Signal a
bandTrig pata patb = opTrig (.&.) pata patb
(!.&.) = bandTrig

bandTrigzero, (!!.&.) :: Bits a => Signal a -> Signal a -> Signal a
bandTrigzero pata patb = opTrigzero (.&.) pata patb
(!!.&.) = bandTrigzero

infix 4 |.&.|, |.&., .&.|, ||.&., .&.||, !.&., !!.&.

-- bor

borMix, (|.|.|) :: Bits a => Signal a -> Signal a -> Signal a
borMix pata patb = opMix (.|.) pata patb
(|.|.|) = borMix

borIn, (|.|.) :: Bits a => Signal a -> Signal a -> Signal a
borIn pata patb = opIn (.|.) pata patb
(|.|.) = borIn

borOut, (.|.|) :: Bits a => Signal a -> Signal a -> Signal a
borOut pata patb = opOut (.|.) pata patb
(.|.|) = borOut

borSqueeze, (||.|.) :: Bits a => Signal a -> Signal a -> Signal a
borSqueeze pata patb = opSqueeze (.|.) pata patb
(||.|.) = borSqueeze

borSqueezeOut, (.|.||) :: Bits a => Signal a -> Signal a -> Signal a
borSqueezeOut pata patb = opSqueezeOut (.|.) pata patb
(.|.||) = borSqueezeOut

borTrig, (!.|.) :: Bits a => Signal a -> Signal a -> Signal a
borTrig pata patb = opTrig (.|.) pata patb
(!.|.) = borTrig

borTrigzero, (!!.|.) :: Bits a => Signal a -> Signal a -> Signal a
borTrigzero pata patb = opTrigzero (.|.) pata patb
(!!.|.) = borTrigzero

infix 4 |.|.|, |.|., .|.|, ||.|., .|.||, !.|., !!.|.

-- bxor

bxorMix, (|.^.|) :: Bits a => Signal a -> Signal a -> Signal a
bxorMix pata patb = opMix (xor) pata patb
(|.^.|) = bxorMix

bxorIn, (|.^.) :: Bits a => Signal a -> Signal a -> Signal a
bxorIn pata patb = opIn (xor) pata patb
(|.^.) = bxorIn

bxorOut, (.^.|) :: Bits a => Signal a -> Signal a -> Signal a
bxorOut pata patb = opOut (xor) pata patb
(.^.|) = bxorOut

bxorSqueeze, (||.^.) :: Bits a => Signal a -> Signal a -> Signal a
bxorSqueeze pata patb = opSqueeze (xor) pata patb
(||.^.) = bxorSqueeze

bxorSqueezeOut, (.^.||) :: Bits a => Signal a -> Signal a -> Signal a
bxorSqueezeOut pata patb = opSqueezeOut (xor) pata patb
(.^.||) = bxorSqueezeOut

bxorTrig, (!.^.) :: Bits a => Signal a -> Signal a -> Signal a
bxorTrig pata patb = opTrig (xor) pata patb
(!.^.) = bxorTrig

bxorTrigzero, (!!.^.) :: Bits a => Signal a -> Signal a -> Signal a
bxorTrigzero pata patb = opTrigzero (xor) pata patb
(!!.^.) = bxorTrigzero

infix 4 |.^.|, |.^., .^.|, ||.^., .^.||, !.^., !!.^.

-- bshiftl

bshiftlMix, (|.<<.|) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftlMix pata patb = opMix (shiftL) pata patb
(|.<<.|) = bshiftlMix

bshiftlIn, (|.<<.) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftlIn pata patb = opIn (shiftL) pata patb
(|.<<.) = bshiftlIn

bshiftlOut, (.<<.|) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftlOut pata patb = opOut (shiftL) pata patb
(.<<.|) = bshiftlOut

bshiftlSqueeze, (||.<<.) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftlSqueeze pata patb = opSqueeze (shiftL) pata patb
(||.<<.) = bshiftlSqueeze

bshiftlSqueezeOut, (.<<.||) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftlSqueezeOut pata patb = opSqueezeOut (shiftL) pata patb
(.<<.||) = bshiftlSqueezeOut

bshiftlTrig, (!.<<.) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftlTrig pata patb = opTrig (shiftL) pata patb
(!.<<.) = bshiftlTrig

bshiftlTrigzero, (!!.<<.) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftlTrigzero pata patb = opTrigzero (shiftL) pata patb
(!!.<<.) = bshiftlTrigzero

infix 4 |.<<.|, |.<<., .<<.|, ||.<<., .<<.||, !.<<., !!.<<.

-- bshiftr

bshiftrMix, (|.>>.|) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftrMix pata patb = opMix (shiftR) pata patb
(|.>>.|) = bshiftrMix

bshiftrIn, (|.>>.) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftrIn pata patb = opIn (shiftR) pata patb
(|.>>.) = bshiftrIn

bshiftrOut, (.>>.|) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftrOut pata patb = opOut (shiftR) pata patb
(.>>.|) = bshiftrOut

bshiftrSqueeze, (||.>>.) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftrSqueeze pata patb = opSqueeze (shiftR) pata patb
(||.>>.) = bshiftrSqueeze

bshiftrSqueezeOut, (.>>.||) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftrSqueezeOut pata patb = opSqueezeOut (shiftR) pata patb
(.>>.||) = bshiftrSqueezeOut

bshiftrTrig, (!.>>.) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftrTrig pata patb = opTrig (shiftR) pata patb
(!.>>.) = bshiftrTrig

bshiftrTrigzero, (!!.>>.) :: Bits a => Signal a -> Signal Int -> Signal a
bshiftrTrigzero pata patb = opTrigzero (shiftR) pata patb
(!!.>>.) = bshiftrTrigzero

infix 4 |.>>.|, |.>>., .>>.|, ||.>>., .>>.||, !.>>., !!.>>.

-- lt

ltMix, (|<|) :: Ord a => Signal a -> Signal a -> Signal Bool
ltMix pata patb = opMix (<) pata patb
(|<|) = ltMix

ltIn, (|<) :: Ord a => Signal a -> Signal a -> Signal Bool
ltIn pata patb = opIn (<) pata patb
(|<) = ltIn

ltOut, (<|) :: Ord a => Signal a -> Signal a -> Signal Bool
ltOut pata patb = opOut (<) pata patb
(<|) = ltOut

ltSqueeze, (||<) :: Ord a => Signal a -> Signal a -> Signal Bool
ltSqueeze pata patb = opSqueeze (<) pata patb
(||<) = ltSqueeze

ltSqueezeOut, (<||) :: Ord a => Signal a -> Signal a -> Signal Bool
ltSqueezeOut pata patb = opSqueezeOut (<) pata patb
(<||) = ltSqueezeOut

ltTrig, (!<) :: Ord a => Signal a -> Signal a -> Signal Bool
ltTrig pata patb = opTrig (<) pata patb
(!<) = ltTrig

ltTrigzero, (!!<) :: Ord a => Signal a -> Signal a -> Signal Bool
ltTrigzero pata patb = opTrigzero (<) pata patb
(!!<) = ltTrigzero

infix 4 |<|, |<, <|, ||<, <||, !<, !!<

-- gt

gtMix, (|>|) :: Ord a => Signal a -> Signal a -> Signal Bool
gtMix pata patb = opMix (>) pata patb
(|>|) = gtMix

gtIn, (|>) :: Ord a => Signal a -> Signal a -> Signal Bool
gtIn pata patb = opIn (>) pata patb
(|>) = gtIn

gtOut, (>|) :: Ord a => Signal a -> Signal a -> Signal Bool
gtOut pata patb = opOut (>) pata patb
(>|) = gtOut

gtSqueeze, (||>) :: Ord a => Signal a -> Signal a -> Signal Bool
gtSqueeze pata patb = opSqueeze (>) pata patb
(||>) = gtSqueeze

gtSqueezeOut, (>||) :: Ord a => Signal a -> Signal a -> Signal Bool
gtSqueezeOut pata patb = opSqueezeOut (>) pata patb
(>||) = gtSqueezeOut

gtTrig, (!>) :: Ord a => Signal a -> Signal a -> Signal Bool
gtTrig pata patb = opTrig (>) pata patb
(!>) = gtTrig

gtTrigzero, (!!>) :: Ord a => Signal a -> Signal a -> Signal Bool
gtTrigzero pata patb = opTrigzero (>) pata patb
(!!>) = gtTrigzero

infix 4 |>|, |>, >|, ||>, >||, !>, !!>

-- lte

lteMix, (|<=|) :: Ord a => Signal a -> Signal a -> Signal Bool
lteMix pata patb = opMix (<=) pata patb
(|<=|) = lteMix

lteIn, (|<=) :: Ord a => Signal a -> Signal a -> Signal Bool
lteIn pata patb = opIn (<=) pata patb
(|<=) = lteIn

lteOut, (<=|) :: Ord a => Signal a -> Signal a -> Signal Bool
lteOut pata patb = opOut (<=) pata patb
(<=|) = lteOut

lteSqueeze, (||<=) :: Ord a => Signal a -> Signal a -> Signal Bool
lteSqueeze pata patb = opSqueeze (<=) pata patb
(||<=) = lteSqueeze

lteSqueezeOut, (<=||) :: Ord a => Signal a -> Signal a -> Signal Bool
lteSqueezeOut pata patb = opSqueezeOut (<=) pata patb
(<=||) = lteSqueezeOut

lteTrig, (!<=) :: Ord a => Signal a -> Signal a -> Signal Bool
lteTrig pata patb = opTrig (<=) pata patb
(!<=) = lteTrig

lteTrigzero, (!!<=) :: Ord a => Signal a -> Signal a -> Signal Bool
lteTrigzero pata patb = opTrigzero (<=) pata patb
(!!<=) = lteTrigzero

infix 4 |<=|, |<=, <=|, ||<=, <=||, !<=, !!<=

-- gte

gteMix, (|>=|) :: Ord a => Signal a -> Signal a -> Signal Bool
gteMix pata patb = opMix (>=) pata patb
(|>=|) = gteMix

gteIn, (|>=) :: Ord a => Signal a -> Signal a -> Signal Bool
gteIn pata patb = opIn (>=) pata patb
(|>=) = gteIn

gteOut, (>=|) :: Ord a => Signal a -> Signal a -> Signal Bool
gteOut pata patb = opOut (>=) pata patb
(>=|) = gteOut

gteSqueeze, (||>=) :: Ord a => Signal a -> Signal a -> Signal Bool
gteSqueeze pata patb = opSqueeze (>=) pata patb
(||>=) = gteSqueeze

gteSqueezeOut, (>=||) :: Ord a => Signal a -> Signal a -> Signal Bool
gteSqueezeOut pata patb = opSqueezeOut (>=) pata patb
(>=||) = gteSqueezeOut

gteTrig, (!>=) :: Ord a => Signal a -> Signal a -> Signal Bool
gteTrig pata patb = opTrig (>=) pata patb
(!>=) = gteTrig

gteTrigzero, (!!>=) :: Ord a => Signal a -> Signal a -> Signal Bool
gteTrigzero pata patb = opTrigzero (>=) pata patb
(!!>=) = gteTrigzero

infix 4 |>=|, |>=, >=|, ||>=, >=||, !>=, !!>=

-- eq

eqMix, (|==|) :: Eq a => Signal a -> Signal a -> Signal Bool
eqMix pata patb = opMix (==) pata patb
(|==|) = eqMix

eqIn, (|==) :: Eq a => Signal a -> Signal a -> Signal Bool
eqIn pata patb = opIn (==) pata patb
(|==) = eqIn

eqOut, (==|) :: Eq a => Signal a -> Signal a -> Signal Bool
eqOut pata patb = opOut (==) pata patb
(==|) = eqOut

eqSqueeze, (||==) :: Eq a => Signal a -> Signal a -> Signal Bool
eqSqueeze pata patb = opSqueeze (==) pata patb
(||==) = eqSqueeze

eqSqueezeOut, (==||) :: Eq a => Signal a -> Signal a -> Signal Bool
eqSqueezeOut pata patb = opSqueezeOut (==) pata patb
(==||) = eqSqueezeOut

eqTrig, (!==) :: Eq a => Signal a -> Signal a -> Signal Bool
eqTrig pata patb = opTrig (==) pata patb
(!==) = eqTrig

eqTrigzero, (!!==) :: Eq a => Signal a -> Signal a -> Signal Bool
eqTrigzero pata patb = opTrigzero (==) pata patb
(!!==) = eqTrigzero

infix 4 |==|, |==, ==|, ||==, ==||, !==, !!==

-- ne

neMix, (|/=|) :: Eq a => Signal a -> Signal a -> Signal Bool
neMix pata patb = opMix (/=) pata patb
(|/=|) = neMix

neIn, (|/=) :: Eq a => Signal a -> Signal a -> Signal Bool
neIn pata patb = opIn (/=) pata patb
(|/=) = neIn

neOut, (/=|) :: Eq a => Signal a -> Signal a -> Signal Bool
neOut pata patb = opOut (/=) pata patb
(/=|) = neOut

neSqueeze, (||/=) :: Eq a => Signal a -> Signal a -> Signal Bool
neSqueeze pata patb = opSqueeze (/=) pata patb
(||/=) = neSqueeze

neSqueezeOut, (/=||) :: Eq a => Signal a -> Signal a -> Signal Bool
neSqueezeOut pata patb = opSqueezeOut (/=) pata patb
(/=||) = neSqueezeOut

neTrig, (!/=) :: Eq a => Signal a -> Signal a -> Signal Bool
neTrig pata patb = opTrig (/=) pata patb
(!/=) = neTrig

neTrigzero, (!!/=) :: Eq a => Signal a -> Signal a -> Signal Bool
neTrigzero pata patb = opTrigzero (/=) pata patb
(!!/=) = neTrigzero

infix 4 |/=|, |/=, /=|, ||/=, /=||, !/=, !!/=

-- and

andMix, (|&&|) :: Signal Bool -> Signal Bool -> Signal Bool
andMix pata patb = opMix (&&) pata patb
(|&&|) = andMix

andIn, (|&&) :: Signal Bool -> Signal Bool -> Signal Bool
andIn pata patb = opIn (&&) pata patb
(|&&) = andIn

andOut, (&&|) :: Signal Bool -> Signal Bool -> Signal Bool
andOut pata patb = opOut (&&) pata patb
(&&|) = andOut

andSqueeze, (||&&) :: Signal Bool -> Signal Bool -> Signal Bool
andSqueeze pata patb = opSqueeze (&&) pata patb
(||&&) = andSqueeze

andSqueezeOut, (&&||) :: Signal Bool -> Signal Bool -> Signal Bool
andSqueezeOut pata patb = opSqueezeOut (&&) pata patb
(&&||) = andSqueezeOut

andTrig, (!&&) :: Signal Bool -> Signal Bool -> Signal Bool
andTrig pata patb = opTrig (&&) pata patb
(!&&) = andTrig

andTrigzero, (!!&&) :: Signal Bool -> Signal Bool -> Signal Bool
andTrigzero pata patb = opTrigzero (&&) pata patb
(!!&&) = andTrigzero

infix 4 |&&|, |&&, &&|, ||&&, &&||, !&&, !!&&

-- or

orMix, (|.||.|) :: Signal Bool -> Signal Bool -> Signal Bool
orMix pata patb = opMix (||) pata patb
(|.||.|) = orMix

orIn, (|.||.) :: Signal Bool -> Signal Bool -> Signal Bool
orIn pata patb = opIn (||) pata patb
(|.||.) = orIn

orOut, (.||.|) :: Signal Bool -> Signal Bool -> Signal Bool
orOut pata patb = opOut (||) pata patb
(.||.|) = orOut

orSqueeze, (||.||.) :: Signal Bool -> Signal Bool -> Signal Bool
orSqueeze pata patb = opSqueeze (||) pata patb
(||.||.) = orSqueeze

orSqueezeOut, (.||.||) :: Signal Bool -> Signal Bool -> Signal Bool
orSqueezeOut pata patb = opSqueezeOut (||) pata patb
(.||.||) = orSqueezeOut

orTrig, (!.||.) :: Signal Bool -> Signal Bool -> Signal Bool
orTrig pata patb = opTrig (||) pata patb
(!.||.) = orTrig

orTrigzero, (!!.||.) :: Signal Bool -> Signal Bool -> Signal Bool
orTrigzero pata patb = opTrigzero (||) pata patb
(!!.||.) = orTrigzero

infix 4 |.||.|, |.||., .||.|, ||.||., .||.||, !.||., !!.||.


