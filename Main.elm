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
    ( { mana =
            { amt = 100
            , max = 100
            , genRate = 0
            , genAmt = 0
            }
      , baseManaRegen = 5
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

        manaAmt =
            mana.amt

        skeletons =
            model.skeletons

        ( newManaAmt, newSkeletons ) =
            if manaAmt >= skeletonCost then
                ( manaAmt - skeletonCost, skeletons + 1 )
            else
                ( manaAmt, skeletons )

        newMana =
            { mana | amt = newManaAmt }
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

        manaAmt =
            mana.amt

        ( newManaAmt, newManaGens ) =
            if manaAmt >= manaGenCost then
                ( manaAmt - manaGenCost, model.manaGenerators + 1 )
            else
                ( manaAmt, model.manaGenerators )

        newMana =
            { mana | amt = newManaAmt }
    in
    { model
        | manaGenerators = newManaGens
        , mana = newMana
    }


tickMana : Model -> Model
tickMana model =
    let
        mana =
            model.mana

        newManaRate =
            model.baseManaRegen
                + (model.manaGeneratorsGenRate * model.manaGenerators)
                + (model.skeletons * model.skelManaBurnRate)

        deltaAmt =
            model.deltaTime * newManaRate

        newManaAmt =
            mana.amt + deltaAmt |> clampDown mana.max

        newMana =
            { mana
                | amt = newManaAmt
                , genRate = newManaRate
            }
    in
    { model | mana = newMana }


clampDown : number -> number -> number
clampDown max num =
    -- Given a max and num, clamp num between 0 and max
    clamp 0 max num


subscriptions : Model -> Sub Msg
subscriptions model =
    --Time.every (0.25 * Time.second) Tick
    AnimationFrame.times Tick
