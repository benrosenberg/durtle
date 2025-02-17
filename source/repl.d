module repl;

import std.stdio;
import std.string : strip;
import std.concurrency;

import interpreter;
import draw;
import types;
import constants;

void runRepl(LogLevel loglevel, bool logToFile) {
    // TODO: de-compartmentalize interpreter,
    // or make separate "REPL" function
    // to decouple state from program evaluation
    // so that state can persist over multiple
    // REPL commands, and we can e.g.
    // update the drawing window from the REPL
    // as needed

    // print repl info...
    writeln("Durtle REPL v0.0.1");
    string input = "";
    // preemptively spawn raylib process for rendering output
    immutable PixelArray dummyPixelArray = [Coord(0, 0): 'w'];
    bool interactive = true;
    Tid raylibTid = spawn(&renderPixels, dummyPixelArray, interactive);

    // writeln("Spawned Raylib thread with Tid: ", raylibTid);

    while (true) {
        write("> ");
        input = strip(readln());
        if ((input == "quit") || (input == "exit"))
            break;
        PixelArray pixelArray = runProgram(input, loglevel, logToFile);
        writefln("input=\"%s\"", input);
        // if length of pixel array is 0, 
        // add dummy pixel of same color as bg
        // so that thread doesn't end
        if (pixelArray.length == 0) {
            pixelArray = [Coord(0, 0): 'w'];
        }
        // push updates to pixel array to raylib thread
        // writefln("Sending updated pixel data: %s", pixelArray);
        send(raylibTid, cast(immutable) pixelArray);
    }

    PixelArray terminator;
    send(raylibTid, cast(immutable) terminator);

}
