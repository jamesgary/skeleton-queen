module Main exposing (..)

import AnimationFrame
import Common exposing (..)
import EveryDict as ED
import Html
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
      , cachedTotalOutputForFrame = ED.empty
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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

        BuyCrystal ->
            ( model, Cmd.none )


tickTime : Time.Time -> Model -> Model
tickTime time model =
    { model
        | time = time
        , deltaTime = (time - model.time) / 1000
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
