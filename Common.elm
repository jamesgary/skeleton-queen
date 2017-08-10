module Common exposing (..)

import Time


type alias Model =
    { manaAmt : Float
    , flasksAmt : Float
    , crystalsAmt : Float
    , lumberAmt : Float
    , goldAmt : Float
    , freeloaderAmt : Float
    , skel :
        { lumberjackAmt : Float
        , minerAmt : Float
        }
    , config :
        { flaskStorage : Float
        , crystalManaPerSec : Float
        , flaskManaStorage : Float
        , lumberjackLumberPerSec : Float
        , minerGoldPerSec : Float
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
        , goldGenPerSec : Float
        }
    }


type Msg
    = SpawnSkeleton
    | BuyCrystal
    | BuyFlask
    | SellSkeleton
    | Assign Job
    | Fire Job
    | Tick Time.Time


type Job
    = Lumberjack
    | Miner


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
    model.freeloaderAmt > 0


canBuyCrystal : Model -> Bool
canBuyCrystal model =
    model.manaAmt > crystalManaCost


canBuyFlask : Model -> Bool
canBuyFlask model =
    model.manaAmt > flaskManaCost


canSpawnSkel : Model -> Bool
canSpawnSkel model =
    model.manaAmt > skelManaCost


skelAmt : Model -> Float
skelAmt model =
    -- TODO: REFACTOR
    model.freeloaderAmt + model.skel.lumberjackAmt + model.skel.minerAmt


canAssignSkel : Model -> Bool
canAssignSkel model =
    model.freeloaderAmt > 0


canFireLumberjack : Model -> Bool
canFireLumberjack model =
    model.skel.lumberjackAmt > 0


canFireMiner : Model -> Bool
canFireMiner model =
    model.skel.minerAmt > 0
