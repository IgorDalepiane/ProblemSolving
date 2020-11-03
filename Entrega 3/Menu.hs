module Menu where

import Vehicles (menuVehicles)
import Clients (menuClient)

menu :: IO ()
menu = do
    putStrLn "1 - Gerenciar Veiculos"
    putStrLn "2 - Gerenciar Clientes"
    putStrLn "3 - Gerar Relatorio"
    putStrLn "4 - Gerar Orcamento"
    putStrLn "0 - Sair" 
    putStrLn "Opcao: "
    option <- getLine
    if (read option) == 0 then putStrLn("Obrigado por utilizar nosso sistema!") else do selectedOption (read option)


selectedOption :: Int -> IO()
selectedOption opcao | opcao == 1 = do {logoVehicles; menuVehicles; menu} 
                     | opcao == 2 = do {logoClient; menuClient; menu}
                     | opcao == 3 = do {logoReport; putStrLn "Opcao em Desenvolvimento"; menu}
                     | opcao == 4 = do {logoBudget; putStrLn "Opcao em Desenvolvimento"; menu}
                     | otherwise =  do {putStrLn "Esta opcao nao e valida. Por favor selecione uma opcao listada acima"; logo;menu}


------------------------LOGOS------------------------
logo :: IO ()
logo = do
    putStrLn "    __    ____  _________    ____ " 
    putStrLn "   / /   / __ \\/ ____/   |  / __ \\" 
    putStrLn "  / /   / / / / /   / /| | / /_/ /" 
    putStrLn " / /___/ /_/ / /___/ ___ |/ _, _/ " 
    putStrLn "/_____/\\____/\\____/_/  |_/_/ |_|  "
    putStrLn "                                    "

logoClient :: IO ()
logoClient = do
    putStrLn " +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
    putStrLn " |G|e|r|e|n|c|i|a|r| |C|l|i|e|n|t|e|s|"
    putStrLn " +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+"

logoVehicles :: IO ()
logoVehicles = do
    putStrLn " +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
    putStrLn " |G|e|r|e|n|c|i|a|r| |V|e|i|c|u|l|o|s|"
    putStrLn " +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+"

logoReport :: IO ()
logoReport = do
    putStrLn " +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+"
    putStrLn " |G|e|r|a|r| |R|e|l|a|t|o|r|i|o|"
    putStrLn " +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+"

logoBudget :: IO ()
logoBudget = do
    putStrLn " +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+"
    putStrLn " |G|e|r|a|r| |O|r|c|a|m|e|n|t|o|"
    putStrLn " +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+"