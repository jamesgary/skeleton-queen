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
        , button
            [ style [ ( "margin", "10px 0" ) ]
            , onClick SpawnSkeleton
            ]
            [ text ("Spawn Skeleton (" ++ toString skeletonCost ++ " mana)") ]
        , text " "
        , button
            [ style [ ( "margin", "10px 0" ) ]
            , onClick BuyManaGen
            ]
            [ text ("Buy Mana Gen (" ++ toString manaGenCost ++ " mana)") ]
        , div [ class "stats" ]
            [ viewMana model
            , viewSkeletons model
            , viewManaGenerators model
            ]
        , div [ class "stats stats-debug" ]
            [ viewTime model
            , viewDeltaTime model
            ]
        ]


viewMana : Model -> Html Msg
viewMana model =
    div []
        [ text "Mana: "
        , text (model.mana |> niceInt)
        , text " / "
        , text (model.maxMana |> niceInt)
        , text " ("
        , text (totalManaRate model |> niceFloat2)
        , text " mana/sec)"
        ]


viewSkeletons : Model -> Html Msg
viewSkeletons model =
    div []
        [ text "Skeletons: "
        , text (model.skeletons |> niceInt)
        , text " ("
        , text (model.skeletons * model.skelManaBurnRate |> niceFloat2)
        , text " mana/sec)"
        ]


viewManaGenerators : Model -> Html Msg
viewManaGenerators model =
    div []
        [ text "ManaGens: "
        , text (model.manaGenerators |> niceInt)

        --, text " ("
        --, text (model.regenMana - (model.skeletons * model.skelManaBurnRate) |> niceFloat2)
        --, text " mana/sec)"
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
