{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
module Vehicles where

import Data.Aeson
    ( decode,
      encode,
      defaultOptions,
      genericToEncoding,
      FromJSON,
      ToJSON(toEncoding) )
import GHC.Generics ( Generic )
import qualified Data.ByteString.Lazy as B
import Data.List (sortOn)

data Vehicle = Vehicle {
  vehicleId, kms, year :: Int,
  plate, category, model, brand, color :: String
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
  if read option == 0 then putStrLn "Retornando...\n" else do selectedOption (read option)

selectedOption :: Int -> IO()
selectedOption option | option == 1 = do {lista <- readFromJSON; printVehicles lista}
                      | option == 2 = do {optionAddVehicle}
                      | option == 3 = do {optionUpdateVehicle}
                      | option == 4 = do {optionRemoveVehicle}

removeItem :: Int -> [Vehicle] -> [Vehicle]
removeItem _ []                       = []
removeItem x (y:ys) | x == vehicleId y = removeItem x ys
                    | otherwise = y   : removeItem x ys

optionRemoveVehicle :: IO()
optionRemoveVehicle = do 
  putStrLn "\n\n\n### Remoção de veículo ###\n\n\n"
  putStrLn "Índice do veículo: "
  _vehicleId <- getLine
  lista <- readFromJSON
  let listaAtualizada = removeItem (read _vehicleId :: Int) lista
  writeToJSON listaAtualizada
  putStrLn "Lista atualizada:"
  printVehicles listaAtualizada

optionUpdateVehicle :: IO ()
optionUpdateVehicle = do
  putStrLn "\n\n###Editar um veículo###"
  putStrLn "Identificador do Veículo: "
  vehicleIdEdit <- getLine
  lista <- readFromJSON
  let veicReturn = returnItem (read vehicleIdEdit :: Int) lista

  putStrLn "Editando veículo: "
  putStrLn $ listVehicle [veicReturn]

  let listaAtualizada = removeItem (read vehicleIdEdit :: Int) lista
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

  let ve = Vehicle {vehicleId = vehicleId veicReturn, plate = _plate, kms = read _kms :: Int, category = _category, model=_model, brand = _brand, color = _color, year = read _year :: Int}
  let list = addToList listaAtualizada ve
  
  writeToJSON $ sortById list

  putStrLn "\nO veiculo antigo: "
  putStrLn $ listVehicle [veicReturn]
  putStrLn "foi editado para: "
  putStrLn $ listVehicle [ve]

sortById :: [Vehicle] -> [Vehicle]
sortById = sortOn vehicleId

returnItem :: Int -> [Vehicle] -> Vehicle
returnItem _ [] = error "Lista vazia!"
returnItem y (x:xs)  | y == vehicleId x = x
                     | otherwise = returnItem y xs

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
  lista <- readFromJSON
  let ve = Vehicle {vehicleId = generateVehicleId lista, plate = _plate, kms = read _kms :: Int, category = _category, model=_model, brand = _brand, color = _color, year = read _year :: Int}
  let list = addToList lista ve
  
  writeToJSON list

generateVehicleId :: [Vehicle] -> Int
generateVehicleId [] = 0
generateVehicleId x = do 
              let lastVeiculo = last x
              vehicleId lastVeiculo + 1

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
printVehicles vehicles = putStrLn ("\n\nID - Placa - Categoria - Marca - Modelo - Cor - Ano - Kms\n\n" ++ listVehicle vehicles ++ "\n")

listVehicle :: [Vehicle] -> String
listVehicle [] = ""
listVehicle (x:xs) = toStringVehicle x ++ ['\n'] ++ listVehicle xs

toStringVehicle :: Vehicle -> String
toStringVehicle Vehicle {
  vehicleId = _vehicleId, 
  plate = _plate, 
  kms = _kms, 
  category = _category, 
  brand = _brand, 
  model = _model,
  color = _color, 
  year = _year } = 
    show _vehicleId ++ " - " ++ 
    _plate ++ " - " ++ 
    _category ++ " - " ++ 
    _brand ++ " - " ++ 
    _model ++ " - " ++
    _color ++ " - " ++ 
    show _year ++ " - " ++ 
    show _kms ++ "km" 
