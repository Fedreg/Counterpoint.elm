port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Regex exposing (..)
import String exposing (..)
import List.Extra exposing (getAt)
import Dict exposing (..)


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



--MODEL


type alias Model =
    { initialNotes1 : String
    , initialNotes2 : String
    , initialNotes3 : String
    , initialNotes4 : String
    , voice1 : List Note
    , voice2 : List Note
    , voice3 : List Note
    , voice4 : List Note
    , index : Int
    , bpm : Int
    , waveType : String
    }


type alias Note =
    { hz : Float
    , duration : Float
    , octave : Int
    }


type alias PlayBundle =
    { noteList : List Note
    , tempo : Float
    , waveType : String
    }


model =
    { initialNotes1 = ""
    , initialNotes2 = ""
    , initialNotes3 = ""
    , initialNotes4 = ""
    , voice1 = []
    , voice2 = []
    , voice3 = []
    , voice4 = []
    , index = 0
    , bpm = 80
    , waveType = "square"
    }


init =
    ( model, Cmd.none )



--UPDATE


port send1 : PlayBundle -> Cmd msg


port send2 : PlayBundle -> Cmd msg


port send3 : PlayBundle -> Cmd msg


port send4 : PlayBundle -> Cmd msg


type Msg
    = AcceptNotes1 String
    | AcceptNotes2 String
    | AcceptNotes3 String
    | AcceptNotes4 String
    | SendNotes
    | ChangeBPM String
    | ChangeWaveType String
    | AddVoice


update msg model =
    case msg of
        AcceptNotes1 text ->
            ( { model
                | initialNotes1 = text
                , voice1 = parseNotes model.initialNotes1
              }
            , Cmd.none
            )

        AcceptNotes2 text ->
            ( { model
                | initialNotes2 = text
                , voice2 = parseNotes model.initialNotes2
              }
            , Cmd.none
            )

        AcceptNotes3 text ->
            ( { model
                | initialNotes3 = text
                , voice3 = parseNotes model.initialNotes3
              }
            , Cmd.none
            )

        AcceptNotes4 text ->
            ( { model
                | initialNotes4 = text
                , voice4 = parseNotes model.initialNotes4
              }
            , Cmd.none
            )

        SendNotes ->
            ( model
            , Cmd.batch
                [ send1 (PlayBundle model.voice1 (tempo model.bpm) model.waveType)
                , send2 (PlayBundle model.voice2 (tempo model.bpm) model.waveType)
                , send3 (PlayBundle model.voice3 (tempo model.bpm) model.waveType)
                , send4 (PlayBundle model.voice4 (tempo model.bpm) model.waveType)
                ]
            )

        ChangeBPM text ->
            ( { model | bpm = Result.withDefault 128 (String.toInt text) }, Cmd.none )

        ChangeWaveType text ->
            ( { model | waveType = text }, Cmd.none )

        AddVoice ->
            ( { model | voice2 = parseNotes model.initialNotes1 }, Cmd.none )


subscriptions =
    always Sub.none


parseNotes : String -> List Note
parseNotes string =
    toLower string
        |> find All (regex "([a-g,r]+#|[a-g,r])([whqes])(\\d)")
        |> List.map .match
        |> List.map noteSorter


noteSorter : String -> Note
noteSorter string =
    case (length string) of
        3 ->
            Note (frequencies (slice 0 1 string)) (sustain (slice 1 2 string)) (octave (Result.withDefault 0 (toInt (slice 2 3 string))))

        4 ->
            Note (frequencies (slice 0 2 string)) (sustain (slice 2 3 string)) (octave (Result.withDefault 0 (toInt (slice 3 4 string))))

        _ ->
            Note 0.0 0.0 0


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
            2 ^ (num - 1)


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


tempo : Int -> Float
tempo bpm =
    (Basics.toFloat 60 / Basics.toFloat bpm) * 0.5



-- VIEW


view : Model -> Html Msg
view model =
    div [ style [ ( "textAlign", "center" ) ] ]
        [ h1 [ style [ ( "textDecoration", "underline" ), ( "marginBottom", "2rem" ) ] ] [ text "COUNTERPOINT.ELM" ]
        , noteInputField AcceptNotes1
        , noteInputField AcceptNotes2
        , noteInputField AcceptNotes3
        , noteInputField AcceptNotes4
        , bpmInput
        , waveSelectMenu
        , button [ onClick SendNotes ] [ text "Play Notes" ]
        , div [] [ text "NOTES TO BE PLAYED" ]
        , div [ style [ ( "color", "red" ), ( "fontSize", "0.75rem" ) ] ] [ text (toString model.voice1) ]
        , div [ style [ ( "color", "orange" ), ( "fontSize", "0.75rem" ) ] ] [ text (toString model.voice2) ]
        , div [ style [ ( "color", "purple" ), ( "fontSize", "0.75rem" ) ] ] [ text (toString model.voice3) ]
        , div [ style [ ( "color", "lightblue" ), ( "fontSize", "0.75rem" ) ] ] [ text (toString model.voice4) ]
        , div [ style [ ( "margin", "1rem auto" ) ] ] [ instructions ]
        ]


noteInputField msg =
    input
        [ type_ "text"
        , placeholder "Enter notes to play"
        , onInput msg
        , style
            [ ( "margin", " 0.5rem 20px" )
            , ( "width", "80%" )
            , ( "textTransform", "uppercase" )
            ]
        ]
        []



{--
additionalVoice : Html Msg
additionalVoice =
    label
        [ style [ ( "display", "block" ) ] ]
        [ input
            [ type_ "checkbox"
            , onClick AddVoice
            ]
            []
        , text ("Add Voice #2")
        ]
-}


waveSelectMenu : Html Msg
waveSelectMenu =
    select
        [ onInput ChangeWaveType
        , style
            [ ( "margin", " 1rem 20px" )
            , ( "width", "15%" )
            , ( "textTransform", "uppercase" )
            , ( "display", "inline-block" )
            ]
        ]
        [ option [ value "square" ] [ text "square" ]
        , option [ value "sine" ] [ text "sine" ]
        , option [ value "triangle" ] [ text "triangle" ]
        , option [ value "sawtooth" ] [ text "sawtooth" ]
        ]


bpmInput : Html Msg
bpmInput =
    input
        [ type_ "number"
        , placeholder "BPM"
        , onInput ChangeBPM
        , style
            [ ( "margin", " 1rem 20px" )
            , ( "width", "15%" )
            , ( "textTransform", "uppercase" )
            , ( "display", "inline-block" )
            ]
        ]
        [ text "Beats per minute" ]


instructions : Html Msg
instructions =
    ul [ style [ ( "listStyle", "none" ) ] ]
        [ li [] [ text "Enter notes in the format: CW3 where ..." ]
        , li [] [ text "C is the name of the note to be played (sharps are allowed but no flats yet)" ]
        , li [] [ text "W is the note duration, where W = whole, H = eigth, Q = quarter, E = eigth, & S = sixteenth" ]
        , li [] [ text "3 equals octave to be played (range of 1 - 9)" ]
        ]
