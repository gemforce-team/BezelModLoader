CXXFLAGS := $(CXXFLAGS) -std=c++17 -m32
ASFLAGS  := $(ASFLAGS) --32

bezel-installer.exe: bezel-installer.o bezel-swf.o bezel-swc.o gccs-loader.o gcfw-loader.o
	$(CXX) $(CXXFLAGS) -static -o bezel-installer.exe bezel-installer.o bezel-swf.o bezel-swc.o gccs-loader.o gcfw-loader.o

bezel-installer.o: bezel-installer.cpp
bezel-swf.o: bezel-swf.s ../obj/BezelModLoader.swf
bezel-swc.o: bezel-swc.s ../obj/BezelModLoader.swc
gccs-loader.o: gccs-loader.s ../obj/GCCSMainLoader.swf
gcfw-loader.o: gcfw-loader.s ../obj/GCFWMainLoader.swf

clean:
	rm bezel-swf.o bezel-swc.o gccs-loader.o gcfw-loader.o bezel-installer.o bezel-installer.exe
