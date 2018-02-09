;=====================================================================================
; x64dbg plugin SDK for Masm - fearless 2015
;
; CopyToAsm.inc
;
;-------------------------------------------------------------------------------------
include windows.inc
include CommCtrl.inc
include shellapi.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib shell32.lib

include LTLILIB64.Inc
includelib LTLILIB64.lib

include masm64.inc
includelib masm64.lib

CTALoadMenuIcon                     PROTO :QWORD, :QWORD

DoCopyToAsm                         PROTO :QWORD

CTABuildJmpTable                    PROTO :QWORD, :QWORD
CTAClearJmpTable                    PROTO
CTAAddressInJmpTable                PROTO :QWORD

CTABuildCallTable                   PROTO :QWORD, :QWORD
CTAClearCallTable                   PROTO
CTAAddressInCallTable               PROTO :QWORD

CTALabelFromCallEntry               PROTO :QWORD, :QWORD
CTALabelFromJmpEntry                PROTO :QWORD, :QWORD, :QWORD
CTAJmpLabelFromJmpEntry             PROTO :QWORD, :QWORD, :QWORD, :QWORD, :QWORD

CTAOutputLabelsOutsideRangeBefore   PROTO :QWORD, :QWORD
CTAOutputLabelsOutsideRangeAfter    PROTO :QWORD, :QWORD
CTARefViewLabelsOutsideRangeBefore  PROTO :QWORD, :QWORD
CTARefViewLabelsOutsideRangeAfter   PROTO :QWORD, :QWORD

CTAOutputCallLabelsOutsideRangeBefore   PROTO :QWORD, :QWORD
CTAOutputCallLabelsOutsideRangeAfter    PROTO :QWORD, :QWORD
CTARefViewCallLabelsOutsideRangeBefore  PROTO :QWORD, :QWORD
CTARefViewCallLabelsOutsideRangeAfter   PROTO :QWORD, :QWORD

CTAMnemonicToMasmHex                PROTO :QWORD, :QWORD, :QWORD
CTAInternalCallToMasmHex            PROTO :QWORD, :QWORD, :QWORD

CTA_AddColumnsToRefView             PROTO :QWORD, :QWORD
CTA_AddRowToRefView                 PROTO :QWORD, :QWORD

Strip_x64dbg_calls                  PROTO :QWORD, :QWORD
Strip_x64dbg_segments               PROTO :QWORD, :QWORD
Strip_x64dbg_anglebrackets          PROTO :QWORD, :QWORD
Strip_x64dbg_modulename             PROTO :QWORD, :QWORD


JMPTABLE_ENTRY          STRUCT
    qwAddress           dq 0
JMPTABLE_ENTRY          ENDS

CALLTABLE_ENTRY         STRUCT
    qwAddress           dq 0 ; call destination address
    qwCallAddress       dq 0 ; instructions address
CALLTABLE_ENTRY         ENDS


.CONST
CRLF                    TEXTEQU <13,10,0> ; carriage return and linefeed for strings that require them (GuiAddLogMessage for example) 

ICO_COPYTOASM           EQU 99
IMG_COPYTOASM_MAIN      EQU 100 ; PNG image for plugin menu icon
IMG_COPYTOASM_CLPB      EQU 101 ; PNG image for plugin menu icon
IMG_COPYTOASM_REFV      EQU 102 ; PNG image for plugin menu icon
IMG_MENU_CHECK          EQU 121 ; Checkmark (tick)
IMG_MENU_NOCHECK        EQU 122 ; No checkmark, just blank space
IMG_MENU_OPTIONS        EQU 123

