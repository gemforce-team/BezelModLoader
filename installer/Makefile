CXXFLAGS := $(CXXFLAGS) -std=c++17 -m32 -O3 -flto
ASFLAGS  := $(ASFLAGS) --32
LDFLAGS  := $(LDFLAGS) -s

bezel-installer.exe: bezel-installer.o bezel-swf.o bezel-swc.o
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -static -o bezel-installer.exe bezel-installer.o bezel-swf.o bezel-swc.o

bezel-installer.o: bezel-installer.cpp
bezel-swf.o: bezel-swf.s ../obj/BezelModLoader.swf
bezel-swc.o: bezel-swc.s ../obj/BezelModLoader.swc

clean:
	rm bezel-swf.o bezel-swc.o bezel-installer.o bezel-installer.exe
