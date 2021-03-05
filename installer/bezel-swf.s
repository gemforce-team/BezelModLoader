.section rodata
.global swfData
.align 4

swfData:
.incbin "../obj/BezelModLoader.swf"

.global swfSize
.align 4
swfSize:
.int swfSize - swfData
