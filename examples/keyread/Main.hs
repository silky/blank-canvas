module Main where

import Graphics.Blank
import Data.Map (Map)
import qualified Data.Map as Map
import Debug.Trace
import Control.Concurrent
import Data.List (nub)

data State = State
     	     { keys :: [Int]    -- key *codes* for pressed keys
     	     , step :: Int
     	     }
     deriving Show

main = blankCanvas 3000 $ \ context -> loop context (State [] 0)

loop context state = do
--        threadDelay (1 * 1000 * 10)    -- remove if writing a game
        send context $ do
                (width,height) <- size
                clearRect (0,0,width,height)
                lineWidth 1
                strokeStyle "red"
                font "30pt Calibri"
                fillText("Keys currently pressed: " ++ show (keys state),50,50)
                fillText("Counter: " ++ show (step state),50,150)

--        print state

        control context state

control context state = do
        event <- send context $ tryReadEvents [KeyDown,KeyUp]
        let down_keys = case event of { Just (NamedEvent KeyDown e) -> [jsCode e] ; _ -> [] }
        let up_keys = case event of { Just (NamedEvent KeyUp e) -> [jsCode e] ; _ -> []}
        let current_keys = [ k | k <- nub (keys state ++ down_keys), not (k `elem` up_keys) ]
        let state' = state { step = step state + 1, keys = current_keys }
        case event of
          Nothing -> loop context state'
          Just _  -> control context state'      -- there may be more events to process

