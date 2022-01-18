CXXFLAGS := $(CXXFLAGS) -std=c++17 -m32 -g
ASFLAGS  := $(ASFLAGS) --32

splitter.exe: splitter.o
	$(CXX) $(CXXFLAGS) -static -o splitter.exe splitter.o

splitter.o: splitter.cpp

clean:
	rm splitter.o splitter.exe
