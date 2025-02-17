module parser;

import pegged.grammar;

mixin(grammar(q"DELIMITER
Turtle:
    Terms       < (Instruction)+
    Instruction < Right / Left / Up / Down
                  / Loop / Color / Set / Get
                  / Add / Sub / Mul / Div / Pow
                  / RPow / Mod
                  / PenDown / PenUp / PrintCmd
                  / Conditional / FuncDef
                  / FuncCall / Comment / Exp
                  / AngleChange / ColorCond
    AngleChange < "|" Exp
    Comment     < "`" (!"`" .)* "`"
    FuncDef     < "(" FuncTerms ")" Number
    FuncTerms   < FuncTerm+
    FuncTerm    < Right / Left / Up / Down
                  / FuncLoop / ColorExp / Set / Get
                  / Add / Sub / Mul / Div / Pow / RPow / Mod
                  / PenDown / PenUp / PrintCmd
                  / FuncCond / FFuncCall / FuncExp / Comment
                  / FColorCond / AngleChange
    FuncLoop    < "[" FuncTerms "]" (FuncExp / ColorExp)
    FuncCond    < FuncIfElse / FuncIf / FColorIfElse / FColorIf
    FuncIfElse  < "~" FuncExp ";" FuncTerms ";" FuncTerms "\\"
    FuncIf      < "~" FuncExp ";" FuncTerms "\\"
    FFuncCall   < "{" ColorExp FuncExp "}" Number
    FuncCall    < "{" ColorExp Exp "}" Number
    Conditional < IfElse / If
    ColorCond   < ColorIfElse / ColorIf
    FColorCond  < FColorIfElse / FColorIf
    IfElse      < "~" Exp ";" Terms ";" Terms "\\"
    If          < "~" Exp ";" Terms "\\"
    ColorIfElse < "~" ColorExp ";" Terms ";" Terms "\\"
    ColorIf     < "~" ColorExp ";" Terms "\\"
    FColorIfElse< "~" ColorExp ";" FuncTerms ";" FuncTerms "\\"
    FColorIf    < "~" ColorExp ";" FuncTerms "\\"
    ColorExp    < "#" / Color
    PrintCmd    < "?_" / "??" / "?!" / "?:" / "?;" / "?|"
    PrintToggle < ";"
    Right       < ">" Exp
    Left        < "<" Exp
    Up          < "^" Exp
    Down        < "v" Exp
    Loop        < "[" Terms "]" (Exp / ColorExp)
    Color       < [a-z]
    Set         < ":" Exp
    Get         < "!"
    PenDown     < "."
    PenUp       < ","
    MathExp     < Add / Sub / Mul / Div / Pow / RPow / Mod
    Add         < "+" Exp
    Sub         < "-" Exp
    Mul         < "*" Exp
    Div         < "/" Exp
    Pow         < "@" Exp
    RPow        < "$" Exp
    Mod         < "%" Exp
    Exp         < Number / Var / MathExp / FuncCall
                  / Conditional / ColorCond
    FuncExp     < Number / Var / MathExp / FuncCall
                  / FuncCond / FColorCond
    Var         < "_"
    Number      < ~([0-9]+)
DELIMITER"));

ParseTree parseProgram(string program) {
    return Turtle(program);
}
