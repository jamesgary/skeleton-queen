module View exposing (view)

import Common exposing (..)
import FormatNumber
import FormatNumber.Locales exposing (usLocale)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


view : Model -> Html Msg
view model =
    div [ style [ ( "margin", "20px" ) ] ]
        [ h1 [] [ text "SKELETON QUEEN" ]
        , btn
            [ onClick BuyCrystal ]
            [ text ("Buy Crystal (" ++ toString crystalManaCost ++ " mana)") ]
        , text " "
        , btn
            [ onClick BuyFlask ]
            [ text ("Buy Flask (" ++ toString flaskManaCost ++ " mana)") ]
        , text " "
        , div [ class "stats" ]
            [ viewMana model
            , viewFlasks model
            , viewCrystals model
            ]
        , br [] []
        , hr [] []
        , btn
            [ onClick SpawnSkeleton ]
            [ text ("Spawn Skeleton (" ++ toString skeletonCost ++ " mana)") ]
        , div [ class "stats" ]
            [ viewSkeletons model
            ]
        , div [ class "stats stats-debug" ]
            [ viewTime model
            , viewDeltaTime model
            ]
        ]


btn : List (Attribute msg) -> List (Html msg) -> Html msg
btn attrs children =
    button
        (List.append [ style [ ( "margin", "10px 0" ) ] ] attrs)
        children


viewFlasks : Model -> Html Msg
viewFlasks model =
    div []
        [ text "Flasks: "
        , text (model.flasks.amt |> niceInt)
        , text " (+"
        , text (model.config.flaskStorage * model.flasks.amt |> niceInt)
        , text " max mana)"
        ]


viewCrystals : Model -> Html Msg
viewCrystals model =
    div []
        [ text "Crystals: "
        , text (model.crystals.amt |> niceInt)
        , text " ("
        , text (model.config.crystalManaPerSec * model.crystals.amt |> niceInt)
        , text " mana/sec)"
        ]


viewMana : Model -> Html Msg
viewMana model =
    div []
        [ text "Mana: "
        , text (model.mana.amt |> niceInt)
        , text " / "
        , text (model.cache.manaMax |> niceInt)
        , text " ("
        , text (model.cache.manaPerSec |> niceFloat2)
        , text " mana/sec)"
        ]


viewSkeletons : Model -> Html Msg
viewSkeletons model =
    div []
        [ text "Skeletons: "
        , text (model.skel.amt |> niceInt)
        , text " ("
        , text (model.cache.skelManaBurnPerSec |> niceFloat2)
        , text " mana/sec) "
        , btn [ onClick SellSkeleton, disabled (not (canSellSkel model)) ] [ text "Destroy 1 Skeleton" ]
        ]


viewTime : Model -> Html Msg
viewTime model =
    div []
        [ text "Time: "
        , text (toString model.time)
        ]


viewDeltaTime : Model -> Html Msg
viewDeltaTime model =
    div []
        [ text "DeltaTime: "
        , text (toString model.deltaTime)
        ]


niceInt : Float -> String
niceInt num =
    FormatNumber.format { decimals = 0, thousandSeparator = ",", decimalSeparator = "" } num


niceFloat1 : Float -> String
niceFloat1 num =
    FormatNumber.format { decimals = 1, thousandSeparator = ",", decimalSeparator = "." } num


niceFloat2 : Float -> String
niceFloat2 num =
    FormatNumber.format { decimals = 2, thousandSeparator = ",", decimalSeparator = "." } num
