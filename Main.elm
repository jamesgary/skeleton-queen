module Main exposing (..)

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
      , freeloaderAmt = 0
      , skel =
            { lumberjackAmt = 0
            , minerAmt = 0
            }
      , flasksAmt = 1
      , crystalsAmt = 1
      , lumberAmt = 0
      , goldAmt = 0
      , config =
            { flaskStorage = 100
            , crystalManaPerSec = 1
            , flaskManaStorage = 100
            , lumberjackLumberPerSec = 1
            , minerGoldPerSec = 1
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
            , goldGenPerSec = 0
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

        Assign job ->
            ( assignJob job model, Cmd.none )

        Fire job ->
            ( fireJob job model, Cmd.none )

        Tick time ->
            if model.firstFramePassed then
                ( model
                    |> tickTime time
                    |> updateCache
                    |> tickMana
                    |> tickLumber
                    |> tickGold
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
        { model
            | freeloaderAmt = model.freeloaderAmt + 1
            , manaAmt = model.manaAmt - skelManaCost
        }
    else
        model


sellSkeleton : Model -> Model
sellSkeleton model =
    if canSellSkel model then
        { model | freeloaderAmt = model.freeloaderAmt - 1 }
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


assignJob : Job -> Model -> Model
assignJob job model =
    if canAssignSkel model then
        -- remove one from freeloaders and add to specified job
        let
            newModel =
                { model | freeloaderAmt = model.freeloaderAmt - 1 }
        in
        addAmtToJob newModel job 1
    else
        model


fireJob : Job -> Model -> Model
fireJob job model =
    if canFire job model then
        -- add one to freeloaders and remove from specified job
        let
            newModel =
                { model | freeloaderAmt = model.freeloaderAmt + 1 }
        in
        addAmtToJob newModel job -1
    else
        model


getJobAmt : Model -> Job -> Float
getJobAmt model job =
    case job of
        Lumberjack ->
            model.skel.lumberjackAmt

        Miner ->
            model.skel.minerAmt


addAmtToJob : Model -> Job -> Float -> Model
addAmtToJob model job amt =
    let
        skel =
            model.skel

        newSkel =
            case job of
                Lumberjack ->
                    { skel | lumberjackAmt = skel.lumberjackAmt + amt }

                Miner ->
                    { skel | minerAmt = skel.minerAmt + amt }
    in
    { model | skel = newSkel }


canFire : Job -> Model -> Bool
canFire job model =
    getJobAmt model job > 0


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


tickGold : Model -> Model
tickGold model =
    let
        newGoldAmt =
            model.goldAmt + (model.deltaTime * model.cache.goldGenPerSec)
    in
    { model | goldAmt = newGoldAmt }


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

        goldGenPerSec =
            model.skel.minerAmt * model.config.minerGoldPerSec

        cache =
            { manaPerSec = manaPerSec
            , skelManaBurnPerSec = skelManaBurnPerSec
            , manaMax = manaMax
            , crystalManaGenPerSec = crystalManaGenPerSec
            , lumberGenPerSec = lumberGenPerSec
            , goldGenPerSec = goldGenPerSec
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
