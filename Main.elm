module Main exposing (..)

import AnimationFrame
import Common exposing (..)
import EveryDict as ED
import Html
import Stuff exposing (..)
import Time
import View exposing (view)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { stuffStats =
            ED.fromList
                [ ( Mana
                  , { amt = 50
                    , max = 100
                    , cost = ED.empty
                    , outputPerSec = ED.empty
                    }
                  )
                , ( Crystal
                  , { amt = 1
                    , max = 100
                    , cost = ED.fromList [ ( Mana, crystalManaCost ) ]
                    , outputPerSec = ED.fromList [ ( Mana, 5 ) ]
                    }
                  )
                , ( Skel
                  , { amt = 1
                    , max = 100
                    , cost = ED.fromList [ ( Mana, 10 ) ]
                    , outputPerSec = ED.fromList [ ( Mana, -0.5 ) ]
                    }
                  )

                --, ( Flask
                --  , { amt = 1
                --    , max = 100
                --    , cost = ED.fromList [ ( Mana, 50 ) ]
                --    , outputPerSec = ED.fromList []
                --    }
                --  )
                ]
      , time = 0
      , deltaTime = 0
      , firstFramePassed = False
      , cachedCombinedStuffOutputs = ED.empty
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ stuffStats } as model) =
    case msg of
        Tick time ->
            if model.firstFramePassed then
                ( model
                    |> tickTime time
                    |> updateStuffs
                , Cmd.none
                )
            else
                ( model
                    |> tickTime time
                    |> passFirstFrame
                , Cmd.none
                )

        Buy stuff ->
            if canBuy stuff stuffStats then
                ( buyStuff stuff model, Cmd.none )
            else
                ( model, Cmd.none )


buyStuff : Stuff -> Model -> Model
buyStuff stuff ({ stuffStats } as model) =
    let
        cost =
            getCostOfStuff stuff model

        newStuffStats =
            ED.foldl deductCostFromStuffStats stuffStats cost

        stuffStats2 =
            addAmtToStuffStats stuff newStuffStats
    in
    { model | stuffStats = stuffStats2 }


addAmtToStuffStats : Stuff -> StuffStats -> StuffStats
addAmtToStuffStats stuff stuffStats =
    ED.update
        stuff
        (\maybeStat ->
            case maybeStat of
                Just stat ->
                    Just { stat | amt = stat.amt + 1 }

                Nothing ->
                    Nothing
        )
        stuffStats


deductCostFromStuffStats : Stuff -> Float -> StuffStats -> StuffStats
deductCostFromStuffStats stuff amt stuffStats =
    let
        stat_ =
            stat stuff stuffStats

        newStat =
            { stat_ | amt = stat_.amt - amt }
    in
    ED.insert stuff newStat stuffStats


getCostOfStuff : Stuff -> Model -> StuffAmts
getCostOfStuff stuff { stuffStats } =
    .cost (stat stuff stuffStats)


tickTime : Time.Time -> Model -> Model
tickTime time model =
    { model
        | time = time
        , deltaTime = (time - model.time) / 1000
    }


updateStuffs : Model -> Model
updateStuffs ({ deltaTime, stuffStats } as model) =
    let
        totalOutputsDict =
            combinedStuffOutputs stuffStats
    in
    { model
        | stuffStats = addStuffsToStuffsForFrame deltaTime totalOutputsDict stuffStats
        , cachedCombinedStuffOutputs = totalOutputsDict
    }


passFirstFrame : Model -> Model
passFirstFrame model =
    { model | firstFramePassed = True }


clampDown : number -> number -> number
clampDown max num =
    -- Given a max and num, clamp num between 0 and max
    clamp 0 max num


subscriptions : Model -> Sub Msg
subscriptions model =
    AnimationFrame.times Tick
