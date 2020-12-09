CXXFLAGS := $(CXXFLAGS) -std=c++17 -m32
ASFLAGS  := $(ASFLAGS) --32

bezel-installer.exe: bezel-installer.o bezel-swf.o
	$(CXX) $(CXXFLAGS) -static -o bezel-installer.exe bezel-swf.o bezel-installer.o

bezel-installer.o: bezel-installer.cpp
bezel-swf.o: bezel-swf.s ../obj/BezelModLoader.swf

clean:
	rm bezel-swf.o bezel-installer.o bezel-installer.exe
