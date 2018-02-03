;=====================================================================================
; x64dbg plugin SDK for Masm - fearless 2015
;
; CopyToAsm.asm
;
;-------------------------------------------------------------------------------------
.686
.MMX
.XMM
.x64

option casemap : none
option win64 : 11
option frame : auto
option stackbase : rsp

_WIN64 EQU 1
WINVER equ 0501h

;DEBUG64 EQU 1
;
;IFDEF DEBUG64
;    PRESERVEXMMREGS equ 1
;    includelib \JWasm\lib\x64\Debug64.lib
;    DBG64LIB equ 1
;    DEBUGEXE textequ <'\Jwasm\bin\DbgWin.exe'>
;    include \JWasm\include\debug64.inc
;    .DATA
;    RDBG_DbgWin	DB DEBUGEXE,0
;    .CODE
;ENDIF

Include x64dbgpluginsdk.inc               ; Main x64dbg Plugin SDK for your program, and prototypes for the main exports 

include x64dbgpluginsdk_x64.inc
includelib x64dbgpluginsdk_x64.lib

Include CopyToAsm.inc                   ; plugin's include file

Include CopyToAsmIni.asm

pluginit	        PROTO :QWORD            ; Required prototype and export for x64dbg plugin SDK
plugstop            PROTO                   ; Required prototype and export for x64dbg plugin SDK
plugsetup           PROTO :QWORD            ; Required prototype and export for x64dbg plugin SDK
;=====================================================================================


.CONST
PLUGIN_VERSION      EQU 1

.DATA
align 01
PLUGIN_NAME         DB "CopyToAsm x64",0

.DATA?
;-------------------------------------------------------------------------------------
; GLOBAL Plugin SDK variables
;-------------------------------------------------------------------------------------
align 08

PUBLIC              pluginHandle
PUBLIC              hwndDlg
PUBLIC              hMenu
PUBLIC              hMenuDisasm
PUBLIC              hMenuDump
PUBLIC              hMenuStack

pluginHandle        DD ?
hwndDlg             DQ ?
hMenu               DD ?
hMenuDisasm         DD ?
hMenuDump           DD ?
hMenuStack          DD ?
hMenuOptions        DD ?
;-------------------------------------------------------------------------------------


.CODE

;=====================================================================================
; Main entry function for a DLL file  - required.
;-------------------------------------------------------------------------------------
DllMain PROC hInst:HINSTANCE, fdwReason:DWORD, lpvReserved:LPVOID
    .IF fdwReason == DLL_PROCESS_ATTACH
        mov rax, hInst
        mov hInstance, rax
    .ENDIF
    mov rax,TRUE
    ret
DllMain Endp


;=====================================================================================
; pluginit - Called by debugger when plugin.dp64 is loaded - needs to be EXPORTED
; 
; Arguments: initStruct - a pointer to a PLUG_INITSTRUCT structure
;
; Notes:     you must fill in the pluginVersion, sdkVersion and pluginName members. 
;            The pluginHandle is obtained from the same structure - it may be needed in
;            other function calls.
;
;            you can call your own setup routine from within this function to setup 
;            menus and commands, and pass the initStruct parameter to this function.
;
;-------------------------------------------------------------------------------------
pluginit PROC FRAME USES RBX initStruct:QWORD
    mov rbx, initStruct

    ; Fill in required information of initStruct, which is a pointer to a PLUG_INITSTRUCT structure
    mov eax, PLUGIN_VERSION
    mov [rbx].PLUG_INITSTRUCT.pluginVersion, eax
    mov eax, PLUG_SDKVERSION
    mov [rbx].PLUG_INITSTRUCT.sdkVersion, eax
    Invoke lstrcpy, Addr [rbx].PLUG_INITSTRUCT.pluginName, Addr PLUGIN_NAME
    
    mov rbx, initStruct
    mov eax, [rbx].PLUG_INITSTRUCT.pluginHandle
    mov pluginHandle, eax
    
    ; Do any other initialization here
    ; Construct plugin's .ini file from module filename
    Invoke GetModuleFileName, 0, Addr szModuleFilename, SIZEOF szModuleFilename
    Invoke GetModuleFileName, hInstance, Addr CopyToAsmIni, SIZEOF CopyToAsmIni
    Invoke szLen, Addr CopyToAsmIni
    lea rbx, CopyToAsmIni
    add rbx, rax
    sub rbx, 4 ; move back past 'dp64' extention
    mov byte ptr [rbx], 0 ; null so we can use lstrcat
    Invoke lstrcat, rbx, Addr szIni ; add 'ini' to end of string instead

	mov rax, TRUE
	ret
pluginit endp


;=====================================================================================
; plugstop - Called by debugger when the plugin.dp64 is unloaded - needs to be EXPORTED
;
; Arguments: none
; 
; Notes:     perform cleanup operations here, clearing menus and other housekeeping
;
;-------------------------------------------------------------------------------------
plugstop PROC FRAME
    
    ; remove any menus, unregister any callbacks etc
    Invoke _plugin_menuclear, hMenu
    Invoke GuiAddLogMessage, Addr szCopyToAsmUnloaded
    
    mov eax, TRUE
    ret
plugstop endp


