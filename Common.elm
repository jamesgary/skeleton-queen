module Common exposing (..)

import Time


type alias Model =
    { manaAmt : Float
    , flasksAmt : Float
    , crystalsAmt : Float
    , skel :
        { amt : Float
        , lumberjackAmt : Float
        , freeloaderAmt : Float
        }
    , lumberAmt : Float
    , config :
        { flaskStorage : Float
        , crystalManaPerSec : Float
        , flaskManaStorage : Float
        , lumberjackLumberPerSec : Float
        }
    , time : Time.Time
    , deltaTime : Time.Time
    , firstFramePassed : Bool
    , cache :
        { manaPerSec : Float
        , manaMax : Float
        , skelManaBurnPerSec : Float
        , crystalManaGenPerSec : Float
        , lumberGenPerSec : Float
        }
    }


type Msg
    = SpawnSkeleton
    | BuyCrystal
    | BuyFlask
    | SellSkeleton
    | AssignLumberjack
    | Tick Time.Time


skelManaCost =
    10


manaGenCost =
    50


crystalManaCost =
    20


flaskManaCost =
    50


canSellSkel : Model -> Bool
canSellSkel model =
    model.skel.amt > 0


canBuyCrystal : Model -> Bool
canBuyCrystal model =
    model.manaAmt > crystalManaCost


canBuyFlask : Model -> Bool
canBuyFlask model =
    model.manaAmt > flaskManaCost


canSpawnSkel : Model -> Bool
canSpawnSkel model =
    model.manaAmt > skelManaCost


canAssignLumberjack : Model -> Bool
canAssignLumberjack model =
    model.skel.freeloaderAmt > 0
