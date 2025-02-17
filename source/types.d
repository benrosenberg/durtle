module types;

struct Coord {
    int x, y;

    // Required to use as a key in an associative array
    bool opEquals(const Coord other) const {
        return x == other.x && y == other.y;
    }

    size_t toHash() const {
        return typeid(int).getHash(&x) ^ typeid(int).getHash(&y);
    }
}

struct FuncEnv {
    int var;
    char color;
}

alias PixelArray = char[Coord];
