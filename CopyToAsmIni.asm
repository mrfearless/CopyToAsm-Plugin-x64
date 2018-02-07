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

IniGetLblUseAddress             PROTO
IniSetLblUseAddress             PROTO :QWORD
IniGetLblUseLabel               PROTO
IniSetLblUseLabel               PROTO :QWORD


.CODE



;**************************************************************************
;
;**************************************************************************
IniGetFormatType PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniFormatType, 1, Addr CopyToAsmIni
    ret
IniGetFormatType ENDP


;**************************************************************************
;
;**************************************************************************
IniSetFormatType PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniFormatType, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniFormatType, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetFormatType ENDP


;**************************************************************************
;
;**************************************************************************
IniGetOutsideRangeLabels PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniOutsideRangeLabels, 1, Addr CopyToAsmIni
    ret
IniGetOutsideRangeLabels ENDP


;**************************************************************************
;
;**************************************************************************
IniSetOutsideRangeLabels PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniOutsideRangeLabels, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniOutsideRangeLabels, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetOutsideRangeLabels ENDP



;**************************************************************************
;
;**************************************************************************
IniGetCmntOutsideRange PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniCmntOutsideRange, 1, Addr CopyToAsmIni
    ret
IniGetCmntOutsideRange ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntOutsideRange PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntOutsideRange, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntOutsideRange, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntOutsideRange ENDP



;**************************************************************************
;
;**************************************************************************
IniGetCmntJumpDest PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniCmntJumpDest, 1, Addr CopyToAsmIni
    ret
IniGetCmntJumpDest ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntJumpDest PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntJumpDest, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntJumpDest, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntJumpDest ENDP


;**************************************************************************
;
;**************************************************************************
IniGetCmntCallDest PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniCmntCallDest, 1, Addr CopyToAsmIni
    ret
IniGetCmntCallDest ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntCallDest PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntCallDest, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntCallDest, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntCallDest ENDP


;**************************************************************************
;
;**************************************************************************
IniGetLblUseAddress PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniLblUseAddress, 1, Addr CopyToAsmIni
    ret
IniGetLblUseAddress ENDP


;**************************************************************************
;
;**************************************************************************
IniSetLblUseAddress PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniLblUseAddress, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniLblUseAddress, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetLblUseAddress ENDP


;**************************************************************************
;
;**************************************************************************
IniGetLblUseLabel PROC FRAME
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniLblUseLabel, 1, Addr CopyToAsmIni
    ret
IniGetLblUseLabel ENDP


;**************************************************************************
;
;**************************************************************************
IniSetLblUseLabel PROC FRAME qwValue:QWORD
    .IF qwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniLblUseLabel, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniLblUseLabel, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetLblUseLabel ENDP






















