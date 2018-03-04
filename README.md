# CopyToAsm Plugin (x64) - A Plugin For x64dbg

![](https://github.com/mrfearless/CopyToAsm-Plugin-x64/blob/master/images/copytoasmlogo.png) [Current version: 1.0.0.6 - Last updated: 03/03/2018](https://github.com/mrfearless/CopyToAsm-Plugin-x64/releases/latest) For the x86 version of this plugin, visit [here](https://github.com/mrfearless/CopyToAsm-Plugin-x86)

## Overview

A plugin to copy a selected disassembly range in the x64dbg cpu view tab and convert to a masm compatible style assembler code and output to clipboard or the reference view tab.

## Features

* Copy selected range to assembler style code.
* Outputs assembler code to clipboard or reference view.
* Adds labels for jump destinations.
* Adjusts jump instructions to point to added labels.
* Indicates if jump destinations are outside selection range.
* Code comments to indicate start/end and outside range.
* Options to adjust comments and label outputs.
* Format hex values as C style (0x) or Masm style.
* Registered commands: CopyToAsmClip (ctac) and CopyToAsmRef (ctar)

## Options
![](https://github.com/mrfearless/CopyToAsm-Plugin-x64/blob/master/images/cta_label_options.png) 
![](https://github.com/mrfearless/CopyToAsm-Plugin-x64/blob/master/images/cta_comment_options.png) 
![](https://github.com/mrfearless/CopyToAsm-Plugin-x64/blob/master/images/cta_format_options.png) 

## How to install

* If x64dbg (x64dbg 64bit) is currently running, stop and exit.
* Copy the `CopyToAsm.dp64` to your `x64dbg\x64\plugins` folder.
* Start x64dbg

## Information

* Written by [fearless](https://github.com/mrfearless)  - [www.LetTheLight.in](http://www.LetTheLight.in)
* Created with the [x64dbg Plugin SDK For x64 Assembler](https://github.com/mrfearless/x64dbg-Plugin-SDK-For-x64-Assembler)
* A RadASM project (.rap) is used to manage and compile the plugin. The RadASM IDE can be downloaded [here](http://www.softpedia.com/get/Programming/File-Editors/RadASM.shtml)
* Some plugins make use of the UASM found [here](http://www.terraspace.co.uk/uasm.html)
* Wiki entry: [szLen from Masm32 library CopyToAsm example](https://github.com/mrfearless/CopyToAsm-Plugin-x64/wiki/szLen-from-MASM32-Library---CopyToAsm-Example)

## x64dbg
* [x64dbg website](http://x64dbg.com)
* [x64dbg github](https://github.com/x64dbg/x64dbg)
* [x64dbg gitter](https://gitter.im/x64dbg/x64dbg)