;=====================================================================================
; plugsetup - Called by debugger to initialize your plugins setup - needs to be EXPORTED
;
; Arguments: setupStruct - a pointer to a PLUG_SETUPSTRUCT structure
; 
; Notes:     setupStruct contains useful handles for use within x64dbg, mainly Qt 
;            menu handles (which are not supported with win32 api) and the main window
;            handle with this information you can add your own menus and menu items 
;            to an existing menu, or one of the predefined supported right click 
;            context menus: hMenuDisam, hMenuDump & hMenuStack
;            
;            plugsetup is called after pluginit. 
;-------------------------------------------------------------------------------------
plugsetup PROC FRAME USES RBX setupStruct:QWORD
    LOCAL hIconData:ICONDATA
    LOCAL hIconDataOptions:ICONDATA
    mov rbx, setupStruct

    ; Extract handles from setupStruct which is a pointer to a PLUG_SETUPSTRUCT structure  
    mov rax, [rbx].PLUG_SETUPSTRUCT.hwndDlg
    mov hwndDlg, rax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenu
    mov hMenu, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuDisasm
    mov hMenuDisasm, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuDump
    mov hMenuDump, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuStack
    mov hMenuStack, eax
    
    ; Do any setup here: add menus, menu items, callback and commands etc
     Invoke _plugin_menuaddentry, hMenu, MENU_COPYTOASM_CLPB1, Addr szCopyToAsmMenuClip    
    Invoke _plugin_menuaddentry, hMenu, MENU_COPYTOASM_REFV1, Addr szCopyToAsmMenuRefv
    Invoke _plugin_menuaddseparator, hMenu
    Invoke _plugin_menuadd, hMenu, Addr szCTACommentOptions
    mov hMenuOptions, eax    
    ;Invoke _plugin_menuaddentry, hMenu, MENU_COPYTOASM_FMT1, Addr szCopyToAsmFormat
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTARANGELABELS1, Addr szCTAOutsideRangeLabels
    Invoke _plugin_menuaddseparator, hMenuOptions
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTRANGE1, Addr szCTACmntOutsideRange
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTJMPDEST1, Addr szCTACmntJmpDest
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTCALLDEST1, Addr szCTACmntCallDest
    Invoke CTALoadMenuIcon, IMG_MENU_OPTIONS, Addr hIconDataOptions
    Invoke _plugin_menuseticon, hMenuOptions, Addr hIconDataOptions

    Invoke _plugin_menuaddentry, hMenuDisasm, MENU_COPYTOASM_CLPB2, Addr szCopyToAsmMenuClip
    Invoke _plugin_menuaddentry, hMenuDisasm, MENU_COPYTOASM_REFV2, Addr szCopyToAsmMenuRefv
    Invoke _plugin_menuaddseparator, hMenuDisasm
    Invoke _plugin_menuadd, hMenuDisasm, Addr szCTACommentOptions
    mov hMenuOptions, eax
    ;Invoke _plugin_menuaddentry, hMenuDisasm, MENU_COPYTOASM_FMT2, Addr szCopyToAsmFormat
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTARANGELABELS2, Addr szCTAOutsideRangeLabels
    Invoke _plugin_menuaddseparator, hMenuOptions
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTRANGE2, Addr szCTACmntOutsideRange
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTJMPDEST2, Addr szCTACmntJmpDest
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTCALLDEST2, Addr szCTACmntCallDest
    Invoke _plugin_menuseticon, hMenuOptions, Addr hIconDataOptions

    Invoke CTALoadMenuIcon, IMG_COPYTOASM_MAIN, Addr hIconData
    .IF rax == TRUE
        Invoke _plugin_menuseticon, hMenu, Addr hIconData
        Invoke _plugin_menuseticon, hMenuDisasm, Addr hIconData
    .ENDIF

    Invoke CTALoadMenuIcon, IMG_COPYTOASM_CLPB, Addr hIconData
    .IF rax == TRUE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_CLPB1, Addr hIconData
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_CLPB2, Addr hIconData
    .ENDIF
    
    Invoke CTALoadMenuIcon, IMG_COPYTOASM_REFV, Addr hIconData
    .IF rax == TRUE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_REFV1, Addr hIconData
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_REFV2, Addr hIconData
    .ENDIF

    Invoke CTALoadMenuIcon, IMG_MENU_CHECK, Addr hImgCheck
    Invoke CTALoadMenuIcon, IMG_MENU_NOCHECK, Addr hImgNoCheck
    
    Invoke IniGetOutsideRangeLabels
    mov g_OutsideRangeLabels, rax
    .IF rax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS1, Addr hImgCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS2, Addr hImgCheck
        ;Invoke GuiAddLogMessage, Addr szLogFormatTypeNormal
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS1, Addr hImgNoCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS2, Addr hImgNoCheck
        ;Invoke GuiAddLogMessage, Addr szLogFormatTypeMasm
    .ENDIF
    
    Invoke IniGetCmntOutsideRange
    mov g_CmntOutsideRange, rax
    .IF rax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE1, Addr hImgCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE2, Addr hImgCheck
        ;Invoke GuiAddLogMessage, Addr szLogFormatTypeNormal
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE1, Addr hImgNoCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE2, Addr hImgNoCheck
        ;Invoke GuiAddLogMessage, Addr szLogFormatTypeMasm
    .ENDIF
    
    Invoke IniGetCmntJumpDest
    mov g_CmntJumpDest, rax
    .IF rax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST1, Addr hImgCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST2, Addr hImgCheck
        ;Invoke GuiAddLogMessage, Addr szLogFormatTypeNormal
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST1, Addr hImgNoCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST2, Addr hImgNoCheck
        ;Invoke GuiAddLogMessage, Addr szLogFormatTypeMasm
    .ENDIF
    
    Invoke IniGetCmntCallDest
    mov g_CmntCallDest, rax
    .IF rax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST1, Addr hImgCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST2, Addr hImgCheck
        ;Invoke GuiAddLogMessage, Addr szLogFormatTypeNormal
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST1, Addr hImgNoCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST2, Addr hImgNoCheck
        ;Invoke GuiAddLogMessage, Addr szLogFormatTypeMasm
    .ENDIF    

    Invoke GuiAddLogMessage, Addr szCopyToAsmInfo
    Invoke GuiGetWindowHandle
    mov hwndDlg, rax  
    
    ret
plugsetup endp


;=====================================================================================
; CBMENUENTRY - Called by debugger when a menu item is clicked - needs to be EXPORTED
;
; Arguments: cbType
;            cbInfo - a pointer to a PLUG_CB_MENUENTRY structure. The hEntry contains 
;            the resource id of menu item identifiers
;  
; Notes:     hEntry can be used to determine if the user has clicked on your plugins
;            menu item(s) and to do something in response to it.
;            Needs to be PROC C type procedure call to be compatible with debugger
;-------------------------------------------------------------------------------------
CBMENUENTRY PROC FRAME USES RBX cbType:QWORD, cbInfo:QWORD
    mov rbx, cbInfo
    xor rax, rax    
    mov eax, [rbx].PLUG_CB_MENUENTRY.hEntry
    
    .IF eax == MENU_COPYTOASM_CLPB1 || eax == MENU_COPYTOASM_CLPB2
       Invoke DbgIsDebugging
        .IF rax == FALSE
            Invoke GuiAddStatusBarMessage, Addr szDebuggingRequired
            Invoke GuiAddLogMessage, Addr szDebuggingRequired
        .ELSE
            Invoke DoCopyToAsm, 0 ; clipboard
        .ENDIF
        
    .ELSEIF eax == MENU_COPYTOASM_REFV1 || eax == MENU_COPYTOASM_REFV2
       Invoke DbgIsDebugging
        .IF rax == FALSE
            Invoke GuiAddStatusBarMessage, Addr szDebuggingRequired
            Invoke GuiAddLogMessage, Addr szDebuggingRequired
        .ELSE
            Invoke DoCopyToAsm, 1 ; refview
        .ENDIF
        
   
    .ELSEIF eax == MENU_COPYTOASM_FMT1 || eax == MENU_COPYTOASM_FMT2
        mov rax, g_FormatType
        .IF rax == 1
            mov g_FormatType, 0
            Invoke IniSetFormatType, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT2, Addr hImgNoCheck
            ;Invoke GuiAddLogMessage, Addr szLogFormatTypeNormal
        .ELSE
            mov g_FormatType, 1
            Invoke IniSetFormatType, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT2, Addr hImgCheck
            ;Invoke GuiAddLogMessage, Addr szLogFormatTypeMasm
        .ENDIF

    .ELSEIF eax == MENU_CTARANGELABELS1 || eax == MENU_CTARANGELABELS2

        mov rax, g_OutsideRangeLabels
        .IF rax == 1
            mov g_OutsideRangeLabels, 0
            Invoke IniSetOutsideRangeLabels, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS2, Addr hImgNoCheck
        .ELSE
            mov g_OutsideRangeLabels, 1
            Invoke IniSetOutsideRangeLabels, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS2, Addr hImgCheck
        .ENDIF

    .ELSEIF eax == MENU_CTACMTRANGE1 || eax == MENU_CTACMTRANGE2

        mov rax, g_CmntOutsideRange
        .IF rax == 1
            mov g_CmntOutsideRange, 0
            Invoke IniSetCmntOutsideRange, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE2, Addr hImgNoCheck
        .ELSE
            mov g_CmntOutsideRange, 1
            Invoke IniSetCmntOutsideRange, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE2, Addr hImgCheck
        .ENDIF

    .ELSEIF eax == MENU_CTACMTJMPDEST1 || eax == MENU_CTACMTJMPDEST2

        mov rax, g_CmntJumpDest
        .IF rax == 1
            mov g_CmntJumpDest, 0
            Invoke IniSetCmntJumpDest, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST2, Addr hImgNoCheck
        .ELSE
            mov g_CmntJumpDest, 1
            Invoke IniSetCmntJumpDest, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST2, Addr hImgCheck
        .ENDIF

    .ELSEIF eax == MENU_CTACMTCALLDEST1 || eax == MENU_CTACMTCALLDEST2

        mov rax, g_CmntCallDest
        .IF rax == 1
            mov g_CmntCallDest, 0
            Invoke IniSetCmntCallDest, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST2, Addr hImgNoCheck
        .ELSE
            mov g_CmntCallDest, 1
            Invoke IniSetCmntCallDest, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST2, Addr hImgCheck
        .ENDIF        

    .ENDIF
    
    mov rax, TRUE
    ret

