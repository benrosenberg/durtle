module draw;

import std.stdio;
import std.concurrency;
import core.time;

import raylib;
import types;
import constants;

void drawPixels(PixelArray pixelColorMap, Coord offset, int scalingFactor) {
    // offset is the coord of the center (want to draw from center)
    foreach (coord, color; pixelColorMap) {
        int x = coord.x * scalingFactor + offset.x;
        int y = coord.y * scalingFactor + offset.y;
        DrawRectangle(x, y, scalingFactor, scalingFactor, colorMap[color]);
    }
}

void renderPixels(immutable PixelArray pixelColorMap, bool interactive) {
    // writeln("Raylib thread started with Tid: ", thisTid);

    const int screenWidth = 1000;
    const int screenHeight = 1000;
    SetTraceLogLevel(LOG_ERROR); // Only show errors
    InitWindow(screenWidth, screenHeight, "durtle");
    SetTargetFPS(60);

    Coord offset = Coord(screenWidth / 2, screenHeight / 2);
    Coord offsetInitial = Coord(offset.x, offset.y);

    PixelArray mutablePixelColorMap = cast(PixelArray) pixelColorMap;

    int scalingFactor = 2;
    int scalingFactorInitial = scalingFactor;

    while (!WindowShouldClose()) {
        if (interactive) {
            // wait for another pixel array - block until one is received,
            // so that we can update the values
            PixelArray newPixelArray;
            bool gotMessage = receiveTimeout(dur!"msecs"(10), (immutable PixelArray p) {
                newPixelArray = cast(PixelArray) p;
                // writeln("Received updated pixel data!");
            });
            if (gotMessage) {
                if (newPixelArray.length == 0) {
                    break;
                } else {
                    mutablePixelColorMap = newPixelArray.dup;
                }
                // writeln("Updated pixel data in Raylib thread!");
            }
        }

        if (IsKeyPressed(KEY_UP) && scalingFactor < 20) {
            // Prevent scalingFactor from going above 20
            scalingFactor++;
        }
        if (IsKeyPressed(KEY_DOWN) && scalingFactor > 1) {
            // Prevent scalingFactor from going below 1
            scalingFactor--;
        }
        if (IsKeyPressed(KEY_W)) {
            offset.y += 800 / scalingFactor;
        }
        if (IsKeyPressed(KEY_S)) {
            offset.y -= 800 / scalingFactor;
        }
        if (IsKeyPressed(KEY_A)) {
            offset.x += 800 / scalingFactor;
        }
        if (IsKeyPressed(KEY_D)) {
            offset.x -= 800 / scalingFactor;
        }
        if (IsKeyPressed(KEY_SPACE)) {
            offset.x = offsetInitial.x;
            offset.y = offsetInitial.y;
            scalingFactor = scalingFactorInitial;
        }

        BeginDrawing();
        ClearBackground(colorMap[BACKGROUND_COLOR]);

        drawPixels(mutablePixelColorMap, offset, scalingFactor);

        EndDrawing();
    }

    CloseWindow();
}
