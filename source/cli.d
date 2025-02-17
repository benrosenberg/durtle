module cli;

import std.stdio;

void writeHelpMessage() {
    string help_message = q"DELIM
    "Help for durtle"
    "---------------"
    
    "    Notes:"
    "\tX can be either a positive integer or '_'."
    "\tC is a color (any lowercase letter besides 'v')."
    
    "    Movement:"
    "\t>X\tMove X units right"
    "\t<X\tMove X units left"
    "\t^X\tMove X units up"
    "\tvX\tMove X units down"
    
    "    Pen and color:"
    "\t.\tPen down"
    "\t,\tPen up"
    "\tC\tSelect color"
    "\t!\tSet color to color at current location"
    
    "    Variable:"
    "\t:X\tSet variable to X"
    "\t+X\tAdd X to variable"
    "\t-X\tSubtract X from variable"
    "\t*X\tMultiply variable by X"
    "\t/X\tDivide variable by X"
    "\t_\tUse variable value"
    
    "    Control flow:"
    "\t[...]X\tLoop X times"
    "\t[...]C\tLoop until color C seen"
    
    "    Output:"
    "\t?;\tToggle printing style (line breaks)"
    "\t??\tPrint this help message"
    "\t?!\tPrint the current color name"
    "\t?_\tPrint the variable value"
    "\t?:\tPrint the variable's ASCII character"
DELIM";
    writeln(help_message);
}
