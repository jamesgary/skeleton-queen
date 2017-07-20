module Main exposing (main)

import AnimationFrame
import Common exposing (..)
import Html
import Time
import View exposing (view)


--exposing (Time)


skeletonCost =
    10


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
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SpawnSkeleton ->
            ( spawnSkeleton model, Cmd.none )

        Tick time ->
            ( model
                |> updateTime time
                |> regenMana
            , Cmd.none
            )


updateTime : Time.Time -> Model -> Model
updateTime time model =
    { model
        | time = time
        , deltaTime = (time - model.time) / 1000
    }


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


regenMana : Model -> Model
regenMana model =
    if model.mana < model.maxMana then
        { model | mana = model.mana + (model.regenMana * model.deltaTime) }
    else
        model


subscriptions : Model -> Sub Msg
subscriptions model =
    --Time.every (0.25 * Time.second) Tick
    AnimationFrame.times Tick
