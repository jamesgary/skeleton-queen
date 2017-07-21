module Common exposing (..)

import Time


type alias Model =
    { mana : Float
    , maxMana : Float
    , regenMana : Float
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
    model.mana - skelBurn model


totalManaRate : Model -> Float
totalManaRate model =
    model.regenMana
        + (model.manaGeneratorsGenRate * model.manaGenerators)
        + (model.skeletons * model.skelManaBurnRate)


skeletonCost =
    10


manaGenCost =
    50