MENU_COPYTOASM_CLPB1    EQU 1
MENU_COPYTOASM_CLPB2    EQU 2
MENU_COPYTOASM_REFV1    EQU 3
MENU_COPYTOASM_REFV2    EQU 4
MENU_COPYTOASM_FMT1     EQU 5
MENU_COPYTOASM_FMT2     EQU 6
MENU_CTACMTRANGE1       EQU 7
MENU_CTACMTRANGE2       EQU 8
MENU_CTACMTJMPDEST1     EQU 9
MENU_CTACMTJMPDEST2     EQU 10
MENU_CTACMTCALLDEST1    EQU 11
MENU_CTACMTCALLDEST2    EQU 12
MENU_CTARANGELABELS1    EQU 13
MENU_CTARANGELABELS2    EQU 14
MENU_CTALBLUSEADDRESS1  EQU 15
MENU_CTALBLUSEADDRESS2  EQU 16
MENU_CTALBLUSELABEL1    EQU 17
MENU_CTALBLUSELABEL2    EQU 18


.DATA
align 01
szCopyToAsm             DB "CopyToAsm",0
szCopyToAsmLoaded       DB "CopyToAsm loaded.",CRLF
szCopyToAsmUnloaded     DB "CopyToAsm unloaded.",CRLF
szCopyToAsmMenuClip     DB "Selected range to clipboard",0
szCopyToAsmMenuRefv     DB "Selected range to reference view",0
szCopyToAsmFormat       DB "Masm format (uncheck for normal)",0
szCTACommentOptions     DB "Options",0
szCTAOutsideRangeLabels DB "Outside range jump labels (before and after)",0
szCTACmntOutsideRange   DB "Comment jumps/calls when outside range",0
szCTACmntJmpDest        DB "Comment jumps with destination address",0
szCTACmntCallDest       DB "Comment internal calls with destination address",0
szCTALblsUseAddress     DB "Label name uses destination address",0
szCTALblsUseLabel       DB "Label name prepended with 'LABEL_'",0

szCopyToAsmInfo         DB 13,10         
                        DB "CopyToAsm x64 x64dbg plugin by fearless 2018 - www.LetTheLight.in",13,10
                        DB 13,10
                        DB "CopyToAsm Features & Usage:",13,10
                        DB " - Copy selected range to assembler style code.",13,10  
                        DB " - Outputs assembler code to clipboard or reference view.",13,10
                        DB " - Adds labels for jump destinations.",13,10
                        DB " - Adjusts jump instructions to point to added labels.",13,10
                        DB " - Indicates if jump destinations are outside selection range.",13,10
                        DB " - Code comments to indicate start/end and outside range.",13,10
                        DB 13,10,0
                        ;DB " - Removes '0x' from values and appends 'h' for masm style hex values.",13,10

;---------------------------
; Log and error messages
;---------------------------
szDebuggingRequired     DB "CopyToAsm: you need to be debugging to use this option.",CRLF
szStartCopyToAsm        DB "CopyToAsm: Processing selection, please wait...",CRLF
szFinishCopyToAsm       DB "CopyToAsm: finshed processing information, output is on the clipboard.",CRLF
szFinishCopyToAsmRefView DB "CopyToAsm: finshed processing information, output is in the reference view tab.",CRLF
szErrorMaxEntries       DB "CopyToAsm: error building call/jump table, maximum entries exceeded. Operation aborted.",CRLF
szErrorAllocMemJmpTable DB "CopyToAsm: error allocating memory for jump table. Operation aborted.",CRLF
szErrorAllocMemCallTable DB "CopyToAsm: error allocating memory for call table. Operation aborted.",CRLF
szErrorClipboardData    DB "CopyToAsm: error allocating memory for clipboard. Operation aborted.",CRLF
szLogFormatTypeNormal   DB "CopyToAsm: Normal format type specified.",CRLF
szLogFormatTypeMasm     DB "CopyToAsm: Masm style format type specified.",CRLF


