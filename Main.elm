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
    ( { mana =
            { amt = 50
            }
      , skel =
            { amt = 0
            }
      , flasks =
            { amt = 1
            }
      , crystals =
            { amt = 1
            }
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
        mana =
            model.mana

        manaAmt =
            mana.amt

        skel =
            model.skel

        skelAmt =
            skel.amt

        ( newManaAmt, newSkelAmt ) =
            if manaAmt >= skeletonCost then
                ( manaAmt - skeletonCost, skelAmt + 1 )
            else
                ( manaAmt, skelAmt )

        newMana =
            { mana | amt = newManaAmt }

        newSkel =
            { skel | amt = newSkelAmt }
    in
    { model
        | skel = newSkel
        , mana = newMana
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
        mana =
            model.mana

        manaAmt =
            mana.amt

        crystals =
            model.crystals

        crystalAmt =
            crystals.amt

        ( newManaAmt, newCrystalAmt ) =
            if manaAmt >= crystalManaCost then
                ( manaAmt - crystalManaCost, crystalAmt + 1 )
            else
                ( manaAmt, crystalAmt )

        newCrystals =
            { crystals | amt = newCrystalAmt }

        newMana =
            { mana | amt = newManaAmt }
    in
    { model
        | crystals = newCrystals
        , mana = newMana
    }


buyFlask : Model -> Model
buyFlask model =
    let
        mana =
            model.mana

        manaAmt =
            mana.amt

        flasks =
            model.flasks

        flaskAmt =
            flasks.amt

        ( newManaAmt, newFlaskAmt ) =
            if manaAmt >= flaskManaCost then
                ( manaAmt - flaskManaCost, flaskAmt + 1 )
            else
                ( manaAmt, flaskAmt )

        newFlasks =
            { flasks | amt = newFlaskAmt }

        newMana =
            { mana | amt = newManaAmt }
    in
    { model
        | flasks = newFlasks
        , mana = newMana
    }


tickMana : Model -> Model
tickMana model =
    let
        mana =
            model.mana

        newMana =
            { mana
                | amt = clampDown model.cache.manaMax (mana.amt + (model.deltaTime * model.cache.manaPerSec))
            }
    in
    { model | mana = newMana }


updateCache : Model -> Model
updateCache model =
    let
        skelManaBurnPerSec =
            model.skel.amt * -0.8

        crystalManaGenPerSec =
            model.crystals.amt * model.config.crystalManaPerSec

        manaPerSec =
            skelManaBurnPerSec + crystalManaGenPerSec

        manaMax =
            model.flasks.amt * model.config.flaskManaStorage

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
