module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (..)
import Debug exposing (log)
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


parseNotes notesToBeParsed =
    find All (regex "([a-g,r]+#|[a-g,r])([whqos])(\\d)/g") notesToBeParsed


finalArr =
    map parseNotes makeArrInArr


makeArrInArr parseNotes =
    if length parseNotes == 3 then
        let
            arr =
                []
        in
            (slice 2 3 parseNotes)
                :: arr
                    (slice 1 2 parseNotes)
                :: arr
                    (slice 0 1 parseNotes)
                :: arr
    else if length parseNotes == 4 then
        let
            arr =
                []
        in
            (slice 3 4 parseNotes)
                :: arr
                    (slice 2 3 parseNotes)
                :: arr
                    (slice 0 2 parseNotes)
                :: arr
    else
        let
            arr =
                []
        in
            "4"
                :: arr
                    "s"
                :: arr
                    "r"
                :: arr



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
        ]
