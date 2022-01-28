.section rodata
.global _gcfwLoaderData
.align 4

_gcfwLoaderData:
.incbin "../obj/GCFWMainLoader.swf"

.global _gcfwLoaderSize
.align 4
_gcfwLoaderSize:
.int _gcfwLoaderSize - _gcfwLoaderData
