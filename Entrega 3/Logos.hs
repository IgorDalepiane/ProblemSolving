module Logos where

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

logoRents :: IO ()
logoRents = do
    putStrLn " +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
    putStrLn " |G|e|r|e|n|c|i|a|r| |L|o|c|a|c|o|e|s|"
    putStrLn " +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
