module View exposing (view)

import Common exposing (..)
import EveryDict as ED
import FormatNumber
import FormatNumber.Locales exposing (usLocale)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Stuff exposing (..)


view : Model -> Html Msg
view model =
    div [ style [ ( "margin", "20px" ) ] ]
        [ h1 [] [ text "SKELETON QUEEN" ]
        , buyBtn Crystal model

        --, text " "
        --, buyFlaskBtn model
        --, text " "
        , div [ class "stats" ]
            [ viewStatWithRate Mana model
            , viewStat Crystal model
            , viewStat Skel model

            --    , viewFlasks model
            --    , viewCrystals model
            --    , viewLumber model
            --    , viewGold model
            ]

        --, br [] []
        --, hr [] []
        --, spawnSkelBtn model
        --, div [ class "stats" ]
        --    [ viewSkeletons model
        --    ]
        --, hr [] []
        --, div [ class "stats" ]
        --    [ viewJobs model
        --    ]
        --, div [ class "stats stats-debug" ]
        --    [ viewTime model
        --    , viewDeltaTime model
        --    ]
        ]


viewStatWithRate : Stuff -> Model -> Html Msg
viewStatWithRate stuff { stuffStats, cachedCombinedStuffOutputs } =
    let
        stats =
            stat stuff stuffStats

        outputPerSec =
            amt stuff cachedCombinedStuffOutputs
    in
    div []
        [ text (nameFromStuff stuff)
        , text ": "
        , text (stats.amt |> niceInt)
        , text " / "
        , text (stats.max |> niceInt)
        , text " ("
        , text (outputPerSec |> niceFloat1)
        , text " "
        , text (String.toLower (nameFromStuff stuff))
        , text "/sec)"
        ]


viewStat : Stuff -> Model -> Html Msg
viewStat stuff { stuffStats } =
    let
        stats =
            stat stuff stuffStats
    in
    div []
        [ text (nameFromStuff stuff)
        , text ": "
        , text (stats.amt |> niceInt)
        , text " / "
        , text (stats.max |> niceInt)
        ]


buyBtn : Stuff -> Model -> Html Msg
buyBtn stuff { stuffStats } =
    let
        btnText =
            text ("Buy " ++ nameFromStuff Crystal ++ " (" ++ toString crystalManaCost ++ " mana)")
    in
    if canBuy stuff stuffStats then
        btn [ onClick (Buy stuff) ] [ btnText ]
    else
        btn (class "is-disabled" :: tooltip "Not enough mana(TODO: getCostOfStuff)!") [ btnText ]



{-

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



   sellSkelBtn : Model -> Html Msg
   sellSkelBtn model =
       if canSellSkel model then
           btn [ onClick SellSkeleton ] [ text "Destroy 1 Skeleton" ]
       else
           btn (class "is-disabled" :: tooltip "Need a freeloading skeleton to destroy!") [ text "Destroy 1 Skeleton" ]




   viewJobs : Model -> Html Msg
   viewJobs model =
       div []
           [ h3 [] [ text "Skeleton Jobs" ]
           , div []
               [ text "Freeloaders: "
               , text (model.freeloaderAmt |> niceInt)
               ]
           , viewLumberjacks model
           , viewMiners model
           ]


   viewLumberjacks : Model -> Html Msg
   viewLumberjacks model =
       div []
           [ text "Lumberjacks: "
           , text (model.skel.lumberjackAmt |> niceInt)
           , text " ("
           , text (model.cache.lumberGenPerSec |> niceFloat2)
           , text " lumber/sec) "
           , assignLumberjackBtn model
           , fireLumberjackBtn model
           ]


   assignLumberjackBtn : Model -> Html Msg
   assignLumberjackBtn model =
       if canAssignSkel model then
           btn [ onClick (Assign Lumberjack) ] [ text "Assign Lumberjack" ]
       else
           btn (class "is-disabled" :: tooltip "Need a freeloading skeleton!") [ text "Assign Lumberjack" ]


   fireLumberjackBtn : Model -> Html Msg
   fireLumberjackBtn model =
       if canFireLumberjack model then
           btn [ onClick (Fire Lumberjack) ] [ text "Fire Lumberjack" ]
       else
           btn (class "is-disabled" :: tooltip "No lumberjack skeletons to fire!") [ text "Fire Lumberjack" ]


   viewMiners : Model -> Html Msg
   viewMiners model =
       div []
           [ text "Miners: "
           , text (model.skel.minerAmt |> niceInt)
           , text " ("
           , text (model.cache.goldGenPerSec |> niceFloat2)
           , text " gold/sec) "
           , assignMinerBtn model
           , fireMinerBtn model
           ]


   assignMinerBtn : Model -> Html Msg
   assignMinerBtn model =
       if canAssignSkel model then
           btn [ onClick (Assign Miner) ] [ text "Assign Miner" ]
       else
           btn (class "is-disabled" :: tooltip "Need a freeloading skeleton!") [ text "Assign Miner" ]


   fireMinerBtn : Model -> Html Msg
   fireMinerBtn model =
       if canFireMiner model then
           btn [ onClick (Fire Miner) ] [ text "Fire Miner" ]
       else
           btn (class "is-disabled" :: tooltip "No miner skeletons to fire!") [ text "Fire Miner" ]
-}


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


tooltip : String -> List (Attribute msg)
tooltip text =
    [ attribute "data-balloon" text, attribute "data-balloon-pos" "up" ]


btn : List (Attribute msg) -> List (Html msg) -> Html msg
btn attrs children =
    a
        (List.append [ class "btn" ] attrs)
        children


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
