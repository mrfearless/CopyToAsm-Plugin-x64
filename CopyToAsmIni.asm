includelib advapi32.lib

IniGetFormatType                PROTO
IniSetFormatType                PROTO :QWORD

IniGetOutsideRangeLabels        PROTO
IniSetOutsideRangeLabels        PROTO :QWORD
IniGetCmntOutsideRange          PROTO
IniSetCmntOutsideRange          PROTO :QWORD
IniGetCmntJumpDest              PROTO
IniSetCmntJumpDest              PROTO :QWORD
IniGetCmntCallDest              PROTO
IniSetCmntCallDest              PROTO :QWORD

.CODE



;**************************************************************************
;
;**************************************************************************
IniGetFormatType PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szFormatType, 1, Addr CopyToAsmIni
    ret
IniGetFormatType ENDP


;**************************************************************************
;
;**************************************************************************
IniSetFormatType PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szFormatType, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szFormatType, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetFormatType ENDP


;**************************************************************************
;
;**************************************************************************
IniGetOutsideRangeLabels PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szOutsideRangeLabels, 1, Addr CopyToAsmIni
    ret
IniGetOutsideRangeLabels ENDP


;**************************************************************************
;
;**************************************************************************
IniSetOutsideRangeLabels PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szOutsideRangeLabels, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szOutsideRangeLabels, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetOutsideRangeLabels ENDP



;**************************************************************************
;
;**************************************************************************
IniGetCmntOutsideRange PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szCmntOutsideRange, 1, Addr CopyToAsmIni
    ret
IniGetCmntOutsideRange ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntOutsideRange PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntOutsideRange, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntOutsideRange, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntOutsideRange ENDP



;**************************************************************************
;
;**************************************************************************
IniGetCmntJumpDest PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szCmntJumpDest, 1, Addr CopyToAsmIni
    ret
IniGetCmntJumpDest ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntJumpDest PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntJumpDest, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntJumpDest, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntJumpDest ENDP


;**************************************************************************
;
;**************************************************************************
IniGetCmntCallDest PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szCmntCallDest, 1, Addr CopyToAsmIni
    ret
IniGetCmntCallDest ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntCallDest PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntCallDest, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntCallDest, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntCallDest ENDP