CBMENUENTRY endp


;=====================================================================================
; CTALoadMenuIcon - Loads RT_RCDATA png resource and assigns it to ICONDATA
; Returns TRUE in eax if succesful or FALSE otherwise.
;-------------------------------------------------------------------------------------
CTALoadMenuIcon PROC FRAME USES RBX dqImageResourceID:QWORD, lpIconData:QWORD
    LOCAL hRes:QWORD
    
    ; Load image for our menu item
    Invoke FindResource, hInstance, dqImageResourceID, RT_RCDATA ; load png image as raw data
    .IF eax != NULL
        mov hRes, rax
        Invoke SizeofResource, hInstance, hRes
        .IF rax != 0
            mov rbx, lpIconData
            mov [rbx].ICONDATA.size_, rax
            Invoke LoadResource, hInstance, hRes
            .IF rax != NULL
                Invoke LockResource, rax
                .IF rax != NULL
                    mov rbx, lpIconData
                    mov [rbx].ICONDATA.data, rax
                    mov rax, TRUE
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov rax, FALSE
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov rax, FALSE
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov rax, FALSE
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov rax, FALSE
    .ENDIF    
    ret

CTALoadMenuIcon ENDP



;-------------------------------------------------------------------------------------
; Copies selected disassembly range to clipboard and formats as masm style code
; fixes jmps and labels relative to each other, removes segments and 0x from instructions
;-------------------------------------------------------------------------------------
DoCopyToAsm PROC FRAME USES RBX RCX qwOutput:QWORD
    LOCAL bii:BASIC_INSTRUCTION_INFO ; basic 
    LOCAL cbii:BASIC_INSTRUCTION_INFO ; call destination    
    LOCAL sel:SELECTIONDATA
    LOCAL sellength:QWORD
    LOCAL qwStartAddress:QWORD
    LOCAL qwFinishAddress:QWORD
    LOCAL qwCurrentAddress:QWORD
    LOCAL JmpDestination:QWORD
    LOCAL CallDestination:QWORD
    LOCAL ptrClipboardData:QWORD
    LOCAL LenClipData:QWORD
    LOCAL pClipData:QWORD
    LOCAL hClipData:QWORD
    LOCAL bOutsideRange:QWORD
    LOCAL qwCTALIndex:QWORD
    
    
    Invoke DbgIsDebugging
    .IF rax == FALSE
        Invoke GuiAddLogMessage, Addr szDebuggingRequired
        ret
    .ENDIF
    Invoke GuiAddStatusBarMessage, Addr szStartCopyToAsm


    ;----------------------------------
    ; Get selection information
    ;----------------------------------
    Invoke GuiSelectionGet, GUI_DISASSEMBLY, Addr sel
    mov rax, sel.finish
    mov qwFinishAddress, rax
    mov rbx, sel.start
    mov qwStartAddress, rbx
    sub rax, rbx
    mov sellength, rax
    mov qwCTALIndex, 0

    ;----------------------------------
    ; Get some info for user
    ;----------------------------------
    Invoke ModNameFromAddr, sel.start, Addr szModuleName, TRUE
    Invoke ModNameFromAddr, sel.start, Addr szModuleNameStrip, FALSE
    Invoke szCatStr, Addr szModuleNameStrip, Addr szDot    
    Invoke ModBaseFromAddr, sel.start
    mov ModBase, rax


    ;----------------------------------
    ; 1st pass build jmp destination array
    ;----------------------------------
    Invoke CTABuildJmpTable, qwStartAddress, qwFinishAddress
    .IF rax == FALSE
        ret
    .ENDIF

    .IF qwOutput == 0 ; clipboard
        ;----------------------------------
        ; Alloc space for clipboard data
        ;----------------------------------
        .IF CLIPDATASIZE != 0
            Invoke szLen, Addr szModuleName
            add rax, 64d; "; Source: "+CRLF + CRLF + (base 0x12345678 - 12345678)
            add CLIPDATASIZE, rax
    
            Invoke GlobalAlloc, GMEM_FIXED + GMEM_ZEROINIT, CLIPDATASIZE
            .IF rax == NULL
                Invoke GuiAddStatusBarMessage, Addr szErrorClipboardData
                mov rax, FALSE
                ret
            .ENDIF
            mov ptrClipboardData, rax    
            Invoke OpenClipboard, 0
            .IF rax == 0
                Invoke GlobalFree, ptrClipboardData
                Invoke GuiAddStatusBarMessage, Addr szErrorClipboardData
                mov rax, FALSE
                ret
            .ENDIF
            Invoke EmptyClipboard
        .ELSE
            Invoke GuiAddStatusBarMessage, Addr szErrorClipboardData
        .ENDIF
    
    
        ;----------------------------------
        ; Start : Module Name and Base
        ;----------------------------------
        Invoke szCatStr, ptrClipboardData, Addr szModuleSource
        Invoke szCatStr, ptrClipboardData, Addr szModuleName
        Invoke qw2hex, ModBase, Addr szValueString
        Invoke szCatStr, ptrClipboardData, Addr szModBase
        Invoke szCatStr, ptrClipboardData, Addr szValueString
        Invoke utoa_ex, ModBase, Addr szValueString, 10, FALSE, TRUE
        Invoke szCatStr, ptrClipboardData, Addr szModBaseHex
        Invoke szCatStr, ptrClipboardData, Addr szValueString
        Invoke szCatStr, ptrClipboardData, Addr szRightBracket
        Invoke szCatStr, ptrClipboardData, Addr szCRLF
        Invoke szCatStr, ptrClipboardData, Addr szCRLF
    
        
        .IF g_OutsideRangeLabels == 1
            ;----------------------------------
            ; Labels Before
            ;----------------------------------
            Invoke CTAOutputLabelsOutsideRangeBefore, qwStartAddress, ptrClipboardData
        .ENDIF
    
        ;----------------------------------
        ; Start Information
        ;----------------------------------
        Invoke szCatStr, ptrClipboardData, Addr szCommentSelStart
        Invoke qw2hex, qwStartAddress, Addr szValueString
        Invoke szCatStr, ptrClipboardData, Addr szHex
        Invoke szCatStr, ptrClipboardData, Addr szValueString
        ;Invoke szCatStr, ptrClipboardData, Addr szOffsetLeftBracket
        ;Invoke utoa_ex, qwStartAddress, Addr szValueString, 10, FALSE, TRUE
        ;Invoke szCatStr, ptrClipboardData, Addr szValueString
        ;Invoke szCatStr, ptrClipboardData, Addr szRightBracket
        Invoke szCatStr, ptrClipboardData, Addr szCRLF
        
    .ELSE ; output to reference view

        Invoke CTA_AddColumnsToRefView, qwStartAddress, qwFinishAddress
        
        .IF g_OutsideRangeLabels == 1
            ;----------------------------------
            ; Labels Before
            ;----------------------------------        
            Invoke CTARefViewLabelsOutsideRangeBefore, qwStartAddress, qwCTALIndex
            mov qwCTALIndex, rax
        .ENDIF

    .ENDIF


    ;----------------------------------
    ; Start main loop processing selection
    ;----------------------------------
    mov rax, qwStartAddress
    mov qwCurrentAddress, rax
    .WHILE rax <= qwFinishAddress
        
        Invoke CTAAddressInJmpTable, qwCurrentAddress
        .IF rax != 0
            Invoke CTALabelFromJmpEntry, rax, Addr szLabelX
            .IF qwOutput == 0 ; output to clipboard
                Invoke szCatStr, ptrClipboardData, Addr szCRLF
                Invoke szCatStr, ptrClipboardData, Addr szLabelX
                Invoke szCatStr, ptrClipboardData, Addr szCRLF
            .ELSE ; output to reference view
                Invoke CTA_AddRowToRefView, qwCTALIndex, Addr szLabelX
                inc qwCTALIndex
            .ENDIF
        .ENDIF
        
        Invoke RtlZeroMemory, Addr bii, SIZEOF BASIC_INSTRUCTION_INFO
        Invoke DbgDisasmFastAt, qwCurrentAddress, Addr bii
        movzx rax, byte ptr bii.call_
        movzx rbx, byte ptr bii.branch
        
        .IF rax == 1 && rbx == 1 ; we have call statement
            Invoke GuiGetDisassembly, qwCurrentAddress, Addr szDisasmText
            mov rax, bii.address
            mov CallDestination, rax
            Invoke RtlZeroMemory, Addr cbii, SIZEOF BASIC_INSTRUCTION_INFO
            Invoke DbgDisasmFastAt, CallDestination, Addr cbii
            
            ;mov rax, cbii.address
            ;.IF rax == 0
                mov rax, bii.address
            ;.ENDIF
            mov JmpDestination, rax
            Invoke Strip_x64dbg_calls, Addr szDisasmText, Addr szCALLFunction
            Invoke szCopy, Addr szCall, Addr szFormattedDisasmText
            Invoke szCatStr, Addr szFormattedDisasmText, Addr szCALLFunction
            
            ;mov rax, bii.address
            ;PrintQWORD rax
            ;mov rax, cbii.address
            ;PrintQWORD rax
            
            ;movzx eax, byte ptr cbii.call_
            ;PrintDWORD eax
            ;movzx eax, byte ptr cbii.branch
            ;PrintDWORD eax
            
            
            ;movzx eax, byte ptr cbii.branch
            mov rax, bii.address
            .IF eax == 0 ; external function call
            .ELSE ; internal function call
                Invoke qw2hex, JmpDestination, Addr szValueString
                .IF g_CmntOutsideRange == 1
                    mov rax, qwStartAddress
                    mov rbx, qwFinishAddress
                    .IF JmpDestination < rax || JmpDestination > rbx
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmnt
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szDestJmp
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szHex
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szCommentOutsideRange2
                    .ELSE
                        .IF g_CmntCallDest == 1
                            Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmnt
                            Invoke szCatStr, Addr szFormattedDisasmText, Addr szDestJmp
                            Invoke szCatStr, Addr szFormattedDisasmText, Addr szHex
                            Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
                        .ENDIF
                    .ENDIF
                .ELSE
                    .IF g_CmntCallDest == 1
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmnt
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szDestJmp
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szHex
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
                    .ENDIF
                .ENDIF
            .ENDIF

        .ELSEIF rax == 0 && rbx == 1 ; jumps
            Invoke DbgGetBranchDestination, qwCurrentAddress
            mov JmpDestination, rax
            
            mov rax, qwStartAddress
            mov rbx, qwFinishAddress
            .IF JmpDestination < rax || JmpDestination > rbx
                mov bOutsideRange, TRUE
            .ELSE
                mov bOutsideRange, FALSE
            .ENDIF
            
            Invoke GuiGetDisassembly, qwCurrentAddress, Addr szDisasmText
            Invoke CTAAddressInJmpTable, JmpDestination
            .IF rax != 0
                Invoke CTAJmpLabelFromJmpEntry, rax, JmpDestination, bOutsideRange, Addr szDisasmText, Addr szFormattedDisasmText
            .ELSE
                ;PrintText 'jmp destination not in CTAAddressInJmpTable!'
            .ENDIF

        .ELSE ; normal non jump or call instructions
            Invoke GuiGetDisassembly, qwCurrentAddress, Addr szDisasmText
            Invoke Strip_x64dbg_segments, Addr szDisasmText, Addr szFormattedDisasmText
            Invoke Strip_x64dbg_anglebrackets, Addr szFormattedDisasmText, Addr szDisasmText
            Invoke Strip_x64dbg_modulename, Addr szDisasmText, Addr szFormattedDisasmText

        .ENDIF
        
        .IF qwOutput == 0 ; output to clipboard
            Invoke szCatStr, ptrClipboardData, Addr szFormattedDisasmText
            Invoke szCatStr, ptrClipboardData, Addr szCRLF
        .ELSE ; output to reference view
            Invoke CTA_AddRowToRefView, qwCTALIndex, Addr szFormattedDisasmText
        .ENDIF
        
        inc qwCTALIndex
        
        mov eax, bii.size_ 
        add qwCurrentAddress, rax        
        mov rax, qwCurrentAddress
    .ENDW    
    ;----------------------------------
    ; End main loop
    ;----------------------------------


    .IF qwOutput == 0 ; output to clipboard
        ;----------------------------------
        ; Finish Information
        ;----------------------------------
        Invoke szCatStr, ptrClipboardData, Addr szCommentSelFinish
        Invoke qw2hex, qwFinishAddress, Addr szValueString
        Invoke szCatStr, ptrClipboardData, Addr szHex
        Invoke szCatStr, ptrClipboardData, Addr szValueString
        ;Invoke szCatStr, ptrClipboardData, Addr szOffsetLeftBracket
        ;Invoke utoa_ex, qwFinishAddress, Addr szValueString, 10, FALSE, TRUE
        ;Invoke szCatStr, ptrClipboardData, Addr szValueString
        ;Invoke szCatStr, ptrClipboardData, Addr szRightBracket
        Invoke szCatStr, ptrClipboardData, Addr szCRLF
        ;Invoke szCatStr, ptrClipboardData, Addr szCRLF
    
        .IF g_OutsideRangeLabels == 1
            ;----------------------------------
            ; Labels After
            ;----------------------------------
            Invoke CTAOutputLabelsOutsideRangeAfter, qwFinishAddress, ptrClipboardData
        .ENDIF
        
    .ELSE

        .IF g_OutsideRangeLabels == 1
            ;----------------------------------
            ; Labels After
            ;----------------------------------    
            Invoke CTARefViewLabelsOutsideRangeAfter, qwFinishAddress, qwCTALIndex
            mov qwCTALIndex, rax
        .ENDIF
    
    .ENDIF


    Invoke CTAClearJmpTable ; free jmp table


    .IF qwOutput == 0 ; output to clipboard
        ;----------------------------------
        ; set clipboard data
        ;----------------------------------
        Invoke szLen, ptrClipboardData
        .IF eax != 0
            mov LenClipData, rax
            inc rax
            Invoke GlobalAlloc, GMEM_MOVEABLE, rax
            .IF rax == NULL
                Invoke GlobalFree, ptrClipboardData
                Invoke CloseClipboard
                ret
            .ENDIF
            mov hClipData, rax
            
            Invoke GlobalLock, hClipData
            .IF rax == NULL
                Invoke GlobalFree, ptrClipboardData
                Invoke GlobalFree, hClipData
                Invoke CloseClipboard
                ret
            .ENDIF
            mov pClipData, rax
            mov rax, LenClipData
            Invoke RtlMoveMemory, pClipData, ptrClipboardData, rax
            
            Invoke GlobalUnlock, hClipData 
            invoke SetClipboardData, CF_TEXT, hClipData
        
            Invoke CloseClipboard
            Invoke GlobalFree, ptrClipboardData
        .ENDIF
    
        ;PrintText 'Finished'
        Invoke GuiAddStatusBarMessage, Addr szFinishCopyToAsm
        
    .ELSE
    
        Invoke GuiAddStatusBarMessage, Addr szFinishCopyToAsmRefView
        Invoke GuiReferenceSetSingleSelection, 0, TRUE
        Invoke GuiReferenceReloadData
    .ENDIF
    ret

