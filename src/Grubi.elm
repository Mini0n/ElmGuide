module Grubi exposing (main)

import Array exposing (Array)
import Browser
import Html exposing (button, div, h1, h4, img, input, label, pre, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


type alias Thumb =
    { url : String }


type Click
    = SelectThumb String
    | SelectSize ThumbSize
    | SelectRandom


type alias ClickSize =
    { data : ThumbSize, description : String }


type alias Model =
    { thumbs : List Thumb, selected : String, thumbSize : ThumbSize, testValue : String }


type ThumbSize
    = SML
    | MDM
    | LRG


view : Model -> Html.Html Click
view model =
    div [ class "content" ]
        [ h1 [] [ text "g r u b i" ]
        , div []
            [ randomButton
            , div [ class "size_btns" ]
                (List.map sizeButtons [ SML, MDM, LRG ])

            -- (List.map sizeRadios [ SML, MDM, LRG ])
            ]
        , div [ id "thumbnails" ]
            (List.map (viewThumbs model.thumbSize model.selected) model.thumbs)
        , img [ class "selected_thumb", src (urlLarge model.selected) ] []
        ]


initialModel : Model
initialModel =
    { thumbs =
        [ { url = "xWBjMpOr7rMJ00XA3Y" } -- uh, uhh ♫
        , { url = "2t9sbaLKTaDWeSFhqr" } -- turbo jalo
        , { url = "lzoFgUxKNpR67fAu1l" } -- satan cares
        , { url = "ja8lfMYNhCbISSpnDW" } -- baler berga
        , { url = "jnUJCp8JAOC7faEzuY" } -- ringo deathstarr
        , { url = "eWcQik3FYpL2M" } -- bye, bye macadam
        ]
    , selected = "jnUJCp8JAOC7faEzuY"
    , thumbSize = SML
    , testValue = "Pupe"
    }


thumbArray : Array Thumb
thumbArray =
    Array.fromList initialModel.thumbs


main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }



-- update : Click -> Model -> Model


update msg model =
    case msg of
        SelectThumb url ->
            { model | selected = url }

        SelectRandom ->
            { model | selected = "jnUJCp8JAOC7faEzuY" }

        SelectSize size ->
            { model | thumbSize = size }



-- Helper functions


viewThumbs : ThumbSize -> String -> Thumb -> Html.Html Click
viewThumbs size selected thumb =
    img
        [ src (urlThumb thumb.url)
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
    "https://media.giphy.com/media/" ++ gifCode ++ "/200w_d.gif"


urlLarge : String -> String
urlLarge gifCode =
    "https://media.giphy.com/media/" ++ gifCode ++ "/giphy.gif"


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


getThumbURL : Int -> String
getThumbURL index =
    case Array.get index thumbArray of
        Just thumb ->
            thumb.url

        Nothing ->
            ""
