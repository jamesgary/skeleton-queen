module View exposing (view)

import Common exposing (..)
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
            [ text "Spawn Skeleton" ]
        , div [ class "stats" ]
            [ viewMana model
            , viewSkeletons model
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
        , text (model.mana |> floor |> toString)
        , text " / "
        , text (model.maxMana |> toString)
        , text " ("
        , text (model.regenMana |> toString)
        , text " mana/sec)"
        ]


viewSkeletons : Model -> Html Msg
viewSkeletons model =
    div []
        [ text "Skeletons: "
        , text (toString model.skeletons)
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