DoCopyToAsm ENDP




;-------------------------------------------------------------------------------------
; 1st pass of selection, build an array of jmp destinations
; estimates size required based on selection size (bytes) / 2 (jmp near = 2 bytes long)
; = no of entries (max safe estimate) * size jmptable_entry struct
; also roughly calcs the size of clipboard data required
;-------------------------------------------------------------------------------------
CTABuildJmpTable PROC FRAME USES RBX qwStartAddress:QWORD, qwFinishAddress:QWORD
    LOCAL bii:BASIC_INSTRUCTION_INFO ; basic 
    LOCAL qwJmpTableSize:QWORD
    LOCAL qwCurrentAddress:QWORD
    LOCAL JmpDestination:QWORD
    LOCAL nJmpEntry:QWORD
    LOCAL ptrJmpEntry:QWORD

    
    ;PrintText 'CTABuildJmpTable'
    
    mov CLIPDATASIZE, 0
    
    mov rax, qwFinishAddress
    mov rbx, qwStartAddress
    sub rax, rbx
    .IF sqword ptr rax < 0
        neg rax
    .ENDIF
    shr rax, 1 ; div by 2
    mov JMPTABLE_ENTRIES_MAX, rax
    mov rbx, SIZEOF JMPTABLE_ENTRY
    mul rbx
    mov qwJmpTableSize, rax
    
    Invoke GlobalAlloc, GMEM_FIXED + GMEM_ZEROINIT, qwJmpTableSize
    .IF rax == NULL
        Invoke GuiAddStatusBarMessage, Addr szErrorAllocMemJmpTable
        mov rax, FALSE
        ret
    .ENDIF
    mov JMPTABLE, rax
    mov ptrJmpEntry, rax
    mov nJmpEntry, 0

    mov rax, qwStartAddress
    mov qwCurrentAddress, rax


    .WHILE rax <= qwFinishAddress
        Invoke DbgDisasmFastAt, qwCurrentAddress, Addr bii
        movzx rax, byte ptr bii.call_
        movzx rbx, byte ptr bii.branch
        
        .IF rax == 0 && rbx == 1 ; jumps
            ;mov eax, bii.address
            Invoke DbgGetBranchDestination, qwCurrentAddress
            mov JmpDestination, rax
           ; PrintDec JmpDestination
            
            
            mov rbx, ptrJmpEntry
            mov rax, JmpDestination
            mov [rbx].JMPTABLE_ENTRY.qwAddress, rax
            
            inc nJmpEntry
            inc JMPTABLE_ENTRIES_TOTAL
            
            mov rax, JMPTABLE_ENTRIES_TOTAL
            .IF rax >= JMPTABLE_ENTRIES_MAX
                Invoke GuiAddStatusBarMessage, Addr szErrorMaxEntries
                mov rax, FALSE
                ret
            .ENDIF
            
            add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
        .ENDIF
        
        Invoke GuiGetDisassembly, qwCurrentAddress, Addr szDisasmText
        Invoke szLen, Addr szDisasmText
        add rax, 2 ; for CRLF pairs for each line
        add CLIPDATASIZE, rax

        mov eax, bii.size_ 
        add qwCurrentAddress, rax
        mov rax, qwCurrentAddress
    .ENDW    
    
    mov rax, JMPTABLE_ENTRIES_TOTAL
    mov rbx, 3 ; for extra label entries at start/finish for outside range labels
    mul rbx
    mov rbx, 96d ; LABEL_123456789 CRLF (18) + JMP LABEL_123456789 CRLF (22) = (40) round up = 64 + 16 for jmp outside range
    mul rbx
    add rax, 240d ;32d + 32d + 48d + 48d +8 +8 +20 +20; for additional comments
    add CLIPDATASIZE, rax
    
    
    ;PrintDec dwJmpTableSize
    ;PrintDec JMPTABLE_ENTRIES_MAX
    ;PrintDec JMPTABLE_ENTRIES_TOTAL
    ;DbgDump JMPTABLE, dwJmpTableSize
    
    mov rax, TRUE
    ret

