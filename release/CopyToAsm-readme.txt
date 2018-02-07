;=====================================================================================
;
; CopyToAsm-readme.txt
;
; v1.0.0.2 - Last updated 07/02/2018
;
;-------------------------------------------------------------------------------------


About
-----

CopyToAsm Plugin (x64) For x64dbg (64bit plugin)
by fearless - www.LetTheLight.in

Created with the x64dbg Plugin SDK For x64 Assembler
https://github.com/mrfearless/x64dbg-Plugin-SDK-For-x64-Assembler


Overview
--------

A plugin to copy a selected disassembly range in the x64dbg cpu view tab and convert to
a masm compatible style assembler code and output to clipboard or the reference view tab.


Features
--------

- Copy selected range to assembler style code.
- Outputs assembler code to clipboard or reference view.
- Adds labels for jump destinations.
- Adjusts jump instructions to point to added labels.
- Indicates if jump destinations are outside selection range.
- Code comments to indicate start/end and outside range.
- Options to adjust comments and label outputs.


Notes
-----

- 29/01/2018 first release
- 03/02/2018 v1.0.0.1
- 07/02/2018 v1.0.0.2