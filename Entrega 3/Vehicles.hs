{-# LANGUAGE Arrows, NoMonomorphismRestriction #-}
{-# LANGUAGE DeriveGeneric #-}

module Vehicles where

import Data.Aeson
import GHC.Generics
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
selectedOption option | option == 1 = do {readFromJSON; menuVehicles}
                      | option == 2 = do {readFromJSON ; menuVehicles}
                      | option == 3 = do {readFromJSON ; menuVehicles}
                      | option == 4 = do {readFromJSON ; menuVehicles}


writeToJSON :: [Vehicle] -> IO ()
writeToJSON list = do
  B.writeFile "db/vehicles.json" (encode list)

readFromJSON :: IO()
readFromJSON = do
  d <- (eitherDecode <$> B.readFile "db/vehicles.json") :: IO (Either String [Vehicle])
  case d of
    Left err -> putStrLn err
    Right ps -> printVehicles ps

printVehicles :: [Vehicle] -> IO ()
printVehicles vehicles = putStrLn ("\n\n\n" ++ (listVehicle vehicles) ++ "\n\n")

listVehicle :: [Vehicle] -> String
listVehicle [] = ""
listVehicle (x:xs) = toStringVehicle x ++ ['\n'] ++ listVehicle xs

toStringVehicle :: Vehicle -> String
toStringVehicle (Vehicle {indice = i, placa = p, kms = k, category = cat}) = show i ++ " - " ++ p ++ " - " ++ cat ++ " - " ++ show k ++ "km"