CTABuildJmpTable ENDP


;-------------------------------------------------------------------------------------
; Frees memory of the jmptable and reset vars
;-------------------------------------------------------------------------------------
CTAClearJmpTable PROC FRAME
    
    mov JMPTABLE_ENTRIES_MAX, 0
    mov JMPTABLE_ENTRIES_TOTAL, 0
    mov rax, JMPTABLE
    .IF rax != 0
        Invoke GlobalFree, rax
    .ENDIF
    ret

CTAClearJmpTable ENDP


;-------------------------------------------------------------------------------------
; returns 0 if address is not in JMPTABLE, otherwise returns an 1-based index in eax
; each address can be checked to see if it a destination for a jmp instruction
; if it is then a label can be created an inserted before the instruction
; if it is a jmp instruction the jmp destination can be searched for and if found
; a jmp label can be inserted instead of the disassembled jmp instruction.
;-------------------------------------------------------------------------------------
CTAAddressInJmpTable PROC FRAME USES RBX qwAddress:QWORD
    LOCAL nJmpEntry:QWORD
    LOCAL ptrJmpEntry:QWORD
    
    .IF JMPTABLE == 0 || JMPTABLE_ENTRIES_TOTAL == 0
        mov rax, 0
        ret
    .ENDIF
    
    mov rax, JMPTABLE
    mov ptrJmpEntry, rax
    mov nJmpEntry, 0
    mov rax, 0
    .WHILE rax < JMPTABLE_ENTRIES_TOTAL
        mov rbx, ptrJmpEntry
        mov rax, [rbx].JMPTABLE_ENTRY.qwAddress
        .IF rax == qwAddress
            mov rax, nJmpEntry
            inc rax ; for 1 based index
            ret
        .ENDIF
        add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
        inc nJmpEntry
        mov rax, nJmpEntry
    .ENDW
    mov rax, 0
    ret
