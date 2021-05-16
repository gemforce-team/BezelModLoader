.section rodata
.global _swcData
.align 4

_swcData:
.incbin "../obj/BezelModLoader.swc"

.global _swcSize
.align 4
_swcSize:
.int _swcSize - _swcData
