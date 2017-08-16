module Common exposing (..)

import Dict
import EveryDict as ED
import Time


type alias Model =
    { stuffStats : ED.EveryDict Stuff Stat
    , time : Time.Time
    , deltaTime : Time.Time
    , firstFramePassed : Bool
    , cachedTotalOutputForFrame : ED.EveryDict Stuff Float
    }


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
    , cost : ED.EveryDict Stuff Float
    , outputPerSec : ED.EveryDict Stuff Float -- may eventually be just a coefficient with a static config
    }


type Msg
    = Tick Time.Time


zs : Stat
zs =
    -- zero stat, for defaults
    { amt = 0
    , max = 0
    , cost = ED.empty
    , outputPerSec = ED.empty
    }


updateStuffs : Model -> Model
updateStuffs ({ deltaTime, stuffStats } as model) =
    let
        totalOutputsDict =
            model.stuffStats
                -- list of all stats
                |> ED.values
                -- list of all output dicts
                |> List.map .outputPerSec
                -- merge all outputs together
                |> List.foldr mergeOutputs ED.empty
    in
    { model
        | stuffStats = addStuffsToStuffsForFrame deltaTime totalOutputsDict stuffStats
        , cachedTotalOutputForFrame = totalOutputsDict
    }


mergeOutputs : ED.EveryDict Stuff Float -> ED.EveryDict Stuff Float -> ED.EveryDict Stuff Float
mergeOutputs stuffOutputDictA stuffOutputDictB =
    ED.foldl combineOutputs stuffOutputDictA stuffOutputDictB


combineOutputs : Stuff -> Float -> ED.EveryDict Stuff Float -> ED.EveryDict Stuff Float
combineOutputs stuff outputAmt stuffOutputDict =
    ED.update
        stuff
        (\maybeAmt -> Just (Maybe.withDefault 0 maybeAmt + outputAmt))
        stuffOutputDict


addStuffsToStuffsForFrame : Time.Time -> ED.EveryDict Stuff Float -> ED.EveryDict Stuff Stat -> ED.EveryDict Stuff Stat
addStuffsToStuffsForFrame deltaTime stuffOutputDict stuffStatDict =
    ED.foldl (addOutputForFrame deltaTime) stuffStatDict stuffOutputDict


addOutputForFrame : Time.Time -> Stuff -> Float -> ED.EveryDict Stuff Stat -> ED.EveryDict Stuff Stat
addOutputForFrame deltaTime stuffKey outputAmt stuffStatDict =
    let
        additionalOutputAmt =
            deltaTime * outputAmt
    in
    ED.update
        stuffKey
        (\maybeStat ->
            case maybeStat of
                Just stat ->
                    Just { stat | amt = min stat.max (stat.amt + additionalOutputAmt) }

                Nothing ->
                    Just { zs | amt = additionalOutputAmt }
        )
        stuffStatDict
