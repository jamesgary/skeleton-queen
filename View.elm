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
        , buyCrystalBtn model
        , text " "
        , buyFlaskBtn model
        , text " "
        , div [ class "stats" ]
            [ viewMana model
            , viewFlasks model
            , viewCrystals model
            , viewLumber model
            ]
        , br [] []
        , hr [] []
        , spawnSkelBtn model
        , div [ class "stats" ]
            [ viewSkeletons model
            ]
        , hr [] []
        , div [ class "stats" ]
            [ viewJobs model
            ]
        , div [ class "stats stats-debug" ]
            [ viewTime model
            , viewDeltaTime model
            ]
        ]


buyCrystalBtn : Model -> Html Msg
buyCrystalBtn model =
    let
        btnText =
            text ("Buy Crystal (" ++ toString crystalManaCost ++ " mana)")
    in
    if canBuyCrystal model then
        btn [ onClick BuyCrystal ] [ btnText ]
    else
        btn (class "is-disabled" :: tooltip "Not enough mana!") [ btnText ]


buyFlaskBtn : Model -> Html Msg
buyFlaskBtn model =
    let
        btnText =
            text ("Buy Flask (" ++ toString flaskManaCost ++ " mana)")
    in
    if canBuyFlask model then
        btn [ onClick BuyFlask ] [ btnText ]
    else
        btn (class "is-disabled" :: tooltip "Not enough mana!") [ btnText ]


spawnSkelBtn : Model -> Html Msg
spawnSkelBtn model =
    let
        btnText =
            text ("Spawn Skeleton (" ++ toString skelManaCost ++ " mana)")
    in
    if canSpawnSkel model then
        btn [ onClick SpawnSkeleton ] [ btnText ]
    else
        btn (class "is-disabled" :: tooltip "Not enough mana!") [ btnText ]


btn : List (Attribute msg) -> List (Html msg) -> Html msg
btn attrs children =
    a
        (List.append [ class "btn" ] attrs)
        children


viewFlasks : Model -> Html Msg
viewFlasks model =
    div []
        [ text "Flasks: "
        , text (model.flasksAmt |> niceInt)
        , text " (+"
        , text (model.config.flaskStorage * model.flasksAmt |> niceInt)
        , text " max mana)"
        ]


viewCrystals : Model -> Html Msg
viewCrystals model =
    div []
        [ text "Crystals: "
        , text (model.crystalsAmt |> niceInt)
        , text " ("
        , text (model.config.crystalManaPerSec * model.crystalsAmt |> niceInt)
        , text " mana/sec)"
        ]


viewLumber : Model -> Html Msg
viewLumber model =
    div []
        [ text "Lumber: "
        , text (model.lumberAmt |> niceInt)
        , text " ("
        , text (model.cache.lumberGenPerSec |> niceInt)
        , text " lumber/sec)"
        ]


viewMana : Model -> Html Msg
viewMana model =
    div []
        [ text "Mana: "
        , text (model.manaAmt |> niceInt)
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
        , text (skelAmt model |> niceInt)
        , text " ("
        , text (model.cache.skelManaBurnPerSec |> niceFloat2)
        , text " mana/sec) "
        , sellSkelBtn model
        ]


sellSkelBtn : Model -> Html Msg
sellSkelBtn model =
    if canSellSkel model then
        btn [ onClick SellSkeleton ] [ text "Destroy 1 Skeleton" ]
    else
        btn (class "is-disabled" :: tooltip "Need a freeloading skeleton to destroy!") [ text "Destroy 1 Skeleton" ]


tooltip : String -> List (Attribute msg)
tooltip text =
    [ attribute "data-balloon" text, attribute "data-balloon-pos" "up" ]


actionBtn : Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
actionBtn isEnabled attrs children =
    let
        newAttrs =
            if isEnabled then
                class "btn" :: attrs
            else
                [ class "btn is-disabled" ]
    in
    a newAttrs children


viewJobs : Model -> Html Msg
viewJobs model =
    div []
        [ h3 [] [ text "Skeleton Jobs" ]
        , div []
            [ text "Freeloaders: "
            , text (model.skel.freeloaderAmt |> niceInt)
            ]
        , div []
            [ text "Lumberjacks: "
            , text (model.skel.lumberjackAmt |> niceInt)
            , text " ("
            , text (model.cache.lumberGenPerSec |> niceFloat2)
            , text " lumber/sec) "
            , assignLumberjackBtn model
            , fireLumberjackBtn model
            ]
        ]


assignLumberjackBtn : Model -> Html Msg
assignLumberjackBtn model =
    if canAssignLumberjack model then
        btn [ onClick AssignLumberjack ] [ text "Assign Lumberjack" ]
    else
        btn (class "is-disabled" :: tooltip "Need a freeloading skeleton!") [ text "Assign Lumberjack" ]


fireLumberjackBtn : Model -> Html Msg
fireLumberjackBtn model =
    if canFireLumberjack model then
        btn [ onClick FireLumberjack ] [ text "Fire Lumberjack" ]
    else
        btn (class "is-disabled" :: tooltip "No lumberjack skeletons to fire!") [ text "Fire Lumberjack" ]


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
