module Common exposing (..)

import Time


type alias Model =
    { mana : Float
    , maxMana : Float
    , regenMana : Float
    , skeletons : Float
    , skelManaBurnRate : Float
    , time : Time.Time
    , deltaTime : Time.Time
    , firstFramePassed : Bool
    }


type Msg
    = SpawnSkeleton
    | Tick Time.Time
