module Main where

import Menu
import System.Console.ANSI
import Logos
main :: IO ()
main = do
  clearScreen
  logo
  menu