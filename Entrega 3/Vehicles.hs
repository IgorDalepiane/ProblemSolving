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
import Data.List ( sortOn )
import Logos ( logoVehicles )
import Control.Monad ( when )
import Control.Exception ( try, throw, Exception )
import System.Console.ANSI ( clearScreen )
import Data.Maybe ( isNothing )
import Data.Data ( Typeable )

data VehicleException = 
  NenhumVeiculoCadastrado
  | VeiculoNaoEncontrado
  deriving (Show, Typeable)

data Vehicle = VehicleInstance {
  vehicleId, kms, year :: Int,
  categoryPrice, kilometerPrice :: Float,
  plate, category, model, brand, color, state :: String
} deriving (Generic, Show)

instance ToJSON Vehicle where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON Vehicle

instance Exception VehicleException

menuVehicles :: IO()
menuVehicles = do
  logoVehicles
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
  | option == 2 = do 
    result <- try optionUpdateVehicle :: IO (Either VehicleException ())
    case result of
      Left ex -> do clearScreen; putStrLn $ "\nErro: " ++ show ex; menuVehicles
      Right _ -> menuVehicles
  | option == 3 = do optionRemoveVehicle; menuVehicles
  | option == 4 = do lista <- readVehiclesFromJSON; printVehicles lista; menuVehicles
  | otherwise = do putStrLn "\n\nInsira uma opção válida.\n"; menuVehicles


-- Add Vehicle
optionAddVehicle :: IO()
optionAddVehicle = do
  clearScreen
  putStrLn "### Cadastro de veículo ###"
  putStrLn "Placa: "
  _plate <- getLine
  putStrLn "Quilometragem: "
  _kms <- getLine
  putStrLn "Categoria: "
  _category <- getLine
  putStrLn "Valor da diária da categoria: "
  _categoryPrice <- getLine
  putStrLn "Valor do quilometro da categoria: "
  _kilometerPrice <- getLine
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
    categoryPrice  = read _categoryPrice :: Float,
    kilometerPrice = read _kilometerPrice :: Float,
    model     =_model, 
    brand     = _brand, 
    color     = _color, 
    year      = read _year :: Int,
    state = "Disponivel"
  }
  let list = addVehicleToList lista ve
  writeVehicleToJSON list

  clearScreen
  putStrLn "Veiculo cadastrado com sucesso"
  
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
  lista <- readVehiclesFromJSON
  when (null lista) $ throw NenhumVeiculoCadastrado

  clearScreen
  putStrLn "###Editar um veículo###"
  putStrLn "Identificador do Veículo: "
  vehicleIdEdit <- getLine
  
  let veicReturn = getVehicle (read vehicleIdEdit :: Int) lista
  when (isNothing veicReturn) $ throw VeiculoNaoEncontrado
  let Just justVe = veicReturn
  putStrLn "Editando veículo: "
  putStrLn $ listVehicle [justVe]
  
  let listaAtualizada = rmVehicle (read vehicleIdEdit :: Int) lista
  putStrLn "Nova placa: "
  _plate <- getLine
  putStrLn "Nova quilometragem: "
  _kms <- getLine
  putStrLn "Nova categoria: "
  _category <- getLine
  putStrLn "Nova diária da categoria: "
  _categoryPrice <- getLine
  putStrLn "Novo valor do quilometro da categoria: "
  _kilometerPrice <- getLine
  putStrLn "Novo modelo: "
  _model <- getLine
  putStrLn "Nova marca: "
  _brand <- getLine
  putStrLn "Nova cor: "
  _color <- getLine
  putStrLn "Novo ano: "
  _year <- getLine
  putStrLn "Estado (Disponivel, Alugado, Manutencao): "
  _state <- getLine

  let ve = VehicleInstance {
    vehicleId = vehicleId justVe, 
    plate     = _plate, 
    kms       = read _kms :: Int, 
    category  = _category, 
    categoryPrice  = read _categoryPrice :: Float, 
    kilometerPrice  = read _kilometerPrice :: Float, 
    model     =_model, 
    brand     = _brand, 
    color     = _color, 
    year      = read _year :: Int,
    state = _state
  }
  let list = addVehicleToList listaAtualizada ve
  
  writeVehicleToJSON $ sortVehicleById list

  putStrLn "\nO veiculo antigo: "
  putStrLn $ listVehicle [justVe]
  putStrLn "foi editado para: "
  putStrLn $ listVehicle [ve]

sortVehicleById :: [Vehicle] -> [Vehicle]
sortVehicleById = sortOn vehicleId

-- Remove Vehicle
optionRemoveVehicle :: IO()
optionRemoveVehicle = do 
  lista <- readVehiclesFromJSON
  when (null lista) $ throw NenhumVeiculoCadastrado
  putStrLn "\n\n\n### Remoção de veículo ###\n\n\n"
  putStrLn "Índice do veículo: "
  _vehicleId <- getLine
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
printVehicles vehicles = putStrLn ("\n\nID - Placa - Categoria - Diária (R$) - Valor do Km (R$)- Marca - Modelo - Cor - Ano - Kms - Estado\n\n" ++ listVehicle vehicles)

listVehicle :: [Vehicle] -> String
listVehicle [] = ""
listVehicle (x:xs) = toStringVehicle x ++ ['\n'] ++ listVehicle xs

toStringVehicle :: Vehicle -> String
toStringVehicle VehicleInstance {
  vehicleId    = _vehicleId, 
  plate        = _plate, 
  kms          = _kms, 
  category     = _category, 
  categoryPrice= _categoryPrice,
  kilometerPrice= _kilometerPrice,
  brand        = _brand, 
  model        = _model,
  color        = _color, 
  year         = _year, 
  state        = _state } = 
    show _vehicleId ++ " - " ++ 
    _plate          ++ " - " ++ 
    _category       ++ " - " ++ 
    show _categoryPrice ++ " - " ++ 
    show _kilometerPrice ++ " - " ++
    _brand          ++ " - " ++ 
    _model          ++ " - " ++
    _color          ++ " - " ++ 
    show _year      ++ " - " ++ 
    show _kms       ++ "km - " ++
    _state          

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