CTAAddressInJmpTable ENDP



;-------------------------------------------------------------------------------------
; Called before main loop output to clipboard labels outside range (before) selection
;-------------------------------------------------------------------------------------
CTAOutputLabelsOutsideRangeBefore PROC FRAME USES RBX qwStartAddress:QWORD, pDataBuffer:QWORD
    LOCAL nJmpEntry:QWORD
    LOCAL ptrJmpEntry:QWORD
    LOCAL bOutputComment:QWORD
    LOCAL qwAddress:QWORD
    
    .IF JMPTABLE == 0 || JMPTABLE_ENTRIES_TOTAL == 0
        mov rax, 0
        ret
    .ENDIF
    
    mov bOutputComment, FALSE
    
    mov rax, JMPTABLE
    mov ptrJmpEntry, rax
    mov nJmpEntry, 0
    mov rax, 0
    .WHILE rax < JMPTABLE_ENTRIES_TOTAL
        mov rbx, ptrJmpEntry
        mov rax, [rbx].JMPTABLE_ENTRY.qwAddress
        mov qwAddress, rax
        .IF rax < qwStartAddress
            .IF bOutputComment == FALSE
                Invoke szCatStr, pDataBuffer, Addr szCommentBeforeRange
                mov bOutputComment, TRUE 
            .ENDIF
            mov rax, nJmpEntry
            inc rax ; for 1 based index            
            Invoke CTALabelFromJmpEntry, rax, Addr szLabelX
            Invoke szCatStr, pDataBuffer, Addr szCRLF 
            Invoke szCatStr, pDataBuffer, Addr szLabelX
            .IF g_CmntJumpDest == 1
                Invoke qw2hex, qwAddress, Addr szValueString
                Invoke szCatStr, pDataBuffer, Addr szCmntStart
                Invoke szCatStr, pDataBuffer, Addr szValueString
            .ENDIF
            Invoke szCatStr, pDataBuffer, Addr szCRLF            

        .ENDIF
        add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
        inc nJmpEntry
        mov rax, nJmpEntry
    .ENDW
    mov rax, 0
    ret
CTAOutputLabelsOutsideRangeBefore ENDP


;-------------------------------------------------------------------------------------
; Called before main loop output to refview labels outside range (before) selection
;-------------------------------------------------------------------------------------
CTARefViewLabelsOutsideRangeBefore PROC FRAME USES RBX qwStartAddress:QWORD, qwCount:QWORD
    LOCAL nJmpEntry:QWORD
    LOCAL ptrJmpEntry:QWORD
    LOCAL qwAddress:QWORD
    LOCAL qwCTALIndex:QWORD
    
    .IF JMPTABLE == 0 || JMPTABLE_ENTRIES_TOTAL == 0
        mov rax, 0
        ret
    .ENDIF
    
    mov rax, qwCount
    mov qwCTALIndex, rax
    
    mov rax, JMPTABLE
    mov ptrJmpEntry, rax
    mov nJmpEntry, 0
    mov rax, 0
    .WHILE rax < JMPTABLE_ENTRIES_TOTAL
        mov rbx, ptrJmpEntry
        mov rax, [rbx].JMPTABLE_ENTRY.qwAddress
        mov qwAddress, rax
        .IF rax < qwStartAddress

            mov rax, nJmpEntry
            inc rax ; for 1 based index            
            Invoke CTALabelFromJmpEntry, rax, Addr szLabelX
            Invoke szCopy, Addr szLabelX, Addr szFormattedDisasmText
            .IF g_CmntJumpDest == 1
                Invoke qw2hex, qwAddress, Addr szValueString
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmntStart
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
            .ENDIF
            Invoke CTA_AddRowToRefView, qwCTALIndex, Addr szFormattedDisasmText
            inc qwCTALIndex

        .ENDIF
        add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
        inc nJmpEntry
        mov rax, nJmpEntry
    .ENDW
    mov rax, qwCTALIndex
    ret
CTARefViewLabelsOutsideRangeBefore ENDP


;-------------------------------------------------------------------------------------
; Called after main loop output to clipboard labels outside range (after) selection
;-------------------------------------------------------------------------------------
CTAOutputLabelsOutsideRangeAfter PROC FRAME USES RBX qwFinishAddress:QWORD, pDataBuffer:QWORD
    LOCAL nJmpEntry:QWORD
    LOCAL ptrJmpEntry:QWORD
    LOCAL bOutputComment:QWORD
    LOCAL qwAddress:QWORD
    
    .IF JMPTABLE == 0 || JMPTABLE_ENTRIES_TOTAL == 0
        mov rax, 0
        ret
    .ENDIF
    
    mov bOutputComment, FALSE
    
    mov rax, JMPTABLE
    mov ptrJmpEntry, rax
    mov nJmpEntry, 0
    mov rax, 0
    .WHILE rax < JMPTABLE_ENTRIES_TOTAL
        mov rbx, ptrJmpEntry
        mov rax, [rbx].JMPTABLE_ENTRY.qwAddress
        mov qwAddress, rax
        .IF rax > qwFinishAddress
            .IF bOutputComment == FALSE
                Invoke szCatStr, pDataBuffer, Addr szCommentAfterRange
                mov bOutputComment, TRUE 
            .ENDIF
            mov rax, nJmpEntry
            inc rax ; for 1 based index            
            Invoke CTALabelFromJmpEntry, rax, Addr szLabelX
            Invoke szCatStr, pDataBuffer, Addr szCRLF 
            Invoke szCatStr, pDataBuffer, Addr szLabelX
            .IF g_CmntJumpDest == 1
                Invoke qw2hex, qwAddress, Addr szValueString
                Invoke szCatStr, pDataBuffer, Addr szCmntStart
                Invoke szCatStr, pDataBuffer, Addr szValueString
            .ENDIF
            Invoke szCatStr, pDataBuffer, Addr szCRLF

        .ENDIF
        add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
        inc nJmpEntry
        mov rax, nJmpEntry
    .ENDW
    mov rax, 0
    ret
CTAOutputLabelsOutsideRangeAfter ENDP


;-------------------------------------------------------------------------------------
; Called before main loop output to refview labels outside range (after) selection
;-------------------------------------------------------------------------------------
CTARefViewLabelsOutsideRangeAfter PROC FRAME USES RBX qwFinishAddress:QWORD, qwCount:QWORD
    LOCAL nJmpEntry:QWORD
    LOCAL ptrJmpEntry:QWORD
    LOCAL qwAddress:QWORD
    LOCAL qwCTALIndex:QWORD
    
    .IF JMPTABLE == 0 || JMPTABLE_ENTRIES_TOTAL == 0
        mov rax, 0
        ret
    .ENDIF
    
    mov rax, qwCount
    mov qwCTALIndex, rax
    
    mov rax, JMPTABLE
    mov ptrJmpEntry, rax
    mov nJmpEntry, 0
    mov rax, 0
    .WHILE rax < JMPTABLE_ENTRIES_TOTAL
        mov rbx, ptrJmpEntry
        mov rax, [rbx].JMPTABLE_ENTRY.qwAddress
        mov qwAddress, rax
        .IF rax > qwFinishAddress

            mov rax, nJmpEntry
            inc rax ; for 1 based index            
            Invoke CTALabelFromJmpEntry, rax, Addr szLabelX
            Invoke szCopy, Addr szLabelX, Addr szFormattedDisasmText
            .IF g_CmntJumpDest == 1
                Invoke qw2hex, qwAddress, Addr szValueString
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmntStart
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
            .ENDIF
            Invoke CTA_AddRowToRefView, qwCTALIndex, Addr szFormattedDisasmText
            inc qwCTALIndex

        .ENDIF
        add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
        inc nJmpEntry
        mov rax, nJmpEntry
    .ENDW
    mov rax, qwCTALIndex
    ret
