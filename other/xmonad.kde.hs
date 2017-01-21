--
-- vim:sw=4:
-- Xmonad config
--

--{{{ Imports
import Data.List

import Graphics.X11.ExtraTypes.XF86
import Graphics.X11.Xlib

import System.IO

import XMonad
import XMonad.Config.Kde
import XMonad.Core

import XMonad.Actions.CycleWS

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
{-import XMonad.Hook.FadeInactive-}

import XMonad.Layout
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ResizableTile
import XMonad.Layout.StackTile

{-import XMonad.Prompt-}
{-import XMonad.Prompt.Man-}
{-import XMonad.Prompt.Shell-}

import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Util.Scratchpad

import qualified XMonad.StackSet as W
import qualified Data.Map as M
--}}}
import XMonad
import qualified XMonad.StackSet as W -- to shift and float windows

--{{{ main
main = xmonad kde4Config
    { modMask     = mod4Mask -- use the Windows button as mod
    , manageHook  = manageHook kde4Config <+> myManageHook <+> manageScratchPad
    , startupHook = startup
    , layoutHook  = myLayoutHook
    , keys        = myKeys
    }

myTerminal = "konsole"
-- Need to spawn xcompmgr myself, because if I use KDE startup methods, it can
-- get spawned too late:
startup :: X ()
startup = do
    spawn "xcompmgr -c"
    setWMName "LG3D"

-- Layouts
myLayoutHook =
  {-onWorkspaces ["1:sh", "2:www"] (avoidStruts (Full ||| Tall 1 (3/100) (1/2))) $-}
  avoidStruts (Tall 1 (3/100) (1/2) ||| Mirror (Tall 1 (3/100) (1/2)) ||| Full) ||| noBorders (fullscreenFull Full)

--}}}

--{{{ Hook for managing windows
myManageHook = composeAll . concat $
    [ [ className   =? c --> doFloat           | c <- myFloats]
    , [ title       =? t --> doFloat           | t <- myOtherFloats]
    , [ className   =? c --> doF (W.shift "2") | c <- webApps]
    , [ className   =? c --> doF (W.shift "3") | c <- ircApps]
    , [ className   =? c --> doF (W.shift "8") | c <- kdeApps]
    , [ className   =? c --> doF (W.focusDown) | c <- myAvoidMaster]
    ]
  where myFloats      = ["MPlayer", "Gimp", "plasmashell"]
        myOtherFloats = ["alsamixer"]
        myAvoidMaster = ["plasmashell", "kded5"]
        webApps       = ["Firefox", "Opera"]     -- open on desktop 2
        ircApps       = ["Ksirc"]                -- open on desktop 3
        kdeApps       = ["dolphin"]              -- open on desktop 8

manageScratchPad :: ManageHook
manageScratchPad = scratchpadManageHook (W.RationalRect l t w h)
  where
    l = 0.25    -- distance from left edge
    t = 0.25    -- distance from top edge
    w = 0.6     -- terminal width
    h = 0.5     -- terminal height
--}}}

--{{{ Keybindings
-- Union default and new key bindings
myKeys x  = M.union (M.fromList (newKeys x)) (keys defaultConfig x)
--    Add new and/or redefine key bindings
newKeys conf@(XConfig {XMonad.modMask = modm}) =
  -- Workspace navigation:
  -- =====================
  -- mod-{u,i}, Switch to {prev,next} workspace
  -- mod-shift-{u,i}, Move client and shift to {prev,next} workspace
  -- Requires Xmonad.Actions.CycleWS
  --
  [ ((modm               , xK_u), prevWS)
  , ((modm               , xK_i), nextWS)
  , ((modm .|. shiftMask , xK_u), shiftToPrev >> prevWS)
  , ((modm .|. shiftMask , xK_i), shiftToNext >> nextWS)
  ]
  ++
  -- mod-{e,w,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{e,w,r}, Move client to screen 1, 2, or 3
  [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
           , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
  ++
  -- General keybindings:
  -- ====================
  [
      ((0, xK_Print),                spawn "scrot")
      , ((controlMask, xK_Print),      spawn "sleep 0.2; scrot -s") -- C-Print does screenshot of window
      {-, ((0, xF86XK_AudioMute),        spawn "amixer -q set Speaker toggle")-}
      {-, ((0, xF86XK_AudioRaiseVolume), spawn "amixer -q set Speaker 2+")-}
      {-, ((0, xF86XK_AudioLowerVolume), spawn "amixer -q set Speaker 2-")-}
      , ((modm .|. controlMask, xK_l), spawn "slock" )
      , ((modm .|. controlMask, xK_k), spawn "xset dpms force off" )
      {-, ((0, xF86XK_HomePage),         windows $ W.view "1:sh")-}
      {-, ((0, xF86XK_Search),           spawn "dolphin")-}
      , ((modm, xK_s),                 scratchPad )
      -- Send a 'logout now' command:
      , ((modm .|. shiftMask, xK_q),   spawn "dbus-send --print-reply --dest=org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout int32:0 int32:0 int32:0" )
      {-, ((modm, xK_o), W.greedyView 4)-}
  ]
  where scratchPad = scratchpadSpawnActionTerminal myTerminal

--}}}

