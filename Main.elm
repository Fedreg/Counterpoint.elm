port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Regex exposing (..)
import String exposing (..)
import List.Extra exposing (getAt)
import Time exposing (..)
import Update.Extra.Infix exposing ((:>))


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


--MODEL


type alias Model =
    { initialNotes : String
    , notesToSend : List Note
    , index : Int
    , bpm : Int
    , waveType : String
    , numberOfInputs : Int
    }


type alias Note =
    { hz : Float
    , duration : Float
    , octave : Int
    }


type alias PlayBundle =
    { note : Maybe Note
    , tempo : Float
    , waveType : String
    }


model =
    { initialNotes = ""
    , notesToSend = []
    , index = 0
    , bpm = 80
    , waveType = "square"
    , numberOfInputs = 1
    }


init =
    ( model, Cmd.none )



--UPDATE


port send : PlayBundle -> Cmd msg


type Msg
    = AcceptNotes String
    | Play
    | ResetIndex
    | SendNotes
    | ChangeBPM String
    | ChangeWaveType String


update msg model =
    case msg of
        AcceptNotes text ->
            ( { model
                | initialNotes = text
                , notesToSend = parseNotes model.initialNotes
              }
            , Cmd.none
            )

        Play ->
            (model, Cmd.none)
               :> update ResetIndex
               :> update SendNotes

        ResetIndex ->
            ( { model | index = 0 }, Cmd.none)

        SendNotes ->
            ( { model | index = model.index +1}
            , send (PlayBundle (getAt model.index model.notesToSend) (tempo model.bpm) model.waveType))
            
        ChangeBPM text ->
            ( { model | bpm = Result.withDefault 128 (String.toInt text) }, Cmd.none )

        ChangeWaveType text ->
            ( { model | waveType = text }, Cmd.none )


--subscriptions =
--    always Sub.none
subscriptions : Model -> Sub Msg
subscriptions model =
    if model.index > 0 && model.index < List.length model.notesToSend
      then 
         let 
            sustain =
               Maybe.withDefault 1 ((getAt (model.index - 1) model.notesToSend)
               |> Maybe.map .duration) 

            speed =
               tempo model.bpm 
               
         in
            Time.every ((sustain * speed) * second) (always SendNotes)
        --then Time.every (Maybe.withDefault 1 ((getAt model.index model.notesToSend) |> Maybe.map .duration) * 0.5 * second) (always SendNotes)
        else Sub.none
 
parseNotes : String -> List Note
parseNotes string =
    toLower string
        |> find All (regex "([a-g,r]+#|[a-g,r])([whqes])(\\d)")
        |> List.map .match
        |> List.map noteSorter


noteSorter : String -> Note
noteSorter string =
    case (String.length string) of
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
    div [ style [ ( "textAlign", "center" ), ("color", "#ddd") ] ]
        [ h1 [ style [ ( "textDecoration", "underline" ), ( "marginBottom", "2rem" ) ] ] [ text "COUNTERPOINT.ELM" ]
        , noteInputField "1"
        , noteInputField "2"
        , bpmInput
        , waveSelectMenu
        , button [ onClick Play, style [("backgroundColor", "#ddd"), ("color", "#333"), ("border", "1px solid #333")] ] [ text "Play Notes" ]
        , div [] [ text "NOTES TO BE PLAYED" ]
        , div [ style [ ( "color", "red" ), ( "fontSize", "0.75 rem" ) ] ] [ text (toString model.notesToSend) ]
        , div [ style [ ( "margin", "1rem auto" ) ] ] [ instructions ]
        ]


noteInputField : String -> Html Msg
noteInputField idName =
    input
        [ type_ "text"
        , id idName
        , placeholder "Enter notes to play"
        , onInput AcceptNotes
        , style
            [ ( "margin", " 0.5rem 20px" )
            , ( "width", "80%" )
            , ( "textTransform", "uppercase" )
            , ( "color", "#ddd")
            ]
        ]
        []


waveSelectMenu =
    select
        [ onInput ChangeWaveType
        , style
            [ ( "margin", " 1rem 20px" )
            , ( "width", "15%" )
            , ( "textTransform", "uppercase" )
            , ( "display", "inline-block" )
            , ("color", "#ddd")
            ]
        ]
        [ option [ value "square" ] [ text "square" ]
        , option [ value "sine" ] [ text "sine" ]
        , option [ value "triangle" ] [ text "triangle" ]
        , option [ value "sawtooth" ] [ text "sawtooth" ]
        ]


bpmInput =
    input
        [ type_ "number"
        , placeholder "BPM"
        , onInput ChangeBPM
        , value (toString model.bpm)
        , style
            [ ( "margin", " 1rem 20px" )
            , ( "width", "15%" )
            , ( "textTransform", "uppercase" )
            , ( "display", "inline-block" )
            , ( "color", "#ddd")
            ]
        ]
        [ text "Beats per minute" ]


instructions =
    ul [ style [ ( "listStyle", "none" ), ("color", "#ddd")] ]
        [ li [] [ text "Enter notes in the format: CW3 where ..." ]
        , li [] [ text "C is the name of the note to be played (sharps are allowed but no flats yet)" ]
        , li [] [ text "W is the note duration, where W = whole, H = eigth, Q = quarter, E = eigth, & S = sixteenth" ]
        , li [] [ text "3 equals octave to be played (range of 1 - 9)" ]
        ]