CTARefViewLabelsOutsideRangeAfter ENDP




;-------------------------------------------------------------------------------------
; Creates string "LABEL_X:"+(CRLF) from dwJmpEntry number X
;-------------------------------------------------------------------------------------
CTALabelFromJmpEntry PROC FRAME qwJmpEntry:QWORD, lpszLabel:QWORD
    LOCAL szValue[16]:BYTE
    .IF lpszLabel != NULL
        Invoke utoa_ex, qwJmpEntry, Addr szValue, 10, FALSE, TRUE
        ;Invoke szCopy, Addr szCRLF, lpszLabel
        Invoke szCopy, Addr szLabel, lpszLabel
        ;Invoke szCatStr, lpszLabel, Addr szLabel
        Invoke szCatStr, lpszLabel, Addr szValue
        Invoke szCatStr, lpszLabel, Addr szColon
        ;Invoke szCatStr, lpszLabel, Addr szCRLF
    .ENDIF
    ret
CTALabelFromJmpEntry ENDP


;-------------------------------------------------------------------------------------
; Creates string for jump xxx instruction "jxxx LABEL_X" from dwJmpEntry number x
;-------------------------------------------------------------------------------------
CTAJmpLabelFromJmpEntry PROC FRAME USES RDI RSI qwJmpEntry:QWORD, qwAddress:QWORD, bOutsideRange:QWORD, lpszJxxx:QWORD, lpszJumpLabel:QWORD
    LOCAL szValue[16]:BYTE
    LOCAL szJmp[16]:BYTE
    
    .IF lpszJxxx != NULL && lpszJumpLabel != NULL
        Invoke utoa_ex, qwJmpEntry, Addr szValue, 10, FALSE, TRUE
        
        lea rdi, szJmp
        mov rsi, lpszJxxx
        
        movzx rax, byte ptr [rsi]
        .WHILE al != 0
            .IF al == " " ; space
                mov byte ptr [rdi], al
                inc rdi
                .BREAK
            .ENDIF
            mov byte ptr [rdi], al
            inc rsi
            inc rdi
            movzx rax, byte ptr [rsi]
        .ENDW
        mov byte ptr [rdi], 0h ; add null to string
        
        Invoke szCopy, Addr szJmp, lpszJumpLabel
        ;Invoke szCatStr, lpszJumpLabel, Addr szJmp
        Invoke szCatStr, lpszJumpLabel, Addr szLabel
        Invoke szCatStr, lpszJumpLabel, Addr szValue
        .IF g_CmntJumpDest == 1
            Invoke szCatStr, lpszJumpLabel, Addr szCmnt
            Invoke szCatStr, lpszJumpLabel, Addr szDestJmp
            Invoke qw2hex, qwAddress, Addr szValueString
            Invoke szCatStr, lpszJumpLabel, Addr szHex
            Invoke szCatStr, lpszJumpLabel, Addr szValueString
        .ENDIF
        .IF bOutsideRange == TRUE
           .IF g_CmntOutsideRange == 1
                .IF g_CmntJumpDest == 1
                    Invoke szCatStr, lpszJumpLabel, Addr szCommentOutsideRange2
                .ELSE
                    Invoke szCatStr, lpszJumpLabel, Addr szCommentOutsideRange
                .ENDIF
            .ENDIF
        .ENDIF
        ;Invoke szCatStr, lpszLabel, Addr szCRLF
    .ENDIF
    ret
CTAJmpLabelFromJmpEntry ENDP



;-------------------------------------------------------------------------------------
; Adjust mnemonic to remove 0x and add h for masm style hex values
;-------------------------------------------------------------------------------------
CTAMnemonicToMasmHex PROC FRAME USES RBX RDI RSI lpszDisasmText:QWORD, lpszFormattedDisasmText:QWORD, bii:QWORD
    LOCAL szMnemToReplace[MAX_MNEMONIC_SIZE]:BYTE
    LOCAL szMnemToReplaceWith[MAX_MNEMONIC_SIZE]:BYTE
    LOCAL szTemp[MAX_MNEMONIC_SIZE]:BYTE
    LOCAL pMnemonic:QWORD
    
    mov rbx, bii
    lea rax, [rbx].BASIC_INSTRUCTION_INFO.memory.mnemonic
    mov pMnemonic, rax
    
    ; remove any *1- or *1+
    Invoke InString, 1, pMnemonic, Addr szMnemStarOnePlus
    .IF sqword ptr rax > 0
        Invoke szRep, pMnemonic, Addr szMnemToReplace, Addr szMnemStarOnePlus, Addr szPlus
    .ELSE
        Invoke InString, 1, pMnemonic, Addr szMnemStarOneMinus
        .IF sqword ptr rax > 0
            Invoke szRep, pMnemonic, Addr szMnemToReplace, Addr szMnemStarOneMinus, Addr szMinus
        .ELSE
            Invoke szCopy, pMnemonic, Addr szMnemToReplace
        .ENDIF
    .ENDIF
    
    ; remove any 0x in string
    Invoke InString, 1, Addr szMnemToReplace, Addr szHex
    .IF sqword ptr rax > 0
        Invoke szRep, szMnemToReplace, Addr szTemp, Addr szHex, Addr szNull
        Invoke szCopy, Addr szTemp, Addr szMnemToReplace
        
        Invoke InString, 1, Addr szMnemToReplace, Addr szHex
        .IF sqword ptr rax > 0
            Invoke szRep, szMnemToReplace, Addr szTemp, Addr szHex, Addr szNull
            Invoke szCopy, Addr szTemp, Addr szMnemToReplace
        .ENDIF
    .ENDIF
    
    Invoke szCopy, Addr szMnemToReplace, Addr szMnemToReplaceWith
    Invoke szCatStr, Addr szMnemToReplaceWith, Addr szMasmHexH    
    
    Invoke szRep, lpszDisasmText, lpszFormattedDisasmText, Addr szMnemToReplace, Addr szMnemToReplaceWith

    ret

CTAMnemonicToMasmHex ENDP


