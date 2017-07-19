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
        , viewMana model
        , viewSkeletons model
        ]


viewMana : Model -> Html Msg
viewMana model =
    div []
        [ text "Mana: "
        , text (toString model.mana)
        , text " / "
        , text (toString model.maxMana)
        ]


viewSkeletons : Model -> Html Msg
viewSkeletons model =
    div []
        [ text "Skeletons: "
        , text (toString model.skeletons)
        ]
