module Common exposing (..)


type alias Model =
    { mana : Int
    , maxMana : Int
    , skeletons : Int
    }


type Msg
    = SpawnSkeleton