;---------------------------
; Comments
;---------------------------
szCommentSelStart       DB 13,10,"; Start of selected range: ",0 ;CRLF
szCommentSelFinish      DB "; Finish of selected range: ",0 ;13,10,13,10
szCommentBeforeRange    DB "; Labels outside selected range (before)",CRLF
szCommentAfterRange     DB 13,10,"; Labels outside selected range (after)",CRLF
szCommentCallsBeforeRange    DB 13,10,"; Internal calls outside selected range (before)",CRLF
szCommentCallsAfterRange     DB 13,10,"; Internal calls outside selected range (after)",CRLF
szCommentOutsideRange   DB " ; outside range",0
szCommentOutsideRange2  DB " - outside range",0
szCmntStart             DB " ; 0x",0
szCmnt                  DB " ; ",0
szMnemStarOnePlus       DB "*1+",0
szMnemStarOneMinus      DB "*1-",0
szMasmHexH              DB "h",0
szHex                   DB "0x",0
szLabel                 DB "LABEL_",0
szCall                  DB "call ",0
szModBaseHex            DB " - ",0
szModBase               DB " (base 0x",0
szModuleSource          DB "; Source: ",0
szDestJmp               DB "=> ",0
szErrCallLabel          DB "Error_Call_Label:",0


;---------------------------
; Ini settings
;---------------------------
szIni                   DB "ini",0
CopyToAsmIni            DB MAX_PATH DUP (0)
szIniFormatType         DB "FormatType",0
szIniOutsideRangeLabels DB "OutsideRangeLabels",0
szIniCmntOutsideRange   DB "CmntOutsideRange",0      
szIniCmntJumpDest       DB "CmntJumpDest",0
szIniCmntCallDest       DB "CmntCallDest",0
szIniLblUseAddress      DB "LblUseAddress"
szIniLblUseLabel        DB "LblUseLabel"


;---------------------------
; Buffers
;---------------------------
szModuleFilename        DB MAX_PATH DUP (0)
szModuleName            DB MAX_PATH DUP (0)
szModuleNameStrip       DB MAX_PATH DUP (0)
szValueString           DB 32 DUP (0)
szLabelX                DB 32 DUP (0)
szCALLFunction          DB MAX_PATH DUP (0)
szCallLabelText         DB MAX_PATH DUP (0)
szDisasmText            DB GUI_MAX_DISASSEMBLY_SIZE DUP (0)
szFormattedDisasmText   DB GUI_MAX_DISASSEMBLY_SIZE DUP (0)


;---------------------------
; RefView
;---------------------------
szRefCopyToAsm          DB "CopyToAsm: ",0
szRefAsmCode            DB "Assembly Code",0
szRefHdrMsg             DB MAX_PATH DUP (0)


;---------------------------
; Punctuation
;---------------------------
szNull                  DB 0,0
szCRLF                  DB 13,10,0
szColon                 DB ":",0
szSpace                 DB " ",0
szQuote                 DB 22h,0
szZero                  DB "0",0
szOne                   DB "1",0
szRightBracket          DB ")",0 
szPlus                  DB "+",0
szMinus                 DB "-",0
szDot                   DB ".",0
szUnderscore            DB "_",0
szOffsetLeftBracket     DB " (",0


;---------------------------
; Global Vars
;---------------------------
g_FormatType            DQ 0 ; 1 masm, 0=msvc
g_OutsideRangeLabels    DQ 1
g_CmntOutsideRange      DQ 1
g_CmntJumpDest          DQ 1
g_CmntCallDest          DQ 1
g_LblUseAddress         DQ 1
g_LblUseLabel           DQ 1

;---------------------------
; Jump Table
;---------------------------
JMPTABLE_ENTRIES_MAX    DQ 0
JMPTABLE_ENTRIES_TOTAL  DQ 0
JMPTABLE                DQ 0 ; pointer to array of JMPTABLE_ENTRIES

CALLTABLE_ENTRIES_MAX   DQ 0
CALLTABLE_ENTRIES_TOTAL DQ 0
CALLTABLE               DQ 0 ; pointer to array of CALLTABLE_ENTRIES


;---------------------------
; Misc
;---------------------------
hImgCheck               ICONDATA <> ; IMG_MENU_CHECK
hImgNoCheck             ICONDATA <> ; IMG_MENU_NOCHECK
ModBase                 DQ 0
CLIPDATASIZE            DQ 0


.DATA?
align 08
hInstance           HINSTANCE ?

