module Common exposing (..)

import Time


type alias Model =
    { mana : Int
    , maxMana : Int
    , skeletons : Int
    , time : Time.Time
    , deltaTime : Time.Time
    }


type Msg
    = SpawnSkeleton
    | Tick Time.Time
