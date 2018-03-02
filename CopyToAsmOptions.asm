include ModernUI.inc
includelib ModernUI.lib

include ModernUI_CaptionBar.inc
includelib ModernUI_CaptionBar.lib

include ModernUI_SmartPanel.inc
Includelib ModernUI_SmartPanel.lib

include ModernUI_Button.inc
includelib ModernUI_Button.lib

include ModernUI_Checkbox.inc
includelib ModernUI_Checkbox.lib

OptionsDlgProc               PROTO :HWND, :UINT, :WPARAM, :LPARAM
OptionsPanel0Proc            PROTO :HWND, :UINT, :WPARAM, :LPARAM
OptionsPanel1Proc            PROTO :HWND, :UINT, :WPARAM, :LPARAM
OptionsPanel2Proc            PROTO :HWND, :UINT, :WPARAM, :LPARAM





.CONST
ICO_OPTIONS_LABELS          EQU 130
ICO_OPTIONS_COMMENTS        EQU 131
ICO_OPTIONS_FORMATSTYLE     EQU 132
ICO_OPTIONS_EXIT            EQU 133

; MUI Caption bar images: ICO format
ICO_MUI_MIN                 EQU 140
ICO_MUI_MAX                 EQU 141
ICO_MUI_RES                 EQU 142
ICO_MUI_CLOSE               EQU 143
ICO_MUI_NOCHECKMARK         EQU 144
ICO_MUI_CHECKMARK           EQU 145
ICO_MUI_NOSETRADIO          EQU 146
ICO_MUI_RADIO               EQU 147


; Options Dialog
IDD_OPTIONSDLG              EQU 1000
IDC_CAPTIONBAR              EQU 1001
IDC_SP1                     EQU 1002
IDC_MENUTEXT                EQU 1009
IDC_OPTIONSMENUITEM0        EQU 1010
IDC_OPTIONSMENUITEM1        EQU 1011
IDC_OPTIONSMENUITEM2        EQU 1012
IDC_OPTIONSMENUITEM3        EQU 1013
IDC_OPTIONSMENUITEM4        EQU 1014
IDC_OPTIONSMENUITEM5        EQU 1015

;OptionsPanel0.dlg
IDD_OptionsPanel0			EQU 1500
IDC_CHECKBOX1               EQU 1501
IDC_CHECKBOX2               EQU 1502
IDC_CHECKBOX3               EQU 1503
IDC_CHECKBOX4               EQU 1504

;OptionsPanel1.dlg
IDD_OptionsPanel1			EQU 1600
IDC_CHECKBOX5               EQU 1601
IDC_CHECKBOX6               EQU 1602
IDC_CHECKBOX7               EQU 1603

;OptionsPanel2.dlg
IDD_OptionsPanel2			EQU 1700
IDC_RADIO1                  EQU 1701
IDC_RADIO2                  EQU 1702
IDC_INFOFORMATSTYLE			EQU 1710




.DATA
;---------------------------
; Options Dialog
;---------------------------
szOptionsDlgTitle           DB "CopyToAsm Options",0
szOptionsMenu0Text          DB 'Label Options',0
szOptionsMenu1Text          DB 'Comments Options',0
szOptionsMenu2Text          DB 'Format Style Options',0
szOptionsMenu3Text          DB 'Exit',0
szOptionsMenu4Text          DB ' ',0
szOptionsMenu5Text          DB ' ',0
szCheckbox1Text             DB 'Label name uses destination address',0
szCheckbox2Text             DB "Label name prepended with 'LABEL_'",0
szCheckbox3Text             DB 'Outside range labels for jumps/calls',0
szCheckbox4Text             DB 'Use x64dbg labels when present',0
szCheckbox5Text             DB 'Jumps with destination address',0
szCheckbox6Text             DB 'Internal calls with destination address',0
szCheckbox7Text             DB 'Destination addresses outside range',0
szCheckbox8Text             DB ' ',0
szCheckbox9Text             DB ' ',0
szRadio1Text                DB 'C Style - Prefix hex values with 0x',0
szRadio2Text                DB "MASM Style - Append hex values with 'h'",0                
szFormatStyle               DB "Hex value format style: ",0




