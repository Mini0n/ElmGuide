module Grubi exposing (main)

-- import Array exposing (Array)
-- import Html.Attributes exposing (..)

import Browser
import Html exposing (button, div, h1, h4, img, input, label, pre, text)
import Html.Attributes exposing (class, classList, id, name, src, title, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Random


type Click
    = SelectThumb String
    | SelectSize ThumbSize
    | GetRandomThumb Thumb
    | GetThumbs (Result Http.Error (List Thumb))
    | SelectRandom



-- | GetSelectIndex Int
-- | GetSelectThumb Thumb
-- | GetThumbs (Result Http.Error String)


type ThumbSize
    = SML
    | MDM
    | LRG


type Status
    = Loading
    | Loaded (List Thumb) String
    | Errored String


type alias ClickSize =
    { data : ThumbSize, description : String }


type alias Thumb =
    { url : String
    , size : Int
    , title : String
    }



-- type alias Model =
--     { thumbs : List Thumb, selected : String, thumbSize : ThumbSize, testValue : String }
-- model definition for online loading


type alias Model =
    { status : Status
    , thumbSize : ThumbSize
    }


view : Model -> Html.Html Click
view model =
    div [ class "content" ]
        [ h1 [] [ text "g r u b i" ]
        , div []
            [ randomButton
            , div [ class "size_btns" ]
                (List.map sizeButtons [ SML, MDM, LRG ])
            ]
        , div [ id "thumbnails" ] <|
            case model.status of
                Loaded thumbs selectedURL ->
                    List.map (viewThumbs model.thumbSize selectedURL) thumbs

                Loading ->
                    []

                Errored errorMsg ->
                    [ text ("Error: " ++ errorMsg) ]
        , case model.status of
            Loaded thumbs selectedURL ->
                img [ class "selected_thumb", src (urlLarge selectedURL) ] []

            Loading ->
                img [] []

            Errored errorMsg ->
                img [] [ text ("Error: " ++ errorMsg) ]
        ]


viewLoaded : List Thumb -> String -> ThumbSize -> List (Html.Html Click)
viewLoaded thumbs selectedURL chosenSize =
    [ h1 [] [ text "g r u b i" ]
    , div []
        [ randomButton
        , div [ class "size_btns" ]
            (List.map sizeButtons [ SML, MDM, LRG ])
        ]
    , div [ id "thumbnails" ]
        (List.map (viewThumbs chosenSize selectedURL) thumbs)
    ]


initialModel : Model
initialModel =
    { status = Loading
    , thumbSize = SML
    }


main : Program () Model Click
main =
    Browser.element
        { init = \flags -> ( initialModel, initialCmd )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


update : Click -> Model -> ( Model, Cmd Click )
update msg model =
    case msg of
        SelectThumb url ->
            ( { model | status = selectUrl url model.status }, Cmd.none )

        SelectRandom ->
            case model.status of
                Loaded (firstThumb :: otherThumbs) _ ->
                    ( model, Random.generate GetRandomThumb (Random.uniform firstThumb otherThumbs) )

                Loaded [] _ ->
                    ( model, Cmd.none )

                Loading ->
                    ( model, Cmd.none )

                Errored errorMsg ->
                    ( model, Cmd.none )

        SelectSize size ->
            ( { model | thumbSize = size }, Cmd.none )

        GetRandomThumb thumb ->
            ( { model | status = selectUrl thumb.url model.status }, Cmd.none )

        GetThumbs (Ok thumbs) ->
            case thumbs of
                first :: rest ->
                    ( { model | status = Loaded thumbs first.url }, Cmd.none )

                [] ->
                    ( { model | status = Errored "No photos found." }, Cmd.none )

        GetThumbs (Err _) ->
            ( { model | status = Errored "Server error!" }, Cmd.none )


selectUrl : String -> Status -> Status
selectUrl url status =
    case status of
        Loaded photos _ ->
            Loaded photos url

        Loading ->
            status

        Errored errorMsg ->
            status



-- Helper functions


thumbDecoder : Decoder Thumb
thumbDecoder =
    -- succeed buildThumb
    succeed Thumb
        |> required "url" string
        |> required "size" int
        |> optional "title" string "(untitled)"



-- buildThumb : String -> Int -> String -> Thumb
-- buildThumb url size title =
--     { url = url, size = size, title = title }


initialCmd : Cmd Click
initialCmd =
    list thumbDecoder
        |> Http.get "http://elm-in-action.com/photos/list.json"
        |> Http.send GetThumbs



-- "http://elm-in-action.com/photos/list"
-- |> Http.getString
-- |> Http.send GetThumbs


viewThumbs : ThumbSize -> String -> Thumb -> Html.Html Click
viewThumbs size selected thumb =
    img
        [ src (urlThumb thumb.url)
        , title (thumb.title ++ "[" ++ String.fromInt thumb.size ++ "]")
        , classList
            [ ( "selected", selected == thumb.url )
            , ( "thumb", True )
            , ( sizeToString size, True )
            ]
        , onClick (SelectThumb thumb.url)
        ]
        []


urlThumb : String -> String
urlThumb gifCode =
    -- "https://media.giphy.com/media/" ++ gifCode ++ "/200w_d.gif"
    "http://elm-in-action.com/" ++ gifCode


urlLarge : String -> String
urlLarge gifCode =
    -- "https://media.giphy.com/media/" ++ gifCode ++ "/giphy.gif"
    "http://elm-in-action.com/" ++ gifCode


randomButton : Html.Html Click
randomButton =
    button [ onClick SelectRandom ]
        [ text "rand0m" ]


sizeButtons : ThumbSize -> Html.Html Click
sizeButtons size =
    button [ onClick (SelectSize size) ]
        [ text (sizeToString size) ]


sizeRadios : ThumbSize -> Html.Html Click
sizeRadios size =
    label []
        [ input [ type_ "radio", name "size" ] []
        , text (sizeToString size)
        ]


sizeToString : ThumbSize -> String
sizeToString size =
    case size of
        SML ->
            "small"

        MDM ->
            "medium"

        _ ->
            "large"



-- getThumbURL : Int -> String
-- getThumbURL index =
--     case Array.get index thumbArray of
--         Just thumb ->
--             thumb.url
--         Nothing ->
--             ""
-- randomPhotoPicker : Random.Generator Int
-- randomPhotoPicker =
--     Random.int 0 (Array.length thumbArray - 1)
