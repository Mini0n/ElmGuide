module Grubi exposing (main)

-- import Array exposing (Array)

import Browser
import Html exposing (button, div, h1, h4, img, input, label, pre, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Random


type Click
    = SelectThumb String
    | SelectSize ThumbSize
      -- | GetSelectIndex Int
      -- | GetSelectThumb Thumb
    | GetRandomThumb Thumb
    | SelectRandom
    | GetThumbs (Result Http.Error String)


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
    { url : String }



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

            -- (List.map sizeRadios [ SML, MDM, LRG ])
            ]
        , div [ id "thumbnails" ] <|
            case model.status of
                Loaded thumbs selectedURL ->
                    List.map (viewThumbs model.thumbSize selectedURL) thumbs

                Loading ->
                    []

                Errored errorMsg ->
                    [ text ("Error: " ++ errorMsg) ]

        -- (List.map (viewThumbs model.thumbSize model.selected) model.thumbs)
        , case model.status of
            Loaded thumbs selectedURL ->
                img [ class "selected_thumb", src (urlLarge selectedURL) ] []

            Loading ->
                img [] []

            Errored errorMsg ->
                img [] [ text ("Error: " ++ errorMsg) ]

        -- img [ class "selected_thumb", src (urlLarge model.selected) ] []
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



-- initialModel : Model
-- initialModel =
--     { thumbs =
--         [ { url = "xWBjMpOr7rMJ00XA3Y" } -- uh, uhh ♫
--         , { url = "2t9sbaLKTaDWeSFhqr" } -- turbo jalo
--         , { url = "lzoFgUxKNpR67fAu1l" } -- satan cares
--         , { url = "ja8lfMYNhCbISSpnDW" } -- baler berga
--         , { url = "jnUJCp8JAOC7faEzuY" } -- ringo deathstarr
--         , { url = "eWcQik3FYpL2M" } -- bye, bye macadam
--         ]
--     , selected = "jnUJCp8JAOC7faEzuY"
--     , thumbSize = SML
--     , testValue = "Pupe"
--     }
-- initialModel for online loading


initialModel : Model
initialModel =
    { status = Loading
    , thumbSize = SML
    }



-- thumbArray : Array Thumb
-- thumbArray =
--     Array.fromList initialModel.thumbs


main : Program () Model Click
main =
    Browser.element
        { init = \flags -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }


update : Click -> Model -> ( Model, Cmd Click )
update msg model =
    case msg of
        SelectThumb url ->
            -- ( { model | selected = url }, Cmd.none )
            ( { model | status = selectUrl url model.status }, Cmd.none )

        SelectRandom ->
            -- ( model, Random.generate GetSelectIndex randomPhotoPicker )
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

        -- GetSelectIndex index ->
        -- ( { model | selected = getThumbURL index }, Cmd.none )
        -- GetSelectThumb thumb ->
        GetRandomThumb thumb ->
            ( { model | status = selectUrl thumb.url model.status }, Cmd.none )

        GetThumbs result ->
            case result of
                Ok responseStr ->
                    case String.split "," responseStr of
                        (firstURL :: _) as urls ->
                            let
                                thumbs =
                                    List.map (\url -> { url = url }) urls
                            in
                            ( { model | status = Loaded thumbs firstURL }, Cmd.none )

                        [] ->
                            ( { model | status = Errored "No photos found." }, Cmd.none )

                Err httpError ->
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
