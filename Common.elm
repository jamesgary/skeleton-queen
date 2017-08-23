module Common exposing (..)

import Dict
import EveryDict as ED
import Time


type alias Model =
    { stuffStats : StuffStats
    , time : Time.Time
    , deltaTime : Time.Time
    , firstFramePassed : Bool
    , cachedCombinedStuffOutputs : StuffAmts
    }


type alias StuffStats =
    ED.EveryDict Stuff Stat


type alias StuffAmts =
    ED.EveryDict Stuff Float


type Stuff
    = Mana
    | Skel
    | HiredSkel Job
    | Gold
    | Wood
    | Fish
    | Flask
    | Crystal


type Job
    = Miner
    | Lumberjack
    | Fisher


type alias Stat =
    { amt : Float
    , max : Float
    , cost : StuffAmts
    , outputPerSec : StuffAmts -- may eventually be just a coefficient with a static config
    }


type Msg
    = Tick Time.Time
    | Buy Stuff


crystalManaCost =
    60


nameFromStuff : Stuff -> String
nameFromStuff stuff =
    case stuff of
        Mana ->
            "Mana"

        Skel ->
            "Skeletons"

        Gold ->
            "Gold"

        Wood ->
            "Wood"

        Fish ->
            "Fish"

        Flask ->
            "Flasks"

        Crystal ->
            "Crystals"

        HiredSkel job ->
            case job of
                Miner ->
                    "Miner"

                Lumberjack ->
                    "Lumberjack"

                Fisher ->
                    "Fisher"
