{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
module Vehicles where

import Data.Aeson
import GHC.Generics
import qualified Data.ByteString.Lazy as B
import Data.List

data Vehicle = VehicleInstance {
  vehicleId, kms, year :: Int,
  plate, category, model, brand, color :: String
} deriving (Generic, Show)

instance ToJSON Vehicle where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON Vehicle

menuVehicles :: IO()
menuVehicles = do
  putStrLn "1 - Cadastrar novo veículo"
  putStrLn "2 - Alterar dados de veículo"
  putStrLn "3 - Excluir veículo"
  putStrLn "4 - Listar veículos"
  putStrLn "0 - Voltar" 
  putStrLn "Opcao: "
  option <- getLine
  if read option == 0 then putStrLn "Retornando...\n" else do selectedOptionVehicles (read option)

selectedOptionVehicles :: Int -> IO()
selectedOptionVehicles option 
  | option == 1 = do optionAddVehicle; menuVehicles
  | option == 2 = do optionUpdateVehicle; menuVehicles
  | option == 3 = do optionRemoveVehicle; menuVehicles
  | option == 4 = do lista <- readVehiclesFromJSON; printVehicles lista; menuVehicles
  | otherwise = do putStrLn "\n\nInsira uma opção válida.\n"; menuVehicles

-- Add Vehicle
optionAddVehicle :: IO()
optionAddVehicle = do
  putStrLn "\n\n\n### Cadastro de veículo ###"
  putStrLn "Placa: "
  _plate <- getLine
  putStrLn "Quilometragem: "
  _kms <- getLine
  putStrLn "Categoria: "
  _category <- getLine
  putStrLn "Modelo: "
  _model <- getLine
  putStrLn "Marca: "
  _brand <- getLine
  putStrLn "Cor: "
  _color <- getLine
  putStrLn "Ano: "
  _year <- getLine
  lista <- readVehiclesFromJSON
  let ve = VehicleInstance {
    vehicleId = genVehicleId lista, 
    plate     = _plate, 
    kms       = read _kms :: Int, 
    category  = _category, 
    model     =_model, 
    brand     = _brand, 
    color     = _color, 
    year      = read _year :: Int
  }
  let list = addVehicleToList lista ve
  writeVehicleToJSON list
  
genVehicleId :: [Vehicle] -> Int
genVehicleId [] = 0
genVehicleId x = do 
              let lastVeiculo = last x
              vehicleId lastVeiculo + 1

addVehicleToList :: [Vehicle] -> Vehicle -> [Vehicle]
addVehicleToList [] x = [x]
addVehicleToList x ve = x ++ [ve]

-- Update Vehicle
optionUpdateVehicle :: IO ()
optionUpdateVehicle = do
  putStrLn "\n\n###Editar um veículo###"
  putStrLn "Identificador do Veículo: "
  vehicleIdEdit <- getLine
  lista <- readVehiclesFromJSON
  
  let Just veicReturn = getVehicle (read vehicleIdEdit :: Int) lista
  putStrLn "Editando veículo: "
  putStrLn $ listVehicle [veicReturn]
  
  let listaAtualizada = rmVehicle (read vehicleIdEdit :: Int) lista
  putStrLn "Nova placa: "
  _plate <- getLine
  putStrLn "Nova quilometragem: "
  _kms <- getLine
  putStrLn "Nova categoria: "
  _category <- getLine
  putStrLn "Novo modelo: "
  _model <- getLine
  putStrLn "Nova marca: "
  _brand <- getLine
  putStrLn "Nova cor: "
  _color <- getLine
  putStrLn "Novo ano: "
  _year <- getLine

  let ve = VehicleInstance {
    vehicleId = vehicleId veicReturn, 
    plate     = _plate, 
    kms       = read _kms :: Int, 
    category  = _category, 
    model     =_model, 
    brand     = _brand, 
    color     = _color, 
    year      = read _year :: Int
  }
  let list = addVehicleToList listaAtualizada ve
  
  writeVehicleToJSON $ sortVehicleById list

  putStrLn "\nO veiculo antigo: "
  putStrLn $ listVehicle [veicReturn]
  putStrLn "foi editado para: "
  putStrLn $ listVehicle [ve]

sortVehicleById :: [Vehicle] -> [Vehicle]
sortVehicleById = sortOn vehicleId

-- Remove Vehicle
optionRemoveVehicle :: IO()
optionRemoveVehicle = do 
  putStrLn "\n\n\n### Remoção de veículo ###\n\n\n"
  putStrLn "Índice do veículo: "
  _vehicleId <- getLine
  lista <- readVehiclesFromJSON
  let listaAtualizada = rmVehicle (read _vehicleId :: Int) lista
  writeVehicleToJSON listaAtualizada
  putStrLn "Lista atualizada:"
  printVehicles listaAtualizada

rmVehicle :: Int -> [Vehicle] -> [Vehicle]
rmVehicle _ []                       = []
rmVehicle x (y:ys) 
  | x == vehicleId y = rmVehicle x ys
  | otherwise = y : rmVehicle x ys

-- List Vehicles
getVehicle :: Int -> [Vehicle] -> Maybe Vehicle
getVehicle _ [] = Nothing
getVehicle y (x:xs)  | y == vehicleId x = Just x
                     | otherwise = getVehicle y xs

getVehicleViaPlate :: Int -> [Vehicle] -> Maybe Vehicle
getVehicleViaPlate _ [] = Nothing
getVehicleViaPlate y (x:xs)  | y == vehicleId x = Just x
                     | otherwise = getVehicleViaPlate y xs

printVehicles :: [Vehicle] -> IO ()
printVehicles vehicles = putStrLn ("\n\nID - Placa - Categoria - Marca - Modelo - Cor - Ano - Kms\n\n" ++ listVehicle vehicles ++ "\n")

listVehicle :: [Vehicle] -> String
listVehicle [] = ""
listVehicle (x:xs) = toStringVehicle x ++ ['\n'] ++ listVehicle xs

toStringVehicle :: Vehicle -> String
toStringVehicle VehicleInstance {
  vehicleId    = _vehicleId, 
  plate        = _plate, 
  kms          = _kms, 
  category     = _category, 
  brand        = _brand, 
  model        = _model,
  color        = _color, 
  year         = _year } = 
    show _vehicleId ++ " - " ++ 
    _plate          ++ " - " ++ 
    _category       ++ " - " ++ 
    _brand          ++ " - " ++ 
    _model          ++ " - " ++
    _color          ++ " - " ++ 
    show _year      ++ " - " ++ 
    show _kms       ++ "km" 

-- JSON IO
writeVehicleToJSON :: [Vehicle] -> IO ()
writeVehicleToJSON list = do
  B.writeFile "db/vehicles.json" (encode list)

readVehiclesFromJSON :: IO [Vehicle]
readVehiclesFromJSON = do
  input <- B.readFile "db/vehicles.json"
  let vehicles = decode input :: Maybe [Vehicle]
  case vehicles of
    Nothing -> return []
    Just vehicles -> return vehicles
