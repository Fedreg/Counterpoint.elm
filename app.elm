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


parseNotes string =
    find All (regex "([a-g,r]+#|[a-g,r])([whqos])(\\d)") string
        |> List.map .match


finalArr =
    List.map (String.toList >> List.map String.fromChar)



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
