OPENFILENAMEW STRUCT
  lStructSize        DWORD      ?
  hwndOwner          DWORD      ?
  hInstance          DWORD      ?
  lpstrFilter        DWORD      ?
  lpstrCustomFilter  DWORD      ?
  nMaxCustFilter     DWORD      ?
  nFilterIndex       DWORD      ?
  lpstrFile          DWORD      ?
  nMaxFile           DWORD      ?
  lpstrFileTitle     DWORD      ?
  nMaxFileTitle      DWORD      ?
  lpstrInitialDir    DWORD      ?
  lpstrTitle         DWORD      ?
  Flags              DWORD      ?
  nFileOffset         WORD      ?
  nFileExtension      WORD      ?
  lpstrDefExt        DWORD      ?
  lCustData          DWORD      ?
  lpfnHook           DWORD      ?
  lpTemplateName     DWORD      ?
OPENFILENAMEW ENDS

OPENFILENAMEA STRUCT
  lStructSize        DWORD      ?
  hwndOwner          DWORD      ?
  hInstance          DWORD      ?
  lpstrFilter        DWORD      ?
  lpstrCustomFilter  DWORD      ?
  nMaxCustFilter     DWORD      ?
  nFilterIndex       DWORD      ?
  lpstrFile          DWORD      ?
  nMaxFile           DWORD      ?
  lpstrFileTitle     DWORD      ?
  nMaxFileTitle      DWORD      ?
  lpstrInitialDir    DWORD      ?
  lpstrTitle         DWORD      ?
  Flags              DWORD      ?
  nFileOffset         WORD      ?
  nFileExtension      WORD      ?
  lpstrDefExt        DWORD      ?
  lCustData          DWORD      ?
  lpfnHook           DWORD      ?
  lpTemplateName     DWORD      ?
OPENFILENAMEA ENDS

IFDEF __UNICODE__
  OPENFILENAME equ <OPENFILENAMEW>
ELSE
  OPENFILENAME equ <OPENFILENAMEA>
ENDIF

GMEM_FIXED                           equ 0h
GMEM_ZEROINIT                        equ 40h
GPTR                                 equ GMEM_FIXED OR GMEM_ZEROINIT
GENERIC_WRITE                        equ 40000000h
FILE_SHARE_WRITE                     equ 2h
CREATE_ALWAYS                        equ 2
FILE_ATTRIBUTE_NORMAL                equ 80h
INVALID_HANDLE_VALUE                 equ -1