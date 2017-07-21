module Common exposing (..)

import Time


type alias Model =
    { mana :
        { max : Float
        , amt : Float
        , genRate : Float
        , genAmt : Float
        }
    , baseManaRegen : Float
    , skeletons : Float
    , skelManaBurnRate : Float
    , manaGenerators : Float
    , manaGeneratorsGenRate : Float
    , time : Time.Time
    , deltaTime : Time.Time
    , firstFramePassed : Bool
    }


type Msg
    = SpawnSkeleton
    | BuyManaGen
    | Tick Time.Time


skelBurn : Model -> Float
skelBurn model =
    model.skeletons * model.skelManaBurnRate * model.deltaTime


remainingMana : Model -> Float
remainingMana model =
    model.mana.amt - skelBurn model


skeletonCost =
    10


manaGenCost =
    50
