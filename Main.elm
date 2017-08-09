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
            { amt = 0
            , lumberjackAmt = 0
            , freeloaderAmt = 0
            }
      , flasksAmt = 1
      , crystalsAmt = 1
      , config =
            { flaskStorage = 100
            , crystalManaPerSec = 1
            , flaskManaStorage = 100
            }
      , time = 0
      , deltaTime = 0
      , firstFramePassed = False
      , cache =
            { manaPerSec = 0
            , skelManaBurnPerSec = 0
            , manaMax = 100
            , crystalManaGenPerSec = 0 --?
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

        Tick time ->
            if model.firstFramePassed then
                ( model
                    |> tickTime time
                    |> updateCache
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
        manaAmt =
            model.manaAmt

        skel =
            model.skel

        skelAmt =
            skel.amt

        ( newManaAmt, newSkelAmt, newFreeloaderAmt ) =
            if manaAmt >= skeletonCost then
                ( manaAmt - skeletonCost, skelAmt + 1, skel.freeloaderAmt + 1 )
            else
                ( manaAmt, skelAmt, skel.freeloaderAmt )

        newSkel =
            { skel | amt = newSkelAmt, freeloaderAmt = newFreeloaderAmt }
    in
    { model
        | skel = newSkel
        , manaAmt = newManaAmt
    }


sellSkeleton : Model -> Model
sellSkeleton model =
    if model.skel.amt > 0 then
        let
            skel =
                model.skel

            newSkel =
                { skel | amt = skel.amt - 1 }
        in
        { model | skel = newSkel }
    else
        model


buyCrystal : Model -> Model
buyCrystal model =
    let
        manaAmt =
            model.manaAmt

        crystalsAmt =
            model.crystalsAmt

        ( newManaAmt, newCrystalsAmt ) =
            if manaAmt >= crystalManaCost then
                ( manaAmt - crystalManaCost, crystalsAmt + 1 )
            else
                ( manaAmt, crystalsAmt )
    in
    { model
        | crystalsAmt = newCrystalsAmt
        , manaAmt = newManaAmt
    }


buyFlask : Model -> Model
buyFlask model =
    let
        manaAmt =
            model.manaAmt

        flasksAmt =
            model.flasksAmt

        ( newManaAmt, newFlasksAmt ) =
            if manaAmt >= flaskManaCost then
                ( manaAmt - flaskManaCost, flasksAmt + 1 )
            else
                ( manaAmt, flasksAmt )
    in
    { model
        | flasksAmt = newFlasksAmt
        , manaAmt = newManaAmt
    }


assignLumberjack : Model -> Model
assignLumberjack model =
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


tickMana : Model -> Model
tickMana model =
    let
        newManaAmt =
            clampDown model.cache.manaMax (model.manaAmt + (model.deltaTime * model.cache.manaPerSec))
    in
    { model | manaAmt = newManaAmt }


updateCache : Model -> Model
updateCache model =
    let
        skelManaBurnPerSec =
            model.skel.amt * -0.8

        crystalManaGenPerSec =
            model.crystalsAmt * model.config.crystalManaPerSec

        manaPerSec =
            skelManaBurnPerSec + crystalManaGenPerSec

        manaMax =
            model.flasksAmt * model.config.flaskManaStorage

        cache =
            { manaPerSec = manaPerSec
            , skelManaBurnPerSec = skelManaBurnPerSec
            , manaMax = manaMax
            , crystalManaGenPerSec = crystalManaGenPerSec
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
