module constants;

import types : Coord;
import raylib : Color;

const enum LogLevel {
    LOGGING_ALL = 0,
    LOGGING_NO_MOVEMENT = 1,
    LOGGING_PARSETREE = 2,
    LOGGING_REPL = 2,
    LOGGING_DISABLED = 3
}

const char BACKGROUND_COLOR = 'w';
const char INITIAL_PEN_COLOR = 'w';

const bool INITIAL_PEN_DOWN_STATE = false;

const Coord INITIAL_COORD_LOCATION = Coord(0, 0);

const int INITIAL_VAR_VALUE = 0;

const bool BREAK_LINES_DEFAULT = false;

const bool LOGGING_ENABLED = true;

const int MAX_LOOP_COUNT = 100;

const string[char] colorNames = [
    'a': "azure", 'b': "black", 'c': "cyan",
    'd': "denim", 'e': "eggplant", 'f': "fawn",
    'g': "green", 'h': "heliotrope", 'i': "indigo",
    'j': "jade", 'k': "kiwi", 'l': "lichen",
    'm': "magenta", 'n': "navy", 'o': "orange",
    'p': "pink", 'q': "turquoise", 'r': "red",
    's': "silver", 't': "teal", 'u': "umber",
    'w': "white", 'x': "bordeaux",
    'y': "yellow", 'z': "maize"
];

// raylib interactions with keys
const int KEY_DOWN = 264;
const int KEY_UP = 265;
const int KEY_W = 87;
const int KEY_A = 65;
const int KEY_S = 83;
const int KEY_D = 68;
const int KEY_SPACE = 32;

// map from char colors to RGB for use with raylib
// taken from https://xkcd.com/color/rgb/
const Color[char] colorMap = [
    'a': Color(6, 154, 243), 'b': Color(0, 0, 0),
    'c': Color(0, 255, 255), 'd': Color(59, 99, 140),
    'e': Color(56, 8, 53), 'f': Color(207, 175, 123),
    'g': Color(21, 176, 26), 'h': Color(217, 79, 245),
    'i': Color(56, 2, 130), 'j': Color(31, 167, 116),
    'k': Color(156, 239, 67), 'l': Color(143, 182, 123),
    'm': Color(194, 0, 120), 'n': Color(1, 21, 62),
    'o': Color(249, 115, 6), 'p': Color(255, 129, 192),
    'q': Color(6, 194, 172), 'r': Color(229, 0, 0),
    's': Color(197, 201, 199), 't': Color(2, 147, 135),
    'u': Color(178, 101, 0), 'w': Color(255, 255, 255),
    'x': Color(123, 0, 43), 'y': Color(255, 255, 20),
    'z': Color(244, 209, 84)
];

// raylib log level
const int LOG_ERROR = 5;
