/+dub.sdl:
dependency "pegged" version="~>0.4"
+/

import std.stdio;

import draw;
import interpreter;
import repl;
import constants;
import parser;

void runTests() {
    string program = q"DELIM
    `hilbert curve`
    ?;
    (~0;_;
    ` determine parity based on color `
    `turtle.left(parity * 90)`
    ` in this case parity = 1 if color is a, otherwise parity = -1 `
    ~a;|1;|3\
    ` recursive call with parity=-parity `
    ` if color is a, then call this with r, o/w call with a `
    ~a;{r-1}1;{a-1}1\
    ` move forward `
    ^*2
    ` turtle.right(parity * 90) `
    ` same as before - condition based on color `
    ~a;|3;|1\
    ` recursive call with parity=parity `
    {#-1}1
    ` forward again `
    ^*2
    ` another recursive call with parity=parity `
    {#-1}1
    ` another right turn based on parity `
    ~a;|3;|1\
    ` forward again `
    ^*2
    ` another recursive call with inverted parity `
    ~a;{r-1}1;{a-1}1\
    ` turn left again `
    ~a;|1;|3\
    \)1 . {a10}1
DELIM";
    // sierpinski triangle (with comments)
    //     string program = q"DELIMITER
    //     ` test comment 1...`
    //     <100v100(\25;`test comment 1.5!!!`
    //     [>1^1]_[>1v1]_<*2;{#/2}1,>_.{#/2}1, `test comment 2!!!`
    //     </2^/2.{#/2}1,</2v/2.\)1.{g200}1 `test comment 3..!!>!>!>!`
    // DELIMITER";
    //     writeln(program);
    // string program = `:10:+/2`;
    // sets to 128, because 2^7 = 128
    // string program = `:+2:******2`;
    // testing nested math expressions due to grammar changes
    // sets var to 1 - repeated applications of +1 do not change anything
    // string program = `:+++++++++1`;
    // more complicated function call: factorial
    // string program = `(\0;1;*{#-1}1\)1:{#5}1`;
    // test function calls, "#" designation for current color
    // string program = `(-1)1>{#_}1`;
    // test conditionals
    // string program = `?;:65\65;?:;?!\ :66\65;?:;?!\ :67\67;?:\ \66;?!\`;
    // test output
    // string program = "??w.,>1r.>25,?!?_?;:65?::97?:";
    // test output, loops, writing
    // string program = "w.,>1r.>25,?!?_:0![+3<1!]wg.v_,";
    // test color outputs with raylib
    // string program = ".a>1b>1c>1d>1e>1f>1g>1h>1i>1j>1k>1l>1m>1n>1o>1p>1q>1r>1s>1t>1u>1w>1x>1y>1z>1w.,";

    bool logToFile = true;
    auto output = cast(immutable) runProgram(program, LogLevel.LOGGING_ALL, logToFile);

    // render output image with bg color white
    bool interactive = false;
    renderPixels(output, interactive);
}

void main() {
    bool logToFile = false;
    // runTests();
    runRepl(LogLevel.LOGGING_DISABLED, logToFile);
}