.DATA?
hPreMenuBtn                 DQ ?
hOptionsMenu0               DQ ?
hOptionsMenu1               DQ ?
hOptionsMenu2               DQ ?
hOptionsMenu3               DQ ?
hOptionsMenu4               DQ ?
hOptionsMenu5               DQ ?
hCaptionBar                 DQ ?
hCurrentPanel               DQ ?
hSP1                        DQ ?
hOptionsPanel0              DQ ?
hOptionsPanel1              DQ ?
hOptionsPanel2              DQ ?
hOptionsPanel3              DQ ?
hChk1                       DQ ?
hChk2                       DQ ?
hChk3                       DQ ?
hChk4                       DQ ?
hChk5                       DQ ?
hChk6                       DQ ?
hChk7                       DQ ?
hChk8                       DQ ?
hChk9                       DQ ?
hRadio1                     DQ ?
hRadio2                     DQ ?
hBtnFormatStyle             DQ ?
hMenuText                   DQ ?





.CODE


;=====================================================================================
; Options Dialog Procedure
;-------------------------------------------------------------------------------------
OptionsDlgProc PROC FRAME hWin:HWND,iMsg:UINT,wParam:WPARAM, lParam:LPARAM

    mov eax, iMsg
    .IF eax == WM_INITDIALOG
        
        Invoke GetDlgItem, hWin, IDC_MENUTEXT
        mov hMenuText, rax
        Invoke SetWindowText, hMenuText, Addr szOptionsMenu0Text
        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_CaptionBar & ModernUI style dialog
        ;-----------------------------------------------------------------------------------------------------    
		Invoke MUIApplyToDialog, hWin, FALSE
		
		; Create CaptionBar control and save handle
		Invoke MUICaptionBarCreate, hWin, Addr szOptionsDlgTitle, 26, IDC_CAPTIONBAR, MUICS_WINNODROPSHADOW + MUICS_NOMAXBUTTON + MUICS_NOMINBUTTON + MUICS_LEFT ;or MUICS_REDCLOSEBUTTON
		mov hCaptionBar, rax

		; Set some properties for our CaptionBar control 
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(27,161,226)
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(61,61,61)
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(87,193,244)	

        ;-----------------------------------------------------------------------------------------------------
		; Create ModernUI_Button controls for our menu items
		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu5Text, 1, 27, 220, 43, IDC_OPTIONSMENUITEM5, MUIBS_LEFT ;+ MUIBS_HAND
		mov hPreMenuBtn, rax
        Invoke MUIButtonSetAllProperties, hPreMenuBtn, Addr MUI_MENUITEM_DARK_THEME_BLANK_2, SIZEOF MUI_BUTTON_PROPERTIES		
		
		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu0Text, 1, 70, 220, 45, IDC_OPTIONSMENUITEM0, MUIBS_LEFT ;+ MUIBS_HAND
		mov hOptionsMenu0, rax
		Invoke MUIButtonSetProperty, hOptionsMenu0, @ButtonDllInstance, hInstance
		Invoke MUIButtonLoadImages, hOptionsMenu0, MUIBIT_ICO, ICO_OPTIONS_LABELS, ICO_OPTIONS_LABELS, ICO_OPTIONS_LABELS, ICO_OPTIONS_LABELS, ICO_OPTIONS_LABELS
		Invoke MUIButtonSetAllProperties, hOptionsMenu0, Addr MUI_MENUITEM_DARK_THEME_2, SIZEOF MUI_BUTTON_PROPERTIES
		
		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu1Text, 1, 115, 220, 45, IDC_OPTIONSMENUITEM1, MUIBS_LEFT + MUIBS_HAND
		mov hOptionsMenu1, rax
		Invoke MUIButtonSetProperty, hOptionsMenu1, @ButtonDllInstance, hInstance
		Invoke MUIButtonLoadImages, hOptionsMenu1, MUIBIT_ICO, ICO_OPTIONS_COMMENTS, ICO_OPTIONS_COMMENTS, ICO_OPTIONS_COMMENTS, ICO_OPTIONS_COMMENTS, ICO_OPTIONS_COMMENTS
		Invoke MUIButtonSetAllProperties, hOptionsMenu1, Addr MUI_MENUITEM_DARK_THEME_2, SIZEOF MUI_BUTTON_PROPERTIES

		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu2Text, 1, 160, 220, 45, IDC_OPTIONSMENUITEM2, MUIBS_LEFT + MUIBS_HAND
		mov hOptionsMenu2, rax
		Invoke MUIButtonSetProperty, hOptionsMenu2, @ButtonDllInstance, hInstance
		Invoke MUIButtonLoadImages, hOptionsMenu2, MUIBIT_ICO, ICO_OPTIONS_FORMATSTYLE, ICO_OPTIONS_FORMATSTYLE, ICO_OPTIONS_FORMATSTYLE, ICO_OPTIONS_FORMATSTYLE, ICO_OPTIONS_FORMATSTYLE
        Invoke MUIButtonSetAllProperties, hOptionsMenu2, Addr MUI_MENUITEM_DARK_THEME_2, SIZEOF MUI_BUTTON_PROPERTIES

		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu3Text, 1, 205, 220, 45, IDC_OPTIONSMENUITEM3, MUIBS_LEFT + MUIBS_HAND
		mov hOptionsMenu3, rax
		Invoke MUIButtonSetProperty, hOptionsMenu3, @ButtonDllInstance, hInstance
		Invoke MUIButtonLoadImages, hOptionsMenu3, MUIBIT_ICO, ICO_OPTIONS_EXIT, ICO_OPTIONS_EXIT, ICO_OPTIONS_EXIT, ICO_OPTIONS_EXIT, ICO_OPTIONS_EXIT
        Invoke MUIButtonSetAllProperties, hOptionsMenu3, Addr MUI_MENUITEM_DARK_THEME_2, SIZEOF MUI_BUTTON_PROPERTIES

		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu4Text, 1, 250, 220, 45, IDC_OPTIONSMENUITEM4, MUIBS_LEFT ;+ MUIBS_HAND
		mov hOptionsMenu4, rax
        Invoke MUIButtonSetAllProperties, hOptionsMenu4, Addr MUI_MENUITEM_DARK_THEME_BLANK_2, SIZEOF MUI_BUTTON_PROPERTIES

        
        Invoke MUIButtonSetState, hOptionsMenu0, TRUE
        
    	; smart panel container
    	Invoke MUISmartPanelCreate, hWin, 221, 70, 387, 215, IDC_SP1, MUISPS_NORMAL ;327
    	mov hSP1, rax
    	
    	Invoke MUISmartPanelSetProperty, hSP1, @SmartPanelDllInstance, hInstance
    	;Invoke SmartPanelSetIsDlgMsgVar, hSP1, Addr hCurrentPanel
    	Invoke MUISmartPanelRegisterPanel, hSP1, IDD_OptionsPanel0, Addr OptionsPanel0Proc
    	mov hOptionsPanel0, rax
    	Invoke MUISmartPanelRegisterPanel, hSP1, IDD_OptionsPanel1, Addr OptionsPanel1Proc
    	mov hOptionsPanel1, rax
    	Invoke MUISmartPanelRegisterPanel, hSP1, IDD_OptionsPanel2, Addr OptionsPanel2Proc
    	mov hOptionsPanel2, rax
    	Invoke MUISmartPanelSetCurrentPanel, hSP1, 0, FALSE
    	;Invoke SendMessage, hSP1, MUISPM_SETCURRENTPANEL, 0, FALSE    
        

        
	;---------------------------------------------------------------------------------------------------------------
	; Handle painting of our dialog with our specified background and border color to mimic new Modern style UI feel
	;---------------------------------------------------------------------------------------------------------------
    .ELSEIF eax == WM_ERASEBKGND
        mov rax, 1
        ret

	.ELSEIF eax == WM_PAINT
		invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(240,240,240), MUI_RGBCOLOR(51,51,51) ;MUI_RGBCOLOR(27,161,226) 240,240,240
		mov rax, 0
		ret
    ;---------------------------------------------------------------------------------------------------------------


	.ELSEIF eax == WM_CLOSE
        Invoke EndDialog, hWin, NULL
        
	.ELSEIF eax == WM_COMMAND
        mov rax, wParam
        and rax, 0FFFFh
        .IF rax == IDC_OPTIONSMENUITEM0
	        Invoke MUIButtonSetState, hOptionsMenu0, TRUE
	        Invoke MUIButtonSetState, hOptionsMenu1, FALSE
	        Invoke MUIButtonSetState, hOptionsMenu2, FALSE
	        Invoke MUISmartPanelSetCurrentPanel, hSP1, 0, TRUE
	        Invoke SetWindowText, hMenuText, Addr szOptionsMenu0Text
	        
	    .ELSEIF rax == IDC_OPTIONSMENUITEM1
	        Invoke MUIButtonSetState, hOptionsMenu0, FALSE
	        Invoke MUIButtonSetState, hOptionsMenu1, TRUE
	        Invoke MUIButtonSetState, hOptionsMenu2, FALSE
	        Invoke MUISmartPanelSetCurrentPanel, hSP1, 1, TRUE
	        Invoke SetWindowText, hMenuText, Addr szOptionsMenu1Text
	    
	    .ELSEIF rax == IDC_OPTIONSMENUITEM2
	        Invoke MUIButtonSetState, hOptionsMenu0, FALSE
	        Invoke MUIButtonSetState, hOptionsMenu1, FALSE
	        Invoke MUIButtonSetState, hOptionsMenu2, TRUE
	        Invoke MUISmartPanelSetCurrentPanel, hSP1, 2, TRUE
	        Invoke SetWindowText, hMenuText, Addr szOptionsMenu2Text

        .ELSEIF rax == IDC_OPTIONSMENUITEM3
            Invoke SendMessage, hWin, WM_CLOSE, NULL, NULL

        .ENDIF
    .ELSE
        mov rax, FALSE
        ret
	.ENDIF
    mov rax, TRUE
    ret
