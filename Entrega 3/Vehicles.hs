{-# LANGUAGE Arrows, NoMonomorphismRestriction #-}
module Vehicles where

import Text.XML.HXT.Core

data Vehicle = Vehicle {
  placa, category :: String,
  indice, kms :: Int
} deriving (Show, Eq)

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
selectedOption option | option == 1 = do {listarVehicles; menuVehicles}

parseXML file = readDocument[withValidate no, withRemoveWS yes] file

atTag tag = deep (isElem >>> hasName tag)

getVehiclesFromXml = atTag "CATEGORY" >>>
  proc cat -> do
    _category     <- getAttrValue "NAME"   -< cat
    _ve           <- atTag "VEHICLE"       -< cat
    _indice       <- getAttrValue "INDICE" -< _ve
    _placa        <- getAttrValue "PLACA"  -< _ve
    _kms          <- getAttrValue "KM"     -< _ve
    returnA -< Vehicle {
      indice    = read _indice  :: Int,
      placa     = _placa, 
      kms       = read _kms     :: Int, 
      category  = _category
    }

printVehicles :: [Vehicle] -> IO ()
printVehicles vehicles = putStrLn ("\n\n\n" ++ (listVehicle vehicles) ++ "\n\n")

listVehicle :: [Vehicle] -> String
listVehicle [] = ""
listVehicle (x:xs) = toStringVehicle x ++ ['\n'] ++ listVehicle xs

toStringVehicle :: Vehicle -> String
toStringVehicle (Vehicle {indice = i, placa = p, kms = k, category = cat}) = show i ++ " - " ++ p ++ " - " ++ cat ++ " - " ++ show k ++ "km"

listarVehicles :: IO()
listarVehicles = do
  _vehicles <- runX (parseXML "db/Vehicles.xml" >>> getVehiclesFromXml)
  printVehicles _vehicles
