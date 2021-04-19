CXXFLAGS := $(CXXFLAGS) -std=c++17 -m32
ASFLAGS  := $(ASFLAGS) --32

bezel-installer.exe: bezel-installer.o bezel-swf.o bezel-swc.o
	$(CXX) $(CXXFLAGS) -static -o bezel-installer.exe bezel-installer.o bezel-swf.o bezel-swc.o

bezel-installer.o: bezel-installer.cpp
bezel-swf.o: bezel-swf.s ../obj/BezelModLoader.swf
bezel-swc.o: bezel-swc.s ../obj/BezelModLoader.swc

clean:
	rm bezel-swf.o bezel-installer.o bezel-installer.exe
