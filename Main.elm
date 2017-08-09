module Main exposing (main)

import AnimationFrame
import Common exposing (..)
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
    ( { manaAmt = 50
      , skel =
            { lumberjackAmt = 0
            , freeloaderAmt = 0
            }
      , flasksAmt = 1
      , crystalsAmt = 1
      , lumberAmt = 0
      , config =
            { flaskStorage = 100
            , crystalManaPerSec = 1
            , flaskManaStorage = 100
            , lumberjackLumberPerSec = 1
            }
      , time = 0
      , deltaTime = 0
      , firstFramePassed = False
      , cache =
            { manaPerSec = 0
            , skelManaBurnPerSec = 0
            , manaMax = 100
            , crystalManaGenPerSec = 0
            , lumberGenPerSec = 0
            }
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SpawnSkeleton ->
            ( spawnSkeleton model, Cmd.none )

        BuyCrystal ->
            ( buyCrystal model, Cmd.none )

        BuyFlask ->
            ( buyFlask model, Cmd.none )

        SellSkeleton ->
            ( sellSkeleton model, Cmd.none )

        AssignLumberjack ->
            ( assignLumberjack model, Cmd.none )

        FireLumberjack ->
            ( fireLumberjack model, Cmd.none )

        Tick time ->
            if model.firstFramePassed then
                ( model
                    |> tickTime time
                    |> updateCache
                    |> tickMana
                    |> tickLumber
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
    if canSpawnSkel model then
        let
            skel =
                model.skel

            newManaAmt =
                model.manaAmt - skelManaCost

            newFreeloaderAmt =
                skel.freeloaderAmt + 1

            newSkel =
                { skel | freeloaderAmt = newFreeloaderAmt }
        in
        { model
            | skel = newSkel
            , manaAmt = newManaAmt
        }
    else
        model


sellSkeleton : Model -> Model
sellSkeleton model =
    if canSellSkel model then
        let
            skel =
                model.skel

            newFreeloaderAmt =
                skel.freeloaderAmt - 1

            newSkel =
                { skel | freeloaderAmt = newFreeloaderAmt }
        in
        { model | skel = newSkel }
    else
        model


buyCrystal : Model -> Model
buyCrystal model =
    if canBuyCrystal model then
        let
            newManaAmt =
                model.manaAmt - crystalManaCost

            newCrystalsAmt =
                model.crystalsAmt + 1
        in
        { model
            | crystalsAmt = newCrystalsAmt
            , manaAmt = newManaAmt
        }
    else
        model


buyFlask : Model -> Model
buyFlask model =
    if canBuyFlask model then
        let
            newManaAmt =
                model.manaAmt - flaskManaCost

            newFlasksAmt =
                model.flasksAmt + 1
        in
        { model
            | flasksAmt = newFlasksAmt
            , manaAmt = newManaAmt
        }
    else
        model


assignLumberjack : Model -> Model
assignLumberjack model =
    if canAssignLumberjack model then
        let
            skel =
                model.skel

            freeloaderAmt =
                model.skel.freeloaderAmt

            lumberjackAmt =
                model.skel.lumberjackAmt

            newSkel =
                { skel | freeloaderAmt = freeloaderAmt - 1, lumberjackAmt = lumberjackAmt + 1 }
        in
        { model | skel = newSkel }
    else
        model


fireLumberjack : Model -> Model
fireLumberjack model =
    if canFireLumberjack model then
        let
            skel =
                model.skel

            freeloaderAmt =
                model.skel.freeloaderAmt

            lumberjackAmt =
                model.skel.lumberjackAmt

            newSkel =
                { skel | freeloaderAmt = freeloaderAmt + 1, lumberjackAmt = lumberjackAmt - 1 }
        in
        { model | skel = newSkel }
    else
        model


tickMana : Model -> Model
tickMana model =
    let
        newManaAmt =
            clampDown model.cache.manaMax (model.manaAmt + (model.deltaTime * model.cache.manaPerSec))
    in
    { model | manaAmt = newManaAmt }


tickLumber : Model -> Model
tickLumber model =
    let
        newLumberAmt =
            model.lumberAmt + (model.deltaTime * model.cache.lumberGenPerSec)
    in
    { model | lumberAmt = newLumberAmt }


updateCache : Model -> Model
updateCache model =
    let
        skelManaBurnPerSec =
            skelAmt model * -0.8

        crystalManaGenPerSec =
            model.crystalsAmt * model.config.crystalManaPerSec

        manaPerSec =
            skelManaBurnPerSec + crystalManaGenPerSec

        manaMax =
            model.flasksAmt * model.config.flaskManaStorage

        lumberGenPerSec =
            model.skel.lumberjackAmt * model.config.lumberjackLumberPerSec

        cache =
            { manaPerSec = manaPerSec
            , skelManaBurnPerSec = skelManaBurnPerSec
            , manaMax = manaMax
            , crystalManaGenPerSec = crystalManaGenPerSec
            , lumberGenPerSec = lumberGenPerSec
            }
    in
    { model | cache = cache }


clampDown : number -> number -> number
clampDown max num =
    -- Given a max and num, clamp num between 0 and max
    clamp 0 max num


subscriptions : Model -> Sub Msg
subscriptions model =
    --Time.every (0.25 * Time.second) Tick
    AnimationFrame.times Tick