OptionsDlgProc ENDP


;------------------------------------------------------------------------------
; OptionsPanel0Proc 
;------------------------------------------------------------------------------
OptionsPanel0Proc PROC FRAME hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	mov eax, uMsg
	.IF eax == WM_INITDIALOG
        IFDEF DEBUG32
        ;PrintText 'OptionsPanel1PROC FRAME:WM_INITDIALOG'
        ENDIF

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox1Text, 20, 11, 350, 24, IDC_CHECKBOX1, MUICS_HAND
        mov hChk1, rax
        Invoke MUICheckboxSetProperty, hChk1, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk1, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox2Text, 20, 48, 350, 24, IDC_CHECKBOX2, MUICS_HAND
        mov hChk2, rax
        Invoke MUICheckboxSetProperty, hChk2, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk2, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox3Text, 20, 85, 350, 24, IDC_CHECKBOX3, MUICS_HAND
        mov hChk3, rax
        Invoke MUICheckboxSetProperty, hChk3, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk3, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox4Text, 20, 122, 350, 24, IDC_CHECKBOX4, MUICS_HAND
        mov hChk4, rax
        Invoke MUICheckboxSetProperty, hChk4, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk4, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK


        .IF g_LblUseAddress == 1
            Invoke MUICheckboxSetState, hChk1, TRUE
        .ENDIF
        .IF g_LblUseLabel == 1
            Invoke MUICheckboxSetState, hChk2, TRUE
        .ENDIF
        .IF g_OutsideRangeLabels == 1
            Invoke MUICheckboxSetState, hChk3, TRUE
        .ENDIF
        .IF g_LblUsex64dbgLabels == 1
            Invoke MUICheckboxSetState, hChk4, TRUE
        .ENDIF      

	.ELSEIF eax == WM_COMMAND
		mov	rax,wParam
		and	rax,0FFFFh
        .IF rax == IDC_CHECKBOX1
            Invoke MUICheckboxGetState, hChk1
            .IF rax == TRUE
                mov g_LblUseAddress, 1
                Invoke IniSetLblUseAddress, 1
            .ELSE
                mov g_LblUseAddress, 0
                Invoke IniSetLblUseAddress, 0
            .ENDIF

        .ELSEIF rax == IDC_CHECKBOX2
            Invoke MUICheckboxGetState, hChk2
            .IF rax == TRUE
                mov g_LblUseLabel, 1
                Invoke IniSetLblUseLabel, 1
            .ELSE
                mov g_LblUseLabel, 0
                Invoke IniSetLblUseLabel, 0
            .ENDIF

        .ELSEIF rax == IDC_CHECKBOX3
            Invoke MUICheckboxGetState, hChk3
            .IF rax == TRUE
                mov g_OutsideRangeLabels, 1
                Invoke IniSetOutsideRangeLabels, 1
            .ELSE
                mov g_OutsideRangeLabels, 0
                Invoke IniSetOutsideRangeLabels, 0
            .ENDIF
            
        .ELSEIF rax == IDC_CHECKBOX4
            Invoke MUICheckboxGetState, hChk4
            .IF rax == TRUE
                mov g_LblUsex64dbgLabels, 1
                Invoke IniSetLblUsex64dbgLabels, 1
            .ELSE
                mov g_LblUsex64dbgLabels, 0
                Invoke IniSetLblUsex64dbgLabels, 0
            .ENDIF
        .ENDIF


    .ELSEIF eax == WM_ERASEBKGND
        mov rax, 1
        ret

	.ELSEIF eax == WM_PAINT
		invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(240,240,240), 0
		
	.ELSEIF eax == WM_CLOSE
	    invoke DestroyWindow, hWin
	.ELSE
      	mov rax,FALSE
		ret
	.ENDIF
	mov  rax,TRUE
	ret

