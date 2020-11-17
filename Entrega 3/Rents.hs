{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

module Rents where

import Customers
import Vehicles
import Data.Aeson
import qualified Data.ByteString.Lazy as B
import GHC.Generics
import Data.Maybe (isNothing)

data Rent = RentInstance { 
  rentId, customerRentId, vehicleRentId, vehicleKms :: Int,
  customerRentName, customerRentCNH, vehicleRentCategory, vehicleRentPlate, rentDate, returnDate :: String,
  returned :: Bool
} deriving (Generic, Show)

instance ToJSON Rent where
  toEncoding = genericToEncoding defaultOptions

instance FromJSON Rent

menuRents :: IO ()
menuRents = do
  putStrLn "1 - Cadastrar nova locacao"
  putStrLn "2 - Cadastrar devolucao"
  putStrLn "Opcao: "
  option <- getLine
  if read option == 0 then putStrLn "Retornando..." else do selectedOptionRents (read option)

selectedOptionRents :: Int -> IO ()
selectedOptionRents opcao
  | opcao == 1 = do rent
  | opcao == 2 = do devolution
  | otherwise = putStrLn "Opcao invalida."

-- Rent

getAvailableVehicles :: [Vehicle] -> [Rent] -> [Rent] -> [Vehicle]
getAvailableVehicles [] _ _ = []
getAvailableVehicles x _ [] = x
getAvailableVehicles (x:xs) [] z = x : getAvailableVehicles xs z z
getAvailableVehicles (x:xs) (y:ys) z 
  | vehicleId x == vehicleRentId y = getAvailableVehicles xs z z
  | vehicleId x /= vehicleRentId y = getAvailableVehicles (x:xs) ys z

rent :: IO()
rent = do
  putStrLn "###Locar veiculo###"
  putStrLn "Carros disponiveis: "

  vehicles <- readVehiclesFromJSON
  rents <- readRentFromJSON

  -- getAvailableVehicles (Lista dos veiculos) (ista de rents a ser iterada) (Backup das rents)
  let availableVehicles = getAvailableVehicles vehicles rents rents
  printVehicles availableVehicles

  putStrLn "Id do veiculo a ser locado: "
  _vehicleId <- getLine
  let ve = getVehicle (read _vehicleId :: Int) availableVehicles
  
  if isNothing ve
    then do
      putStrLn "\nErro! Veiculo não encontrado. Digite 1 para continuar ou 0 para voltar."
      opt <- getLine
      if read opt == 1 then rent else menuRents
    else do
      let Just justVe = ve 
      customers <- readCustomersFromJSON
      putStrLn "Id do cliente locador: "
      _customerId <- getLine
      
      let cust = getCustomer (read _customerId :: Int) customers

      if isNothing cust
        then do
          putStrLn "\nErro! Cliente nao encontrado. Digite 1 para continuar ou 0 para voltar."
          opt <- getLine
          if read opt == 1 then rent else menuRents
        else do
          let Just justCust = cust 
          putStrLn "Data de locacao (dd/mm/yyyy): "
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
            returnDate          = "", 
            returned            = False
          }

          let listRents = addRentsToList rents newRent

          writeRentToJSON listRents

          putStrLn "\nO veiculo foi locado com sucesso. \n"

genRentId :: [Rent] -> Int
genRentId [] = 0
genRentId x = do 
              let lastRent = last x
              rentId lastRent + 1

-- devolution

devolution :: IO ()
devolution = do
  putStrLn "\n\nRealizar devolucao de um veiculo"
  putStrLn "\nID da locacao: "
  rentIdGet <- getLine
  putStrLn "\nQuilometragem rodada: "
  kmGet <- getLine
  putStrLn "\nData de devolucao: (dd/mm/yyyy)"
  retDate <- getLine
  -- read list
  listRents <- readRentFromJSON
  -- search rent
  let Just returnedRent = getRent (read rentIdGet :: Int) listRents
  let listRentsUpdated = rmRent (read rentIdGet :: Int) listRents
  -- CUSTOMER
  ---- read customer
  lista <- readCustomersFromJSON
  let customerReturnedRent = customerRentId returnedRent
  let Just returnedCustomer = getCustomer customerReturnedRent lista
  let listaAtualizada = rmCustomer customerReturnedRent lista
  ---- change points
  let points = div (read kmGet :: Int)  100
  let customerRentUpdated = CustomerInstance {customerId = customerId returnedCustomer, name = name returnedCustomer, cnh = cnh returnedCustomer, programPoints = points}
  ---- add customer to list
  let listWithNewCustomer = addCustomerToList listaAtualizada customerRentUpdated
  writeCustomerToJSON listWithNewCustomer
  -- change status
  let newRent = RentInstance {
    rentId              = rentId returnedRent, 
    customerRentId      = customerReturnedRent, 
    vehicleRentId       = vehicleRentId returnedRent,
    customerRentName    = customerRentName returnedRent,
    customerRentCNH     = customerRentCNH returnedRent,
    vehicleRentCategory = vehicleRentCategory returnedRent,
    vehicleRentPlate    = vehicleRentPlate returnedRent,
    vehicleKms          = vehicleKms returnedRent,
    rentDate            = rentDate returnedRent, 
    returnDate          = retDate, 
    returned            = True
  }
  let listRentsNewStatus = addRentsToList  listRentsUpdated newRent
  writeRentToJSON listRentsNewStatus
  let pointsRetunedCustomer = programPoints customerRentUpdated
  putStrLn $ "\nDevolucao realizada com sucesso, o cliente " ++ name customerRentUpdated ++ " esta com "++ show pointsRetunedCustomer ++" pontos no programa de fidelidade\n"

-- List

addRentsToList :: [Rent] -> Rent -> [Rent]
addRentsToList [] x = [x]
addRentsToList x ve = x ++ [ve]

getRent :: Int -> [Rent] -> Maybe Rent
getRent _ [] = Nothing
getRent y (x : xs) | y == rentId x = Just x
                   | otherwise = getRent y xs

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
