-- Xmonad-config --

import XMonad hiding ( (|||) )
import XMonad.Hooks.EwmhDesktops
import System.Exit

import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)

import XMonad.Util.EZConfig(additionalKeys)

import qualified XMonad.StackSet as W

import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import XMonad.Layout.Named
import XMonad.Layout.LayoutCombinators

import XMonad.Hooks.ScreenCorners
import XMonad.Actions.CycleWS

----------------------------------------------------

main = do
    xmproc <- spawnPipe "~/.config/polybar/launch.sh"
    xmonad $ docks $ ewmh  $ def 

        { layoutHook = myLayout
        , startupHook = myStartupHook
        , handleEventHook = myEventHook <+> fullscreenEventHook 

        , modMask = mod4Mask
        , borderWidth   = 2
        , focusedBorderColor = "#FFA500"
        , workspaces = ["1","2","3","4"]

        } `additionalKeys`
        [ ((mod4Mask, xK_Return), spawn    "alacritty")
        , ((mod4Mask, xK_r),      spawn    "alacritty -e ranger")
        , ((mod4Mask, xK_b),      spawn    "brave")
        , ((mod4Mask, xK_space),  spawn    "rofi -show drun -theme ~/.config/rofi/launcher.rasi")
        , ((mod4Mask, xK_period), windows W.focusDown)
        , ((mod4Mask, xK_comma),  windows W.focusUp)
        , ((mod4Mask, xK_p),      sendMessage NextLayout)
        , ((mod4Mask, xK_m),      sendMessage $ JumpToLayout "Mono") 
        , ((mod4Mask, xK_f),      sendMessage $ JumpToLayout "Full") 
        , ((mod4Mask, xK_t),      sendMessage $ JumpToLayout "Hor") 
        , ((mod4Mask, xK_q),      kill)
        , ((mod4Mask .|. mod1Mask, xK_r),   spawn    "xmonad --recompile; xmonad --restart")
        , ((mod4Mask .|. mod1Mask, xK_q),   io (exitWith ExitSuccess))
        ]

------------------------------------------------------------------------
-- Layouts:

myLayout = screenCornerLayoutHook
         $ smartBorders 
         $ avoidStruts (mySpacing (named "Hor" (tiled) 
                               ||| named "Ver" (Mirror tiled) 
                               ||| named "Mono" (Full))) 
                               ||| named "Full" (Full)
 
    where

        -- Spacing
        mySpacing = spacingRaw False (Border 1 1 1 1) True (Border 1 1 1 1) True

        -- default tiling algorithm partitions the screen into two panes
        tiled   = Tall nmaster delta ratio

        -- The default number of windows in the master pane
        nmaster = 1

        -- Default proportion of screen occupied by master pane
        ratio   = 11/20

        -- Percent of screen to increment by when resizing panes
        delta   = 3/100

------------------------------------------------------------------------
---- Startup:

myStartupHook = do
    addScreenCorners [ (SCLowerRight, nextWS)
                     , (SCLowerLeft, prevWS)
                     , (SCUpperLeft, spawn "skippy-xd")
                     ]

------------------------------------------------------------------------
------ Event:

myEventHook e = do
    screenCornerEventHook e
