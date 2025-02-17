module interpreter;

import std.stdio;
import std.conv : to;
import std.string : format;
import std.algorithm.searching : startsWith;
import std.math : pow;
import std.datetime.systime : Clock;
import std.logger : FileLogger;

import pegged.grammar;
import parser;
import cli;
import types;
import constants;

PixelArray runProgram(string program, LogLevel loglevel, bool logToFile) {
    auto parseTree = parseProgram(program);
    return runParseTree(parseTree, loglevel, logToFile);
}

PixelArray runParseTree(ParseTree parseTree, LogLevel loglevel, bool logToFile) {
    FileLogger flogger;
    if (logToFile) {
        flogger = new FileLogger(format("logs\\log_%s.txt", Clock.currTime().toISOString()));
    }

    void logToOut(string msg) {
        if (logToFile) {
            flogger.log(msg);
        } else {
            writeln(msg);
        }
    }

    if (loglevel <= LogLevel.LOGGING_PARSETREE) {
        logToOut("Parse tree output:");
        logToOut(to!string(parseTree));
    }

    void log(string msg) {
        if (loglevel < LogLevel.LOGGING_PARSETREE) {
            if (loglevel < LogLevel.LOGGING_NO_MOVEMENT) {
                // no movement instructions logged
                if (!msg.startsWith("moving pen"))
                    logToOut(msg);
            } else {
                logToOut(msg);
            }
        }
    }

    int var = INITIAL_VAR_VALUE;
    char color = INITIAL_PEN_COLOR;
    bool penDown = INITIAL_PEN_DOWN_STATE;
    auto currentLocation = Coord(
        INITIAL_COORD_LOCATION.x,
        INITIAL_COORD_LOCATION.y
    );
    PixelArray pixelColors;
    bool breakLines = BREAK_LINES_DEFAULT;
    int heading = 0; // multiple of pi/2
    // keep track of functions in an associative array
    // functions are given numeric identifiers by the user
    // and stored as the "FuncTerms" part of the
    // FuncDef parse tree
    ParseTree[int] functions;

    int delegate(ParseTree) runTurtle;

    void moveTurtle(int heading, string direction, ParseTree p) {
        string[] direction_order = [
            "right", "up", "left", "down"
        ];
        int directionIndex = 0;
        foreach (idx; 0 .. 4) {
            if (direction_order[idx] == direction) {
                directionIndex = idx;
                break;
            }
        }
        int newDirectionIndex = ((directionIndex + heading) % 4 + 4) % 4;
        string trueDirection = direction_order[newDirectionIndex];
        log(format("move: heading=%d, direction=%s => true direction=%s", heading, direction, trueDirection));
        switch (trueDirection) {
        case "right":
            int nextX = currentLocation.x + runTurtle(p.children[0]);
            if (penDown) {
                log(format("moving pen to X=%d (drawing with color=%s)", nextX, colorNames[color]));
                foreach (x; currentLocation.x .. nextX + 1) {
                    if (color == BACKGROUND_COLOR) {
                        pixelColors.remove(Coord(x, currentLocation.y));
                    } else {
                        pixelColors[Coord(x, currentLocation.y)] = color;
                    }
                }
            } else {
                log(format("moving pen to X=%d (not drawing)", nextX));
            }
            currentLocation.x = nextX;
            return;
        case "left":
            int nextX = currentLocation.x - runTurtle(p.children[0]);
            if (penDown) {
                log(format("moving pen to X=%d (drawing with color=%s)", nextX, colorNames[color]));
                foreach (x; nextX .. currentLocation.x + 1) {
                    if (color == BACKGROUND_COLOR) {
                        pixelColors.remove(Coord(x, currentLocation.y));
                    } else {
                        pixelColors[Coord(x, currentLocation.y)] = color;
                    }
                }
            } else {
                log(format("moving pen to X=%d (not drawing)", nextX));
            }
            currentLocation.x = nextX;
            return;
        case "up":
            int nextY = currentLocation.y - runTurtle(p.children[0]);
            if (penDown) {
                log(format("moving pen to Y=%d (drawing with color=%s)", nextY, colorNames[color]));
                foreach (y; nextY .. currentLocation.y + 1) {
                    if (color == BACKGROUND_COLOR) {
                        pixelColors.remove(Coord(currentLocation.x, y));
                    } else {
                        pixelColors[Coord(currentLocation.x, y)] = color;
                    }
                }
            } else {
                log(format("moving pen to Y=%d (not drawing)", nextY));
            }
            currentLocation.y = nextY;
            return;
        case "down":
            int nextY = currentLocation.y + runTurtle(p.children[0]);
            if (penDown) {
                log(format("moving pen to Y=%d (drawing with color=%s)", nextY, colorNames[color]));
                foreach (y; currentLocation.y .. nextY + 1) {
                    if (color == BACKGROUND_COLOR) {
                        pixelColors.remove(Coord(currentLocation.x, y));
                    } else {
                        pixelColors[Coord(currentLocation.x, y)] = color;
                    }
                }
            } else {
                log(format("moving pen to Y=%d (not drawing)", nextY));
            }
            currentLocation.y = nextY;
            return;
        default:
            return;
        }
    }

    runTurtle = (ParseTree p) {
        switch (p.name) {
            // TODO: all function logic.
            // requires a concept of "env" - 
            // function environment, current values
            // of variables.
            // needs to be stored on a stack.
            // (basically just going to be a stack
            // of struct FuncEnv { int var; char color; }
            // that we add to when we call a function
            // with those params, and only modify the topmost
            // one at any given time.)
        case "Turtle.AngleChange": // set the heading to pi/2 * amt
            int value = runTurtle(p.children[0]) % 4;
            log(format("setting heading to %d * pi/2 + %d", value, heading));
            heading = (value + heading) % 4;
            return 0;
        case "Turtle.MathExp":
            return runTurtle(p.children[0]);
        case "Turtle.FuncDef": // function definition - 
            // store parse tree for func terms
            // in "functions" assoc. array,
            // using the int value from the 
            // number part of the func def
            int funcID = to!int(p.children[1].matches[0]);
            functions[funcID] = p.children[0];
            log(format("stored parsetree for function %d", funcID));
            return 0;
        case "Turtle.FuncCall", "Turtle.FFuncCall": // call function using "functions"
            // associative array, where function
            // should have been stored as "FuncTerms"
            // parse tree. if not found, log and possibly
            // throw runtime error.
            // returns an int value depending on the last term
            // (for this reason, the list of valid "func term"
            // types includes Exp)
            // note: this is where we need to pop and restore
            // the stack, before and after running the function
            // parse tree.
            int funcID = to!int(p.children[2].matches[0]);
            if (!(funcID in functions)) {
                log(format("unable to find function %d in environment, skipping function call", funcID));
                return 0;
            }
            auto func = functions[funcID];
            // store current var and color to stack
            // in our case, we can actually just use 
            // the function call stack that comes with
            // the language that the interpreter is using,
            // so no need to emulate the stack
            auto env = FuncEnv(var, color);
            if (p.children[0].matches[0] == "#") {
                // passed current color
                log(format("function call: passed current color, %s", to!string(color)));
            } else {
                color = to!char(p.children[0].matches[0]);
                log(format("function call: set color to passed color, %s", to!string(color)));
            }
            var = runTurtle(p.children[1]);
            log(format("function call: set var to %d", var));
            log(format("function call: calling function of type %s", func.name));
            int returnValue = runTurtle(func);
            log(format("function call: returning %d", returnValue));
            color = env.color;
            var = env.var;
            return returnValue;
        case "Turtle.If", "Turtle.FuncIf":
            auto condition_value = runTurtle(p.children[0]);
            if (condition_value == var) {
                log(format("condition value %d = var, running set of instructions", condition_value));
                return runTurtle(p.children[1]);
            } else {
                log(format("condition value %d != var, not running set of instructions", condition_value));
            }
            return 0;
        case "Turtle.IfElse", "Turtle.FuncIfElse":
            auto condition_value = runTurtle(p.children[0]);
            if (condition_value == var) {
                log(format("condition value %d = var, running first set of instructions", condition_value));
                return runTurtle(p.children[1]);
            } else {
                log(format("condition value %d != var, running second set of instructions", condition_value));
                auto returnValue = runTurtle(p.children[2]);
                log(format("returning else value %d from if-else", returnValue));
                return returnValue;
            }
        case "Turtle.ColorIf", "Turtle.FColorIf":
            auto condition_value = to!char(p.children[0].matches[0]);
            if (condition_value == color) {
                log(format("condition value %d = color, running set of instructions", condition_value));
                return runTurtle(p.children[1]);
            } else {
                log(format("condition value %d != color, not running set of instructions", condition_value));
            }
            return 0;
        case "Turtle.ColorIfElse", "Turtle.FColorIfElse":
            auto condition_value = to!char(p.children[0].matches[0]);
            if (condition_value == color) {
                log(format("condition value %d = color, running first set of instructions", condition_value));
                return runTurtle(p.children[1]);
            } else {
                log(format("condition value %d != color, running second set of instructions", condition_value));
                auto returnValue = runTurtle(p.children[2]);
                log(format("returning else value %d from color-if-else", returnValue));
                return returnValue;
            }
        case "Turtle.Conditional", "Turtle.FuncCond":
            log(format("running cond: %s", p.name));
            return runTurtle(p.children[0]);
        case "Turtle.ColorCond", "Turtle.FColorCond":
            log(format("running color cond: %s", p.name));
            return runTurtle(p.children[0]);
        case "Turtle.PrintCmd":
            string cmd = p.matches[0];
            if (cmd == "??") {
                log("writing help message");
                writeHelpMessage();
            } else if (cmd == "?_") {
                log(format("printing value of var (%d) as an int", var));
                if (breakLines) {
                    writeln(format("%d", var));
                } else {
                    write(format("%d", var));
                }
            } else if (cmd == "?!") {
                log(format("writing current color name (%s)", colorNames[color]));
                if (breakLines) {
                    writeln(colorNames[color]);
                } else {
                    write(colorNames[color]);
                }
            } else if (cmd == "?:") {
                log(format("printing value of var (%d) as a char", var));
                if (breakLines) {
                    writeln(to!char(var));
                } else {
                    write(to!char(var));
                }
            } else if (cmd == "?;") {
                log(format("switching line break flag from %s to %s", breakLines, !breakLines));
                breakLines = !breakLines;
            } else if (cmd == "?|") {
                log(format("printing current heading (%d)", heading));
                if (breakLines) {
                    writeln(heading);
                } else {
                    write(heading);
                }
            }
            return 0;
        case "Turtle.PenDown":
            penDown = true;
            if (color == BACKGROUND_COLOR) {
                pixelColors.remove(Coord(currentLocation.x, currentLocation.y));
            } else {
                pixelColors[Coord(currentLocation.x, currentLocation.y)] = color;
            }
            log(format("pen down (set current pixel to color=%s)", colorNames[color]));
            return 0;
        case "Turtle.PenUp":
            penDown = false;
            log("pen up");
            return 0;
        case "Turtle.Add":
            return var + runTurtle(p.children[0]);
        case "Turtle.Sub":
            return var - runTurtle(p.children[0]);
        case "Turtle.Mul":
            return var * runTurtle(p.children[0]);
        case "Turtle.Div":
            return var / runTurtle(p.children[0]);
        case "Turtle.Pow":
            return pow(var, runTurtle(p.children[0]));
        case "Turtle.RPow":
            return pow(runTurtle(p.children[0]), var);
        case "Turtle.Mod":
            return var % runTurtle(p.children[0]);
        case "Turtle.Set":
            var = runTurtle(p.children[0]);
            log(format("set var (now %d)", var));
            return 0;
        case "Turtle.Get":
            if (currentLocation in pixelColors) {
                color = pixelColors[currentLocation];
            } else {
                // default bg if not specified
                color = BACKGROUND_COLOR;
            }
            return 0;
        case "Turtle.Exp", "Turtle.FuncExp":
            return runTurtle(p.children[0]);
        case "Turtle.Number":
            return to!int(p.matches[0]);
        case "Turtle.Var":
            return var;
        case "Turtle", "Turtle.Instruction", "Turtle.FuncTerm":
            return runTurtle(p.children[0]);
        case "Turtle.Terms", "Turtle.FuncTerms":
            int returnValue;
            foreach (child; p.children) {
                if (child.name != "Turtle.Comment")
                    returnValue = runTurtle(child);
            }
            return returnValue;
        case "Turtle.Loop", "Turtle.FuncLoop": // determine type of loop - while or repeat?
            if (p.children[1].name == "Turtle.ColorExp") {
                if (p.children[1].matches[0] == "#") {
                    // same as current color by definition - just exit early (no-op)
                    return 0;
                }
                char loopColor = to!char(p.children[1].matches[0]);

                // while loop - run until curr color matches passed one
                log(format("looping until color=%s seen", colorNames[loopColor]));
                int loopCount = 0;
                while (color != loopColor && loopCount < MAX_LOOP_COUNT) {
                    runTurtle(p.children[0]);
                    loopCount++;
                }
                if (loopCount == MAX_LOOP_COUNT) {
                    log(format("loop count hit max=%d, loop terminated", MAX_LOOP_COUNT));
                } else {
                    log(format("saw color=%s, loop finished", colorNames[loopColor]));
                }
            } else {
                int numRuns = runTurtle(p.children[1]);
                log(format("looping %d times", numRuns));
                for (int i = 0; i < numRuns; i++) {
                    runTurtle(p.children[0]);
                }
                log(format("looped %d times, loop finished", numRuns));
            }

            return 0;
        case "Turtle.Right":
            moveTurtle(heading, "right", p);
            return 0;
        case "Turtle.Left":
            moveTurtle(heading, "left", p);
            return 0;
        case "Turtle.Up":
            moveTurtle(heading, "up", p);
            return 0;
        case "Turtle.Down":
            moveTurtle(heading, "down", p);
            return 0;
        case "Turtle.Color":
            char colorSelection = to!char(p.matches[0]);
            if (!(colorSelection in colorNames)) {
                log(format("skipping unknown color \"%s\"", to!string(colorSelection)));
            } else {
                log(format("setting color to %s", colorNames[colorSelection]));
                color = colorSelection;
            }
            return 0;
        default:
            return 0;
        }
    };

    runTurtle(parseTree);

    return pixelColors;
}