;=====================================================================================
; Strips out the brackets, underscores, full stops and @ symbols from calls: call <winbif._GetModuleHandleA@4> and returns just the api call: GetModuleHandle
; Returns true if succesful and lpszAPIFunction will contain the stripped api function name, otherwise false and lpszAPIFunction will be a null string
;-------------------------------------------------------------------------------------
Strip_x64dbg_calls PROC FRAME USES RDI RSI lpszCallText:QWORD, lpszAPIFunction:QWORD
    
    .IF lpszCallText != 0
        mov rsi, lpszCallText
        mov rdi, lpszAPIFunction
        
        movzx rax, byte ptr [rsi]
        .WHILE al != '.' && al != '&' ; 64bit have & in the api calls, so to check for that as well
            .IF al == 0h ; ended here, maybe have a call eax or call rax type call
                ; go back and look for space instead
                mov rsi, lpszCallText
                mov rdi, lpszAPIFunction
                movzx rax, byte ptr [rsi]
                .WHILE al != ' '
                    .IF al == 0h ; reached end of string and no . and no & and no space now?
                        mov byte ptr [rdi], 0h ;
                        mov rax, FALSE
                        ret
                    .ENDIF
                    inc rsi
                    movzx rax, byte ptr [rsi]
                .ENDW
                .BREAK
            .ENDIF
            inc rsi
            movzx rax, byte ptr [rsi]
        .ENDW
    
        inc rsi ; jump over the . and the first _ if its there
        movzx rax, byte ptr [rsi]
        .IF al == '_'
            inc rsi
        .ENDIF
    
        movzx rax, byte ptr [rsi]
        .WHILE al != '@' && al != '>' && al != 0
    ;        .IF al == 0h
    ;            mov rdi, lpszAPIFunction
    ;            mov byte ptr [rdi], 0h ; null out string
    ;            mov rax, FALSE
    ;            ret
    ;        .ENDIF
            mov byte ptr [rdi], al
            inc rdi
            inc rsi
            movzx rax, byte ptr [rsi]
        .ENDW
        mov byte ptr [rdi], 0h ; null out string
        mov rax, TRUE
    .ELSE
        mov rax, FALSE
    .ENDIF        
    ret

Strip_x64dbg_calls endp


;=====================================================================================
; Strips out the segment text before brackets ss:[], ds:[] etc and any 0x
;-------------------------------------------------------------------------------------
Strip_x64dbg_segments PROC FRAME USES RBX RDI RSI lpszDisasmText:QWORD, lpszFormattedDisamText:QWORD
    
    .IF lpszDisasmText != 0
        mov rsi, lpszDisasmText
        mov rdi, lpszFormattedDisamText
        
        movzx rax, byte ptr [rsi]
        .WHILE al != ':'
            .IF al == 0h
                mov byte ptr [rdi], 0h ; add null to string
                mov rax, FALSE
                ret
    ;        .ELSEIF al == "x"
    ;            dec edi
    ;            dec edi
    ;        .ELSE
    ;            mov byte ptr [edi], al
            .ENDIF
            mov byte ptr [rdi], al
            inc rdi
            inc rsi
            movzx rax, byte ptr [rsi]
        .ENDW
    
        inc rsi ; jump over the :, then skip back before segment text
        dec rdi
        dec rdi
    
        movzx rax, byte ptr [rsi]
        .WHILE al != 0
            .IF g_FormatType == 1
                .IF al == "x"
                    movzx rbx, byte ptr [rsi-1]
                    .IF bl == "0"
                        dec rdi
                        dec rdi
                    .ELSE
                        mov byte ptr [rdi], al
                    .ENDIF
                .ELSE
                    mov byte ptr [rdi], al
                .ENDIF
            .ELSE
                mov byte ptr [rdi], al
            .ENDIF
    ;        mov byte ptr [edi], al
            inc rdi
            inc rsi
            movzx rax, byte ptr [rsi]
        .ENDW
        mov byte ptr [rdi], 0h ; add null to string
    
        mov rax, TRUE
    .ELSE
        mov rax, FALSE
    .ENDIF
    ret

Strip_x64dbg_segments ENDP


;=====================================================================================
; Strips out the angle brackets < >
;-------------------------------------------------------------------------------------
Strip_x64dbg_anglebrackets PROC FRAME USES RDI RSI lpszDisasmText:QWORD, lpszFormattedDisamText:QWORD
    
    .IF lpszDisasmText != 0
        mov rsi, lpszDisasmText
        mov rdi, lpszFormattedDisamText
        
        movzx rax, byte ptr [rsi]
        .WHILE al != 0
            .IF al == '<' || al == '>'
            .ELSE
                mov byte ptr [rdi], al
                inc rdi
            .ENDIF
            inc rsi
            movzx rax, byte ptr [rsi]
        .ENDW
        mov byte ptr [rdi], 0
        mov rax, TRUE
    .ELSE
        mov rax, FALSE
    .ENDIF
    
    ret
Strip_x64dbg_anglebrackets ENDP


;=====================================================================================
; Strips out the module name plus dot if it exists
;-------------------------------------------------------------------------------------
Strip_x64dbg_modulename PROC FRAME lpszDisasmText:QWORD, lpszFormattedDisasmText:QWORD
    .IF lpszDisasmText != 0
        Invoke InString, 1, lpszDisasmText, Addr szModuleNameStrip
        .IF sqword ptr rax > 0
            Invoke szRep, lpszDisasmText, lpszFormattedDisasmText, Addr szModuleNameStrip, Addr szNull
        .ELSE
            Invoke szCopy, lpszDisasmText, lpszFormattedDisasmText
        .ENDIF
        mov rax, TRUE
    .ELSE
        mov rax, FALSE
    .ENDIF
    ret
Strip_x64dbg_modulename ENDP


;-------------------------------------------------------------------------------------
; Adds columns to the Reference View tab in x64dbg for displaying copied code
;-------------------------------------------------------------------------------------
CTA_AddColumnsToRefView PROC FRAME qwStartAddress:QWORD, qwFinishAddress:QWORD
    Invoke szCopy, addr szRefCopyToAsm, Addr szRefHdrMsg
    Invoke szCatStr, Addr szRefHdrMsg, Addr szModuleName
    Invoke szCatStr, Addr szRefHdrMsg, Addr szOffsetLeftBracket
    Invoke szCatStr, Addr szRefHdrMsg, Addr szHex
    Invoke qw2hex, qwStartAddress, Addr szValueString
    Invoke szCatStr, Addr szRefHdrMsg, Addr szValueString
    Invoke szCatStr, Addr szRefHdrMsg, Addr szModBaseHex
    Invoke szCatStr, Addr szRefHdrMsg, Addr szHex
    Invoke qw2hex, qwFinishAddress, Addr szValueString
    Invoke szCatStr, Addr szRefHdrMsg, Addr szValueString    
    Invoke szCatStr, Addr szRefHdrMsg, Addr szRightBracket
    Invoke GuiReferenceInitialize, Addr szRefHdrMsg
    Invoke GuiReferenceAddColumn, 0, Addr szRefAsmCode
    ;Invoke GuiReferenceSetCurrentTaskProgress, 0, Addr szRefCopyToAsmProcess
    Invoke GuiReferenceReloadData
    ret
CTA_AddColumnsToRefView ENDP


;-------------------------------------------------------------------------------------
; Adds a row of information about a code to the Reference View tab in x64dbg
;-------------------------------------------------------------------------------------
CTA_AddRowToRefView PROC FRAME qwCount:QWORD, lpszRowText:QWORD
    mov rax, qwCount
    inc rax
    Invoke GuiReferenceSetRowCount, rax
    Invoke GuiReferenceSetCellContent, qwCount, 0, lpszRowText
    mov rax, TRUE
    ret
CTA_AddRowToRefView ENDP


END DllMain
















