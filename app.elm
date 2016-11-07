module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (..)
import Array exposing (..)
import Regex exposing (..)


main =
    App.beginnerProgram
        { model = model
        , update = update
        , view = view
        }



--MODEL


type alias Model =
    { initialNotes : String
    , notesToBeParsed : String
    }


model =
    { initialNotes = ""
    , notesToBeParsed = ""
    }



--UPDATE


type Msg
    = AcceptNotes String
    | PrepareNotes


update msg model =
    case msg of
        AcceptNotes text ->
            { model | initialNotes = text }

        PrepareNotes ->
            { model | notesToBeParsed = model.initialNotes }


parseNotes string =
    find All (regex "([a-g,r]+#|[a-g,r])([whqos])(\\d)") string
        |> List.map .match


sustain duration =
    case duration of
        "w" ->
            4.0

        "h" ->
            2.0

        "q" ->
            1.0

        "e" ->
            0.5

        "s" ->
            0.25

        _ ->
            0.0


octave num =
    case num of
        1 ->
            1

        _ ->
            2 * (num - 1)


frequencies =
    { c =
        130.81
        --    , c# = 139.00
    , d =
        146.83
        --   , d# = 156.00
    , e = 164.81
    , f =
        174.61
        --  , f# = 185.00
    , g =
        196.0
        --   , g# = 208.00
    , a =
        220.0
        --  , a# = 233.00
    , b = 246.94
    , r = 0.0
    }



{--
finalArr item =
    if List.length item == 3 then

        List.map (first ++ third  ++ fourth ++ ) item

    else
        List.map (firstTwo  ++ third  ++ fourth ++ ) item


first a =
    List.map (String.left 1) a


firstTwo a =
    List.map (String.left 2) a


third a =
    List.map (String.slice 2 3) a


fourth a =
    List.map (String.right 1) a



        List.map (String.toList >> List.map String.fromChar)
frequencies =
    { c = 130.81
    , c# = 139.00
    , d = 146.83
    , d# = 156.00
    , e = 164.81
    , f = 174.61
    , f# = 185.00
    , g = 196.00
    , g# = 208.00
    , a = 220.00
    , a# = 233.00
    , b = 246.94
    , r = 0.0
 }
-}
-- VIEW


view model =
    div []
        [ input
            [ type' "text"
            , placeholder "Enter notes to play"
            , value model.initialNotes
            , onInput AcceptNotes
            ]
            []
        , button [ onClick PrepareNotes ] [ text "Play Notes" ]
        , div [] [ text (toString (parseNotes model.notesToBeParsed)) ]
          --, div [] [ text (toString (finalArr parseNotes)) ]
        ]
