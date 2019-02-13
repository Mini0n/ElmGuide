module Grubi exposing (main)

import Html exposing (div, h1, h4, img, pre, text)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



-- original static view
-- view model =
--     div [ class "content" ]
--         [ h1 [] [ text "Grubi" ]
--         , div [ id "thumbs" ]
--             [ img [ src "https://media.giphy.com/media/xWBjMpOr7rMJ00XA3Y/200w_d.gif" ] []
--             , img [ src "https://media.giphy.com/media/2t9sbaLKTaDWeSFhqr/200w_d.gif" ] []
--             , img [ src "https://media.giphy.com/media/lzoFgUxKNpR67fAu1l/200w_d.gif" ] []
--             ]
--         ]


view model =
    div [ class "content" ]
        [ h1 [] [ text "g r u b i" ]
        , div [ id "thumbnails" ] (List.map (viewThumbs model.selected) model.thumbs)
        , img [ class "large", src (urlLarge model.selected) ] []
        ]


initialModel =
    { thumbs =
        [ { url = "xWBjMpOr7rMJ00XA3Y" } -- uh, uhh ♫
        , { url = "2t9sbaLKTaDWeSFhqr" } -- turbo jalo
        , { url = "lzoFgUxKNpR67fAu1l" } -- satan cares
        ]
    , selected = "2t9sbaLKTaDWeSFhqr"
    }


main =
    view initialModel



-- Helper functions


viewThumbs selected thumb =
    img
        [ src (urlThumb thumb.url)
        , classList [ ( "selected", selected == thumb.url ), ( "thumb", True ) ]
        ]
        []


urlThumb gifCode =
    "https://media.giphy.com/media/" ++ gifCode ++ "/200w_d.gif"


urlLarge gifCode =
    "https://media.giphy.com/media/" ++ gifCode ++ "/giphy.gif"