OptionsPanel0Proc ENDP


;------------------------------------------------------------------------------
; OptionsPanel1Proc
;------------------------------------------------------------------------------
OptionsPanel1Proc PROC FRAME hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	mov eax, uMsg
	.IF eax == WM_INITDIALOG
        Invoke MUICheckboxCreate, hWin, Addr szCheckbox5Text, 20, 11, 350, 24, IDC_CHECKBOX5, MUICS_HAND
        mov hChk5, rax
        Invoke MUICheckboxSetProperty, hChk5, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk5, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox6Text, 20, 48, 350, 24, IDC_CHECKBOX6, MUICS_HAND
        mov hChk6, rax
        Invoke MUICheckboxSetProperty, hChk6, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk6, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox7Text, 20, 85, 350, 24, IDC_CHECKBOX7, MUICS_HAND
        mov hChk7, rax
        Invoke MUICheckboxSetProperty, hChk7, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk7, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        .IF g_CmntJumpDest == 1
            Invoke MUICheckboxSetState, hChk5, TRUE
        .ENDIF
        .IF g_CmntCallDest == 1
            Invoke MUICheckboxSetState, hChk6, TRUE
        .ENDIF
        .IF g_CmntOutsideRange == 1
            Invoke MUICheckboxSetState, hChk7, TRUE
        .ENDIF

	.ELSEIF eax == WM_COMMAND
		mov	rax,wParam
		and	rax,0FFFFh
        .IF rax == IDC_CHECKBOX5
            Invoke MUICheckboxGetState, hChk5
            .IF rax == TRUE
                mov g_CmntJumpDest, 1
                Invoke IniSetCmntJumpDest, 1
            .ELSE
                mov g_CmntJumpDest, 0
                Invoke IniSetCmntJumpDest, 0
            .ENDIF
            ;Invoke CS_GenExampleFilename, g_ImageType
            ;Invoke SetWindowText, hBtnFileGen, Addr CODESHOT_EXAMPLEFILE            

        .ELSEIF rax == IDC_CHECKBOX6
            Invoke MUICheckboxGetState, hChk6
            .IF rax == TRUE
                mov g_CmntCallDest, 1
                Invoke IniSetCmntCallDest, 1
            .ELSE
                mov g_CmntCallDest, 0
                Invoke IniSetCmntCallDest, 0
            .ENDIF
            ;Invoke CS_GenExampleFilename, g_ImageType
            ;Invoke SetWindowText, hBtnFileGen, Addr CODESHOT_EXAMPLEFILE              

        .ELSEIF rax == IDC_CHECKBOX7
            Invoke MUICheckboxGetState, hChk7
            .IF rax == TRUE
                mov g_CmntOutsideRange, 1
                Invoke IniSetCmntOutsideRange, 1
            .ELSE
                mov g_CmntOutsideRange, 0
                Invoke IniSetCmntOutsideRange, 0
            .ENDIF
            ;Invoke CS_GenExampleFilename, g_ImageType
            ;Invoke SetWindowText, hBtnFileGen, Addr CODESHOT_EXAMPLEFILE  

        .ENDIF

    .ELSEIF eax == WM_ERASEBKGND
        mov rax, 1
        ret

	.ELSEIF eax == WM_PAINT
		invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(240,240,240), 0
		
	.ELSEIF eax == WM_CLOSE
	    invoke DestroyWindow, hWin
	.ELSE
      	mov rax,FALSE
		ret
	.ENDIF
	mov rax,TRUE
	ret

