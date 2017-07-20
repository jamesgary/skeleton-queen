module Common exposing (..)

import Time


type alias Model =
    { mana : Float
    , maxMana : Float
    , regenMana : Float
    , skeletons : Float
    , time : Time.Time
    , deltaTime : Time.Time
    }


type Msg
    = SpawnSkeleton
    | Tick Time.Time
