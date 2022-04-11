CXXFLAGS := $(CXXFLAGS) -DZIP_STATIC -std=c++17 -m32 `pkg-config --cflags libzip`
ASFLAGS  := $(ASFLAGS) --32

bezel-installer.exe: bezel-installer.o bezel-swf.o bezel-swc.o gccs-loader.o gcfw-loader.o ane.o aneSWC.o
	$(CXX) $(CXXFLAGS) -static -o bezel-installer.exe bezel-installer.o bezel-swf.o bezel-swc.o gccs-loader.o gcfw-loader.o ane.o aneSWC.o `pkg-config --libs --static libzip` 

bezel-installer.o: bezel-installer.cpp
bezel-swf.o: bezel-swf.s ../obj/BezelModLoader.swf
bezel-swc.o: bezel-swc.s ../obj/BezelModLoader.swc
gccs-loader.o: gccs-loader.s ../obj/GCCSMainLoader.swf
gcfw-loader.o: gcfw-loader.s ../obj/GCFWMainLoader.swf
ane.o: ane.s ANEBytecodeEditor.ane
aneSWC.o: aneSWC.s ANEBytecodeEditor.swc

clean:
	rm bezel-swf.o bezel-swc.o gccs-loader.o gcfw-loader.o bezel-installer.o ane.o bezel-installer.exe
