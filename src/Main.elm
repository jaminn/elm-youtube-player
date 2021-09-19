port module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Browser.Events exposing (onAnimationFrameDelta)
import Css exposing (..)
import Css.Transitions as Transition exposing (transition)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (attribute, class, css, id, src, type_)
import Html.Styled.Events exposing (on, onClick, onMouseEnter, onMouseLeave)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy, lazy2)
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Task
import Time


port sendToPlayer : E.Value -> Cmd msg


port fromPlayer : (E.Value -> msg) -> Sub msg



-- MAIN


main =
    Browser.element
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { textX : Float
    , playState : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model 1.5 playerStateVal.unstarted
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp
    | LogoClicked
    | Tick Float
    | BannerClicked
    | PlayerStateChanged Int


getBannerX : Bool -> Float -> Float -> Float
getBannerX isPlaying x dt =
    if isPlaying then
        if x > 100 then
            -100

        else
            x + 0.05 * dt

    else
        x * 0.96 + 1.5 * 0.04


playerStateVal =
    { unstarted = -1
    , ended = 0
    , playing = 1
    , paused = 2
    , buffering = 3
    , videoCued = 5
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LogoClicked ->
            ( model, Cmd.none )

        Tick t ->
            ( { model
                | textX =
                    getBannerX
                        (model.playState == playerStateVal.playing || model.playState == playerStateVal.buffering)
                        model.textX
                        t
              }
            , Cmd.none
            )

        BannerClicked ->
            ( model
            , if model.playState == playerStateVal.playing || model.playState == playerStateVal.buffering then
                sendToPlayer (E.object [ ( "msg", E.string "pauseVideo" ) ])

              else
                sendToPlayer (E.object [ ( "msg", E.string "playVideo" ) ])
            )

        PlayerStateChanged state ->
            ( { model | playState = state }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onAnimationFrameDelta Tick
        , fromPlayer
            (\o ->
                case D.decodeValue (D.field "msg" D.string) o of
                    Ok "onPlayerStateChange" ->
                        case D.decodeValue (D.field "data" D.int) o of
                            Ok val ->
                                PlayerStateChanged val

                            Err _ ->
                                NoOp

                    _ ->
                        NoOp
            )
        ]



-- VIEW


bottomBtnStyle : Style
bottomBtnStyle =
    Css.batch
        [ fontSize (px 30)
        , color (hex "#47f")
        , paddingLeft (px 30)
        , paddingRight (px 30)
        , displayFlex
        , alignItems center
        , hover [ textShadow4 (px 1) (px 1) (px 10) (hex "#00000044") ]
        , transition [ Transition.textShadow 200, Transition.color 200 ]
        , active [ color (hex "#69f") ]
        ]


bannerView bannerStr xVal =
    div
        [ onClick BannerClicked
        , css
            [ position relative
            , height (px 50)
            , paddingLeft (px 10)
            , backgroundColor (hex "#555")
            , overflow hidden
            ]
        ]
        [ div
            [ css
                [ position absolute
                , minWidth (pct 100)
                , fontSize (px 18)
                , color (hex "#fff")
                , top (px 15)
                , whiteSpace noWrap
                , transforms [ translateX (pct xVal) ]
                ]
            ]
            [ text bannerStr ]
        ]


view : Model -> Html Msg
view model =
    div [ css [ position absolute, top zero, bottom zero, right zero, left zero, displayFlex, flexDirection column ] ]
        [ div [ css [ width (pct 100), flexShrink zero, minHeight (px 60), displayFlex, justifyContent spaceBetween, alignItems stretch, boxShadow4 (px 1) (px 1) (px 10) (hex "#00000022") ] ]
            [ div [ onClick LogoClicked, css [ width (px 240), position relative, hover [ textShadow4 (px 1) (px 1) (px 10) (hex "#00000044") ], transition [ Transition.textShadow 200 ] ] ]
                [ i [ class "fas fa-flag", css [ fontSize (px 40), color (hex "#444"), position absolute, top (px 8), left (px 18) ] ] []
                , div [ css [ fontSize (px 22), fontWeight bold, color (hex "#333"), position absolute, top (px 15), left (px 68) ] ]
                    [ text "유튜브 플레이어" ]
                ]
            , div [] []
            ]
        , div
            [ css
                [ flexGrow (num 1)
                , overflow auto
                , paddingTop (px 30)
                , paddingBottom (px 30)
                , paddingLeft (px 10)
                , paddingRight (px 10)
                , property "user-select" "text"
                ]
            ]
            [ node "youtube-player" [ css [] ] []

            --iframe
            --    [ attribute "frameborder" "0"
            --    , id "player"
            --    , src "http://www.youtube.com/embed/M7lc1UVf-VE?enablejsapi=1"
            --    , type_ "text/html"
            --    , css [ width (pct 100), height (px 400) ]
            --    ]
            --    []
            , bannerView
                (if model.playState == playerStateVal.playing || model.playState == playerStateVal.buffering then
                    "동영상이 실행 중입니다."

                 else
                    "동영상이 멈췄습니다."
                )
                model.textX
            , div [ css [ height (px 1000) ] ] []
            ]
        , div [ css [ width (pct 100), flexShrink zero, minHeight (px 60), displayFlex, justifyContent spaceAround, boxShadow4 (px 1) (px 1) (px 10) (hex "#00000022") ] ]
            [ div [ css [ bottomBtnStyle ] ]
                [ i [ class "fas fa-home" ] [] ]
            , div [ css [ bottomBtnStyle ] ]
                [ i [ class "fas fa-cube" ] [] ]
            , div [ css [ bottomBtnStyle ] ]
                [ i [ class "fas fa-user" ] [] ]
            ]
        ]
