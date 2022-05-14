CFLAGS = -shared -fPIC -llua
CC = gcc
TARGET := libflypy.so

all: build/$(TARGET)

build/$(TARGET): build_dict/libflypy.c 
	cd build_dict && lua trans.lua > mydict.h && $(CC) $(CFLAGS) libflypy.c -o ../lua/$(TARGET)

clean:
	rm -f lua/$(TARGET) build_dict/mydict.h
