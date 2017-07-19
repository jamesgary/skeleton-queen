module Main exposing (main)

import Common exposing (..)
import Html
import View exposing (view)


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
      , skeletons = 0
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SpawnSkeleton ->
            ( spawnSkeleton model, Cmd.none )


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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch []
