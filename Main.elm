module Main exposing (main)

import AnimationFrame
import Common exposing (..)
import Html
import Time
import View exposing (view)


--exposing (Time)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { mana = 100
      , maxMana = 100
      , regenMana = 4
      , skeletons = 0
      , time = 0
      , deltaTime = 0
      , manaGenerators = 0
      , skelManaBurnRate = -0.2
      , manaGeneratorsGenRate = 1
      , firstFramePassed = False
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SpawnSkeleton ->
            ( spawnSkeleton model, Cmd.none )

        BuyManaGen ->
            ( buyManaGen model, Cmd.none )

        Tick time ->
            if model.firstFramePassed then
                ( model
                    |> tickTime time
                    |> tickMana
                , Cmd.none
                )
            else
                ( model
                    |> tickTime time
                    |> passFirstFrame
                , Cmd.none
                )


tickTime : Time.Time -> Model -> Model
tickTime time model =
    { model
        | time = time
        , deltaTime = (time - model.time) / 1000
    }


passFirstFrame : Model -> Model
passFirstFrame model =
    { model | firstFramePassed = True }


spawnSkeleton : Model -> Model
spawnSkeleton model =
    let
        mana =
            model.mana

        skeletons =
            model.skeletons

        ( newMana, newSkeletons ) =
            if mana >= skeletonCost then
                ( mana - skeletonCost, skeletons + 1 )
            else
                ( mana, skeletons )
    in
    { model
        | skeletons = newSkeletons
        , mana = newMana
    }


buyManaGen : Model -> Model
buyManaGen model =
    let
        mana =
            model.mana

        ( newMana, newManaGens ) =
            if mana >= manaGenCost then
                ( mana - manaGenCost, model.manaGenerators + 1 )
            else
                ( mana, model.manaGenerators )
    in
    { model
        | manaGenerators = newManaGens
        , mana = newMana
    }


regenMana : Model -> Model
regenMana model =
    if model.mana < model.maxMana then
        { model
            | mana =
                model.mana
                    + (model.regenMana * model.deltaTime)
                    + (0.5 * model.manaGenerators * model.deltaTime)
                    |> min model.maxMana
        }
    else
        model


burnMana : Model -> Model
burnMana model =
    if model.mana > 0 then
        { model | mana = model.mana - skelBurn model |> max 0 }
    else
        model


tickMana : Model -> Model
tickMana model =
    { model
        | mana =
            model.mana
                + model.deltaTime
                * totalManaRate model
                |> clampDown model.maxMana
    }


clampDown : number -> number -> number
clampDown max num =
    -- Given a max and num, clamp num between 0 and max
    clamp 0 max num


subscriptions : Model -> Sub Msg
subscriptions model =
    --Time.every (0.25 * Time.second) Tick
    AnimationFrame.times Tick
