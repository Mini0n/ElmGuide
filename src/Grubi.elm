module Grubi exposing (main)

import Array exposing (Array)
import Browser
import Html exposing (div, h1, h4, img, pre, text)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Thumb =
    { url : String }


type alias Click =
    { data : String, description : String }


type alias Model =
    { thumbs : List Thumb, selected : String }


view : Model -> Html.Html Click
view model =
    div [ class "content" ]
        [ h1 [] [ text "g r u b i" ]
        , div [ id "thumbnails" ] (List.map (viewThumbs model.selected) model.thumbs)
        , img [ class "large", src (urlLarge model.selected) ] []
        ]


initialModel : Model
initialModel =
    { thumbs =
        [ { url = "xWBjMpOr7rMJ00XA3Y" } -- uh, uhh ♫
        , { url = "2t9sbaLKTaDWeSFhqr" } -- turbo jalo
        , { url = "lzoFgUxKNpR67fAu1l" } -- satan cares
        ]
    , selected = "2t9sbaLKTaDWeSFhqr"
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


update msg model =
    if msg.description == "ClickedThumb" then
        { model | selected = msg.data }

    else
        model



-- Helper functions


viewThumbs : String -> Thumb -> Html.Html Click
viewThumbs selected thumb =
    img
        [ src (urlThumb thumb.url)
        , classList [ ( "selected", selected == thumb.url ), ( "thumb", True ) ]
        , onClick { description = "ClickedThumb", data = thumb.url }
        ]
        []


urlThumb : String -> String
urlThumb gifCode =
    "https://media.giphy.com/media/" ++ gifCode ++ "/200w_d.gif"


urlLarge : String -> String
urlLarge gifCode =
    "https://media.giphy.com/media/" ++ gifCode ++ "/giphy.gif"
