module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex exposing (..)
import List.Extra exposing (getAt)


main =
    beginnerProgram
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


parseNotes : String -> List (List String)
parseNotes string =
    find All (regex "([a-g,r]+#|[a-g,r])([whqes])(\\d)") string
        |> List.map .match
        |> if List.map String.length == 4 then
            List.map (String.toList >> List.map String.fromChar >> getAt 1 ++ getAt 2)
           else
            List.map (String.toList >> List.map String.fromChar)



--sharpAdder : List ( List String) -> List ( List String)
--sharpAdder notes =


sustain : String -> Float
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


octave : Int -> Int
octave num =
    case num of
        1 ->
            1

        _ ->
            2 * (num - 1)


frequencies : String -> Float
frequencies note =
    case note of
        "c" ->
            130.81

        "c#" ->
            139.0

        "d" ->
            146.83

        "d#" ->
            156.0

        "e" ->
            164.81

        "f" ->
            174.61

        "f#" ->
            185.0

        "g" ->
            196.0

        "g#" ->
            208.0

        "a" ->
            220.0

        "a#" ->
            233.0

        "b" ->
            246.94

        "r" ->
            0.0

        _ ->
            0.0



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ input
            [ type_ "text"
            , placeholder "Enter notes to play"
            , value model.initialNotes
            , onInput AcceptNotes
            ]
            []
        , button [ onClick PrepareNotes ] [ text "Play Notes" ]
        , div [] [ text (toString (parseNotes model.notesToBeParsed)) ]
          --, div [] [ text (toString (finalArr parseNotes)) ]
        ]
