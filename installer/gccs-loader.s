.section rodata
.global _gccsLoaderData
.align 4

_gccsLoaderData:
.incbin "../obj/GCCSMainLoader.swf"

.global _gccsLoaderSize
.align 4
_gccsLoaderSize:
.int _gccsLoaderSize - _gccsLoaderData