OptionsPanel1Proc ENDP


;------------------------------------------------------------------------------
; OptionsPanel2Proc 
;------------------------------------------------------------------------------
OptionsPanel2Proc PROC FRAME hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	mov eax, uMsg
	.IF eax == WM_INITDIALOG

        Invoke MUIButtonCreate, hWin, Addr szFormatStyle, 20, 11, 350, 24, IDC_INFOFORMATSTYLE, MUIBS_LEFT
        mov hBtnFormatStyle, rax
        Invoke MUIButtonSetProperty, hBtnFormatStyle, @ButtonTextColor, MUI_RGBCOLOR(51,51,51)
        Invoke MUIButtonSetProperty, hBtnFormatStyle, @ButtonTextColorAlt, MUI_RGBCOLOR(51,51,51)
        Invoke MUIButtonSetProperty, hBtnFormatStyle, @ButtonBackColor, MUI_RGBCOLOR(240,240,240)
        Invoke MUIButtonSetProperty, hBtnFormatStyle, @ButtonBackColorAlt, MUI_RGBCOLOR(240,240,240)
        Invoke MUIButtonSetProperty, hBtnFormatStyle, @ButtonBorderStyle, MUIBBS_NONE
        
        Invoke MUICheckboxCreate, hWin, Addr szRadio1Text, 20, 48, 350, 24, IDC_RADIO1, MUICS_HAND
        mov hRadio1, rax
        Invoke MUICheckboxSetProperty, hRadio1, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hRadio1, MUICIT_ICO, ICO_MUI_NOSETRADIO, ICO_MUI_NOSETRADIO, ICO_MUI_RADIO, ICO_MUI_RADIO, ICO_MUI_RADIO, ICO_MUI_RADIO

        Invoke MUICheckboxCreate, hWin, Addr szRadio2Text, 20, 85, 350, 24, IDC_RADIO2, MUICS_HAND
        mov hRadio2, rax
        Invoke MUICheckboxSetProperty, hRadio2, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hRadio2, MUICIT_ICO, ICO_MUI_NOSETRADIO, ICO_MUI_NOSETRADIO, ICO_MUI_RADIO, ICO_MUI_RADIO, ICO_MUI_RADIO, ICO_MUI_RADIO

        mov rax, g_FormatType
        .IF rax == 0
            Invoke MUICheckboxSetState, hRadio1, TRUE
            Invoke MUICheckboxSetState, hRadio2, FALSE
        .ELSEIF rax == 1
            Invoke MUICheckboxSetState, hRadio1, FALSE
            Invoke MUICheckboxSetState, hRadio2, TRUE
        .ENDIF

	.ELSEIF eax == WM_COMMAND
		mov	rax,wParam
		and	rax,0FFFFh
        .IF rax == IDC_RADIO1
            Invoke MUICheckboxSetState, hRadio1, TRUE
            Invoke MUICheckboxSetState, hRadio2, FALSE
            mov g_FormatType, 0
            Invoke IniSetFormatType, 0

        .ELSEIF rax == IDC_RADIO2
            Invoke MUICheckboxSetState, hRadio1, FALSE
            Invoke MUICheckboxSetState, hRadio2, TRUE
            mov g_FormatType, 1
            Invoke IniSetFormatType, 1

        .ENDIF


    .ELSEIF eax == WM_ERASEBKGND
        mov rax, 1
        ret

	.ELSEIF eax == WM_PAINT
		invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(240,240,240), 0
		
	.ELSEIF eax == WM_CLOSE
	    invoke DestroyWindow, hWin
	.ELSE
      	mov rax,FALSE
		ret
	.ENDIF
	mov rax,TRUE
	ret

OptionsPanel2Proc ENDP

























