{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

module Rents where
import Customers
import Vehicles
    (sortVehicleById, rmVehicle, addVehicleToList, writeVehicleToJSON, year, color, model, brand, Vehicle(VehicleInstance), state,  getVehicle,
      printVehicles,
      readVehiclesFromJSON,
      Vehicle(vehicleId, category, plate, kms, categoryPrice,
              kilometerPrice) )
import Data.Aeson
import qualified Data.ByteString.Lazy as B
import GHC.Generics
import Data.List
import Data.Time

import Control.Exception
import Data.Data
import Data.Maybe
import Control.Monad
import System.Console.ANSI
import Logos

data RentException = 
  VeiculoNaoEncontrado 
  | ClienteRentNaoEncontrado 
  | LocacaoNaoEncontrada 
  | NaoQuisContinuar 
  | PontosInsuficientes 
  | NenhumaLocacaoEmAberto
  | NenhumVeiculoDisponivel
  deriving (Show, Typeable)

data Rent = RentInstance { 
  rentId, customerRentId, vehicleRentId, vehicleKms :: Int,
  customerRentName, customerRentCNH, vehicleRentCategory, vehicleRentPlate, rentDate, returnDate :: String,
  paidValue :: Float,
  returned :: Bool
} deriving (Generic, Show)

instance Exception RentException

instance ToJSON Rent where
  toEncoding = genericToEncoding defaultOptions

instance FromJSON Rent

menuRents :: IO ()
menuRents = do
  logoRents
  putStrLn "1 - Cadastrar nova locacao"
  putStrLn "2 - Cadastrar devolucao"
  putStrLn "3 - Listar locacoes"
  putStrLn "0 - Voltar"
  putStrLn "Opcao: "
  option <- getLine
  if read option == 0 then return () else do selectedOptionRents (read option)

selectedOptionRents :: Int -> IO ()
selectedOptionRents opcao
  | opcao == 1 = do 
      result <- try rent :: IO (Either RentException ())
      case result of
        Left ex -> do clearScreen; putStrLn $ "\nErro: " ++ show ex; menuRents
        Right _ -> menuRents
  | opcao == 2 = do
      result <- try devolution :: IO (Either RentException ())
      case result of
        Left ex -> do clearScreen; putStrLn $ "\nErro: " ++ show ex; menuRents
        Right _ -> menuRents
  | opcao == 3 = do list <- readRentFromJSON; printRents list; menuRents
  | otherwise = putStrLn "Opcao invalida."

-- Rent

getAvailableVehicles :: [Vehicle] -> [Rent] -> [Rent] -> [Vehicle]
getAvailableVehicles [] _ _ = []
getAvailableVehicles x _ [] = x
getAvailableVehicles (x:xs) [] z = x : getAvailableVehicles xs z z
getAvailableVehicles (x:xs) (y:ys) z 
  | vehicleId x == vehicleRentId y = getAvailableVehicles xs z z
  | vehicleId x /= vehicleRentId y = getAvailableVehicles (x:xs) ys z

rmBrokenRented :: [Vehicle] -> [Vehicle]
rmBrokenRented [] = []
rmBrokenRented (x:xs) | state x == "Disponivel" = x : rmBrokenRented xs
                      | otherwise = rmBrokenRented xs

rent :: IO()
rent = do
  vehicles <- readVehiclesFromJSON
  rents <- readRentFromJSON
  let availableVehicles = rmBrokenRented vehicles
  when (null availableVehicles) $ throw NenhumVeiculoDisponivel

  clearScreen
  putStrLn "\nRealizar LOCACAO de um veiculo"
  putStrLn "Carros disponiveis: "
  printVehicles availableVehicles

  putStrLn "Id do veiculo a ser locado: "
  _vehicleId <- getLine
  let ve = getVehicle (read _vehicleId :: Int) availableVehicles
  when (isNothing ve) $ throw VeiculoNaoEncontrado

  let Just justVe = ve 
  let newVehicle = VehicleInstance {
    vehicleId    = vehicleId justVe, 
    plate        = plate justVe, 
    kms          = kms justVe, 
    category     = category justVe, 
    categoryPrice= categoryPrice justVe,
    kilometerPrice= kilometerPrice justVe,
    brand        = brand justVe, 
    model        = model justVe,
    color        = color justVe, 
    year         = year justVe, 
    state        = "Alugado"
  }
  customers <- readCustomersFromJSON
  putStrLn "Clientes:"
  printCustomers customers
  putStrLn "Id do cliente locador: "
  _customerId <- getLine
  
  let cust = getCustomer (read _customerId :: Int) customers
  when (isNothing cust) $ throw ClienteRentNaoEncontrado

  let Just justCust = cust 
  putStrLn "Data de locacao (formato: dd/mm/aaaa):"
  _date <- getLine
  let newRent = RentInstance {
    rentId              = genRentId rents, 
    customerRentId      = read _customerId :: Int , 
    vehicleRentId       = read _vehicleId :: Int,
    customerRentName    = name justCust,
    customerRentCNH     = cnh justCust,
    vehicleRentCategory = category justVe,
    vehicleRentPlate    = plate justVe,
    vehicleKms          = kms justVe,
    rentDate            = _date, 
    paidValue           = 0,
    returnDate          = "", 
    returned            = False
  }

  writeRentToJSON $ addRentsToList rents newRent
  -- update vehicle state
  writeVehicleToJSON $ sortVehicleById $ addVehicleToList (rmVehicle (vehicleId justVe) vehicles) newVehicle

  clearScreen
  putStrLn "O veiculo foi locado com sucesso."

genRentId :: [Rent] -> Int
genRentId [] = 0
genRentId x = do 
              let lastRent = last x
              rentId lastRent + 1

-- devolution

devolution :: IO()
devolution = do
  -- read list
  listRents <- readRentFromJSON
  let emAberto = getOpenRents listRents
  when (null emAberto) $ throw NenhumaLocacaoEmAberto 

  clearScreen
  putStrLn "\nRealizar DEVOLUCAO de um veiculo"
  putStrLn "Locacoes em Aberto: "
  printRents emAberto
  
  putStrLn "\nID da locacao: "
  _rentId <- getLine
  let rent = getRent (read _rentId :: Int) listRents
  when (isNothing rent) $ throw LocacaoNaoEncontrada

  let Just justRent = rent 
  putStrLn "\nQuilometragem rodada: "
  kmGet <- getLine
  putStrLn "\nData de devolucao (formato: dd/mm/aaaa): "
  dateString <- getLine
  let _rentDate = parseTimeOrError True defaultTimeLocale "%d/%m/%Y" (rentDate justRent) :: Day
  let _returnDate = parseTimeOrError True defaultTimeLocale "%d/%m/%Y" dateString :: Day
  let dias = diffDays _returnDate _rentDate
  -- remove a rent atual para modificar
  let listRentsUpdated = rmRent (read _rentId :: Int) listRents
  ---- read customer
  lista <- readCustomersFromJSON
  let custId = customerRentId justRent
  let Just cust = getCustomer custId lista
  let listaAtualizada = rmCustomer custId lista
  -- calculate rent value
  listVehicles <- readVehiclesFromJSON
  let vehicle = getVehicle (vehicleRentId justRent) listVehicles
  let Just justVehicle = vehicle
  let rentValue = (fromIntegral dias * categoryPrice justVehicle) + ((read kmGet::Float) * kilometerPrice justVehicle)
  
  putStrLn $ "O valor da locacao é: R$ " ++ show rentValue
  putStrLn $ "O cliente tem (" ++ show (programPoints cust) ++ ") pontos de fidelidade que podem ser usados: "
  _p <- getLine
  let _points = read _p :: Int
  when (_points > programPoints cust) $ throw PontosInsuficientes -- doesn't use new points

  let _remPoints = programPoints cust - _points
  let discount = rentValue * ((read _p :: Float) / 10000) -- float *
  let newRentValue = rentValue - discount
  putStrLn $ "Valor final: R$ " ++ show newRentValue
  putStrLn $ "Pontos restantes: " ++ show _remPoints
  putStrLn "Continuar? 1-Sim 0-Nao"
  _op <- getLine
  when (read _op == 0) $ throw NaoQuisContinuar
  -- deduct points
  let _newPoints = div (read kmGet :: Int)  100 -- new points
  let updatedCust = CustomerInstance {
    customerId = custId, 
    name = name cust, 
    cnh = cnh cust, 
    programPoints = _newPoints + _remPoints
  }
  -- add customer to list
  let listWithNewCustomer = addCustomerToList listaAtualizada updatedCust
  writeCustomerToJSON $ sortCustomerById listWithNewCustomer
  -- change status
  let newVehicle = VehicleInstance {
    vehicleId    = vehicleId justVehicle, 
    plate        = plate justVehicle, 
    kms          = kms justVehicle, 
    category     = category justVehicle, 
    categoryPrice= categoryPrice justVehicle,
    kilometerPrice= kilometerPrice justVehicle,
    brand        = brand justVehicle, 
    model        = model justVehicle,
    color        = color justVehicle, 
    year         = year justVehicle, 
    state        = "Disponivel"
  }
  let newRent = RentInstance {
    rentId              = rentId justRent, 
    customerRentId      = custId, 
    vehicleRentId       = vehicleRentId justRent,
    customerRentName    = customerRentName justRent,
    customerRentCNH     = customerRentCNH justRent,
    vehicleRentCategory = vehicleRentCategory justRent,
    vehicleRentPlate    = vehicleRentPlate justRent,
    vehicleKms          = vehicleKms justRent,
    rentDate            = rentDate justRent, 
    returnDate          = show $ formatTime defaultTimeLocale "%d/%m/%Y" _returnDate, 
    paidValue           = newRentValue,
    returned            = True
  }

  writeRentToJSON $ addRentsToList listRentsUpdated newRent
  -- update vehicle state
  writeVehicleToJSON $ sortVehicleById $ addVehicleToList (rmVehicle (vehicleId justVehicle) listVehicles) newVehicle
  clearScreen
  putStrLn $ "Devolucao realizada com sucesso\nO cliente " ++ name updatedCust ++ " recebeu "++ show _newPoints ++" pontos e agora esta com "++ show (programPoints updatedCust) ++" pontos totais no programa de fidelidade"

-- List
sortRentById :: [Rent] -> [Rent]
sortRentById = sortOn rentId

addRentsToList :: [Rent] -> Rent -> [Rent]
addRentsToList [] x = [x]
addRentsToList x ve = x ++ [ve]

getRent :: Int -> [Rent] -> Maybe Rent
getRent _ [] = Nothing
getRent y (x : xs) | y == rentId x = Just x
                   | otherwise = getRent y xs

getOpenRents :: [Rent] -> [Rent]
getOpenRents [] = []
getOpenRents (x:xs) | not (returned x) = x : getOpenRents xs 
                    | otherwise = getOpenRents xs

printRents :: [Rent] -> IO ()
printRents rents = putStrLn (listRent rents ++ "\n")

listRent :: [Rent] -> String
listRent [] = ""
listRent (x:xs) = toStringRent x ++ ['\n'] ++ listRent xs

toStringRent :: Rent -> String
toStringRent RentInstance {
  rentId              = _rentId, 
  vehicleRentId       = _vehicleRentId, 
  customerRentId      = _customerRentId, 
  vehicleKms          = _vehicleKms, 
  customerRentName    = _customerRentName, 
  customerRentCNH     = _customerRentCNH, 
  vehicleRentCategory = _vehicleRentCategory, 
  vehicleRentPlate    = _vehicleRentPlate, 
  rentDate            = _rentDate,
  returnDate          = _returnDate } = 
    "\nID: "              ++ show _rentId         ++ "\n" ++
    "ID Veiculo: "        ++ show _vehicleRentId  ++ "\n" ++
    "ID Cliente: "        ++ show _customerRentId ++ "\n" ++ 
    "Quilometragem: "     ++ show _vehicleKms     ++ "\n" ++ 
    "Cliente Nome: "      ++ _customerRentName    ++ "\n" ++ 
    "Cliente CNH: "       ++ _customerRentCNH     ++ "\n" ++ 
    "Veiculo Categoria: " ++ _vehicleRentCategory ++ "\n" ++
    "Veiculo Placa: "     ++ _vehicleRentPlate    ++ "\n" ++ 
    "Data Locacao: "      ++ _rentDate            ++ "\n" ++
    "Data Retorno: "      ++ _returnDate           

-- Remove Rent

rmRent :: Int -> [Rent] -> [Rent]
rmRent _ [] = []
rmRent x (y : ys)
  | x == rentId y = rmRent x ys
  | otherwise = y : rmRent x ys

-- JSON actions

writeRentToJSON :: [Rent] -> IO ()
writeRentToJSON list = do
  B.writeFile "db/rents.json" (encode list)

readRentFromJSON :: IO [Rent]
readRentFromJSON = do
  input <- B.readFile "db/rents.json"

  let rents = decode input :: Maybe [Rent]

  case rents of
    Nothing -> return []
    Just rents -> return rents
