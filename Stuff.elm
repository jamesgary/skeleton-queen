module Stuff
    exposing
        ( addStuffsToStuffsForFrame
        , amt
        , canBuy
        , combinedStuffOutputs
        , stat
        )

import Common exposing (..)
import EveryDict as ED
import Time


zs : Stat
zs =
    -- zero stat, for defaults
    { amt = 0
    , max = 0
    , cost = ED.empty
    , outputPerSec = ED.empty
    }


amt : Stuff -> StuffAmts -> Float
amt stuff stuffAmts =
    Maybe.withDefault 0 (ED.get stuff stuffAmts)


stat : Stuff -> StuffStats -> Stat
stat stuff stuffStats =
    Maybe.withDefault zs (ED.get stuff stuffStats)


combinedStuffOutputs : StuffStats -> StuffAmts
combinedStuffOutputs stuffStats =
    stuffStats
        -- list of all stats
        |> ED.values
        -- list of all output dicts
        |> List.map .outputPerSec
        -- merge all outputs together
        |> List.foldr mergeOutputs ED.empty


mergeOutputs : StuffAmts -> StuffAmts -> StuffAmts
mergeOutputs stuffOutputDictA stuffOutputDictB =
    ED.foldl
        (\stuff outputAmt stuffOutputDict ->
            ED.update
                stuff
                (\maybeAmt ->
                    Just (Maybe.withDefault 0 maybeAmt + outputAmt)
                )
                stuffOutputDict
        )
        stuffOutputDictA
        stuffOutputDictB


addStuffsToStuffsForFrame : Time.Time -> StuffAmts -> StuffStats -> StuffStats
addStuffsToStuffsForFrame deltaTime stuffOutputDict stuffStatDict =
    ED.foldl (addOutputToStuffsForFrame deltaTime) stuffStatDict stuffOutputDict


addOutputToStuffsForFrame : Time.Time -> Stuff -> Float -> StuffStats -> StuffStats
addOutputToStuffsForFrame deltaTime stuffKey outputAmt stuffStatDict =
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


canBuy : Stuff -> StuffStats -> Bool
canBuy stuff stuffStats =
    case ED.get stuff stuffStats of
        Just stat ->
            ED.toList stat.cost
                |> List.all
                    (\( stuff, cost ) ->
                        case ED.get stuff stuffStats of
                            Just stat ->
                                stat.amt >= cost

                            Nothing ->
                                False
                    )

        Nothing ->
            False
