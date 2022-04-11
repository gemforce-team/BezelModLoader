.section rodata
.global _aneData
.align 4

_aneData:
.incbin "ANEBytecodeEditor.ane"

.global _aneSize
.align 4
_aneSize:
.int _aneSize - _aneData
