.section rodata
.global _aneSwcData
.align 4

_aneSwcData:
.incbin "ANEBytecodeEditor.swc"

.global _aneSwcSize
.align 4
_aneSwcSize:
.int _aneSwcSize - _aneSwcData
