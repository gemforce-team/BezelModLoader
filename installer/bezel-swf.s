.section rodata
.global _swfData
.align 4

_swfData:
.incbin "../obj/BezelModLoader.swf"

.global _swfSize
.align 4
_swfSize:
.int _swfSize - _swfData
