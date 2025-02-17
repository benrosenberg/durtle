module cli;

import std.stdio;

void writeHelpMessage() {
    string help_message = q"DELIM
Help for durtle
---------------

  Notes:
    X is anything that evalues to a number
    C is a color (any lowercase letter besides 'v')
    N is a number (integer)
    Functions cannot be defined inside a function definition

  Movement and direction:
    >X    Move X units right
    <X    Move X units left
    ^X    Move X units up
    vX    Move X units down
    |X    Add X * 90 to the angle in degrees

  Pen and color:
    .    Pen down
    ,    Pen up
    C    Select color
    !    Set color to color at current location

  Variable:
    :X    Set variable to the numerical value of X
    +X    The value of the variable plus X
    -X    The value of the variable minus X
    *X    The value of the variable times X
    /X    The value of the variable divided by X
    @X    The value of the variable raised to the power X
    $X    The value of X raised to the power of the variable
    %X    The value of the variable mod X
    _     The current variable value

  Control flow:
    [...]X          Loop X times
    [...]C          Loop until current color is C
    ~X;...;...\     If/Then/Else with guard "variable == X"
    ~C;...;...\     If/Then/Else with guard "current color == C"
    ~X;...\         If/Then with guard "variable == X"
    ~C;...\         If/Then with guard "current color == C"

  Output:
    ?;    Toggle printing style (line breaks)
    ??    Print this help message
    ?!    Print the current color name
    ?_    Print the variable value
    ?:    Print the variable's ASCII character
    ?|    Print the current heading as a multiple of 90 degrees

  Functions:
    (...)N    Define a function with ID N
    {CX}N     Call function N with parameters C and X

  Miscellaneous:
    `     Begin/end a comment

DELIM";
    writeln(help_message);
}
