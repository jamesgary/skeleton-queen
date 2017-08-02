module Common exposing (..)

import Time


type alias Model =
    { mana :
        { amt : Float
        }
    , skel :
        { amt : Float
        , lumberjackAmt : Float
        , freeloaderAmt : Float
        }
    , flasks :
        { amt : Float
        }
    , crystals :
        { amt : Float
        }
    , config :
        { flaskStorage : Float
        , crystalManaPerSec : Float
        , flaskManaStorage : Float
        }
    , time : Time.Time
    , deltaTime : Time.Time
    , firstFramePassed : Bool
    , cache :
        { manaPerSec : Float
        , manaMax : Float
        , skelManaBurnPerSec : Float
        , crystalManaGenPerSec : Float
        }
    }


type Msg
    = SpawnSkeleton
    | BuyCrystal
    | BuyFlask
    | SellSkeleton
    | AssignLumberjack
    | Tick Time.Time


skeletonCost =
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
