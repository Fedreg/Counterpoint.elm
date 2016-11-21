module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Regex exposing (..)
import String
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
    , notesToSend : List Note
    }


type alias Note =
    { noteName : String
    , noteDuration : String
    , octave : Float
    }


model =
    { initialNotes = ""
    , notesToSend = []
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
            { model | notesToSend = parseNotes model.initialNotes }


parseNotes : String -> List Note
parseNotes string =
    String.toLower string
        |> find All (regex "([a-g,r]+#|[a-g,r])([whqes])(\\d)")
        |> List.map .match
        |> List.map noteSorter


noteSorter : String -> Note
noteSorter string =
    case (String.length string) of
        3 ->
            Note (String.slice 0 1 string) (String.slice 1 2 string) (Result.withDefault 0 <| String.toFloat <| String.slice 2 3 string)

        4 ->
            Note (String.slice 0 2 string) (String.slice 2 3 string) (Result.withDefault 0 <| String.toFloat <| String.slice 3 4 string)

        _ ->
            Note "x" "x" 0.0


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
    div [ style [ ( "textAlign", "center" ) ] ]
        [ h1 [ style [ ( "textDecoration", "underline" ) ] ] [ text "COUNTERPOINT.ELM" ]
        , input
            [ type_ "text"
            , placeholder "Enter notes to play"
            , value model.initialNotes
            , onInput AcceptNotes
            , style
                [ ( "margin", " 3rem 20px" )
                , ( "width", "80%" )
                , ( "textTransform", "uppercase" )
                ]
            ]
            []
        , button [ onClick PrepareNotes ] [ text "Play Notes" ]
        , div [] [ text "NOTES TO BE PLAYED" ]
        , div [ style [ ( "color", "red" ), ( "fontSize", "0.75 rem" ) ] ] [ text (toString (parseNotes model.initialNotes)) ]
        , div [ style [ ( "margin", "1rem auto" ) ] ] [ instructions ]
        ]


instructions =
    ul [ style [ ( "listStyle", "none" ) ] ]
        [ li [] [ text "Enter notes in the format: CW3 where ..." ]
        , li [] [ text "C is the name of the note to be played (sharps are allowed but no flats yet)" ]
        , li [] [ text "W is the note duration, where W = whole, H = eigth, Q = quarter, E = eigth, & S = sixteenth" ]
        , li [] [ text "3 equals octave to be played (range of 1 - 9)" ]
        ]
