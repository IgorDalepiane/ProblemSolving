{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
module Vehicles where

import Data.Aeson
import GHC.Generics
import Control.Applicative
import Data.List
import qualified Data.ByteString.Lazy as B

data Vehicle = Vehicle {
  placa, category :: String,
  indice, kms :: Int
} deriving (Generic, Show)

instance ToJSON Vehicle where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON Vehicle

menuVehicles :: IO()
menuVehicles = do
  putStrLn "1 - Listar Veículos"
  putStrLn "2 - Adicionar novo Veículo"
  putStrLn "3 - Alterar Veículo"
  putStrLn "4 - Remover Veículo"
  putStrLn "0 - Voltar" 
  putStrLn "Opcao: "
  option <- getLine
  if (read option) == 0 then putStrLn("Retornando...\n") else do selectedOption (read option)

selectedOption :: Int -> IO()
selectedOption option | option == 1 = do {lista <- readFromJSON; printVehicles lista}
                      | option == 2 = do {optionAddVehicle}
                      | option == 3 = do {menuVehicles}
                      | option == 4 = do {menuVehicles}


-- rmVehicle :: [Vehicle] -> String -> Maybe Vehicle
-- rmVehicle ve idx = do
--   find idx ve

-- optionRemoveVehicle :: IO()
-- optionRemoveVehicle = do 
--   putStrLn "\n\n\n### Remoção de veículo ###\n\n\n"
--   putStrLn "Índice do veículo: "
--   _indice <- getLine
--   lista <- readFromJSON
--   let rmedVehicle = rmVehicle lista _indice
--   print rmedVehicle


-- optionUpdateVehicle :: IO()
-- optionUpdateVehicle = do
--   putStrLn "\n\n\n### Alteração de veículo ###"
--   putStrLn "Indice: "
--   _indice <- getLine
--   putStrLn "Placa: "
--   _placa <- getLine
--   putStrLn "Quilometragem: "
--   _kms <- getLine
--   putStrLn "Categoria: "
--   _category <- getLine

optionAddVehicle :: IO()
optionAddVehicle = do
  putStrLn "\n\n\n### Cadastro de veículo ###"
  putStrLn "Placa: "
  _placa <- getLine
  putStrLn "Quilometragem: "
  _kms <- getLine
  putStrLn "Categoria: "
  _category <- getLine
  lista <- readFromJSON
  let ve = Vehicle {indice = generateIndex lista, placa = _placa, kms = read _kms :: Int, category = _category}
  let list = addToList lista ve
  print list
  writeToJSON list

generateIndex :: [Vehicle] -> Int
generateIndex [] = 0
generateIndex x = do 
              let lastVeiculo = last x
              (indice) lastVeiculo + 1

addToList :: [Vehicle] -> Vehicle -> [Vehicle]
addToList [] x = [x]
addToList x ve = x ++ [ve]

writeToJSON :: [Vehicle] -> IO ()
writeToJSON list = do
  B.writeFile "db/vehicles.json" (encode list)

readFromJSON :: IO [Vehicle]
readFromJSON = do
  input <- B.readFile "db/vehicles.json"

  let vehicles = decode input :: Maybe [Vehicle]

  case vehicles of
    Nothing -> return []
    Just vehicles -> return vehicles


printVehicles :: [Vehicle] -> IO ()
printVehicles vehicles = putStrLn ("\n\n\n" ++ (listVehicle vehicles) ++ "\n\n")

listVehicle :: [Vehicle] -> String
listVehicle [] = ""
listVehicle (x:xs) = toStringVehicle x ++ ['\n'] ++ listVehicle xs

toStringVehicle :: Vehicle -> String
toStringVehicle (Vehicle {indice = i, placa = p, kms = k, category = cat}) = show i ++ " - " ++ p ++ " - " ++ cat ++ " - " ++ show k ++ "km"
