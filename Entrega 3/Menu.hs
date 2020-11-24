module Menu where

import Vehicles (menuVehicles)
import Customers (menuCustomers)
import Rents (menuRents)
import System.Console.ANSI
import Logos

menu :: IO ()
menu = do
    putStrLn "1 - Gerenciar Veiculos"
    putStrLn "2 - Gerenciar Clientes"
    putStrLn "3 - Gerenciar Locacoes"
    putStrLn "4 - Gerar Orcamento"
    putStrLn "0 - Sair" 
    putStrLn "Opcao: "
    option <- getLine
    if read option == 0 then putStrLn "Obrigado por utilizar nosso sistema!" else do selectedOption (read option)


selectedOption :: Int -> IO()
selectedOption opcao | opcao == 1 = do {clearScreen; menuVehicles; clearScreen; logo; menu} 
                     | opcao == 2 = do {clearScreen; logoClient; menuCustomers; clearScreen; logo; menu}
                     | opcao == 3 = do {clearScreen; menuRents; clearScreen; logo; menu}
                     | opcao == 4 = do {clearScreen; logoBudget; putStrLn "Opcao em Desenvolvimento"; clearScreen; logo; menu}
                     | otherwise =  do {putStrLn "Esta opcao nao e valida. Por favor selecione uma opcao listada acima"; clearScreen; logo; menu}
