CXXFLAGS := -std=c++17

bezel-installer.exe: bezel-installer.o bezel-swf.o
	$(CXX) -static -o bezel-installer.exe bezel-swf.o bezel-installer.o

clean:
	rm bezel-swf.o bezel-installer.o
