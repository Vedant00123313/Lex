LEX/FLEX C++ SOURCE SCANNER — TEAM RUN INSTRUCTIONS

Purpose
-------
This Flex program scans a C++ source file and classifies a practical subset of tokens.
It does not compile or execute the C++ file and does not check full C++ grammar or semantics.

The practical-specific rule flags identifiers longer than 8 characters. This is a requirement
of the lab exercise, NOT a universal restriction of modern C++.

Files
-----
cpp_lexer.l   Flex lexer source
input.cpp     Sample C++ source to scan

Install on Debian/Ubuntu
------------------------
sudo apt update
sudo apt install flex gcc

Build
-----
flex cpp_lexer.l
gcc lex.yy.c -o cpp_lexer

Run
---
./cpp_lexer input.cpp

If your Flex installation requires explicit Flex library linking, use:
gcc lex.yy.c -o cpp_lexer -lfl

Expected checks
---------------
- Keywords such as int, char, return are categorized as Keyword.
- Names such as a and b are categorized as Identifier and added once to the symbol table.
- Integer literals such as 3 and 5 are constants.
- The identifier bilateral is 9 characters and is flagged by the lab's >8 rule.
- The input source itself is only scanned; it is not compiled or executed.

Important implementation notes
-------------------------------
- This is a teaching lexer for a subset of C/C++ tokens, not a complete C++ lexer.
- It uses Flex's longest-match rule and rule order for resolving token matches.
- Preprocessor handling is intentionally limited to a #include directive on a single line.
- The identifier-length rule follows the lab handout, not the C++ language standard.
