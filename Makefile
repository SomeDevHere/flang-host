NPROC := $(shell nproc)
MULTILIB := $(shell rm -f conftest;gcc conftest32.c -m32 -o conftest; ./conftest)

LLVM_CMAKE_ARGS=-DLLVM_ENABLE_PROJECTS='clang;mlir;flang' -DLLVM_TARGETS_TO_BUILD='' -DBUILD_SHARED_LIBS=OFF

all: bin.tar.gz

#Download and verify

f18-llvm-project:
	make -f Extract.inc f18-llvm-project

musl:
	make -f Extract.inc musl

musl/output/bin: musl
	cd musl; \
	make TARGET=i686-linux-musl install

build: f18-llvm-project patch
	mkdir -p build

build/x86_64/bin/flang-new: build
	mkdir -p build/x86_64
	cd build/x86_64; \
	pwd; \
	cmake -G Ninja ../../f18-llvm-project/llvm $(LLVM_CMAKE_ARGS); \
	ninja -j $(NPROC) flang-new

build/x86/bin/flang-new: build
	mkdir -p build/x86
	cd build/x86; \
	cmake -G Ninja ../../f18-llvm-project/llvm $(LLVM_CMAKE_ARGS) \
		-DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS=-m32 \
		-DCMAKE_EXE_LINKER_FLAGS=-m32; \
	ninja -j $(NPROC) flang-new

build/i686/bin/flang-new: build musl/output/bin
	mkdir -p build/i686
	cd build/i686; \
	cmake -G Ninja ../../f18-llvm-project/llvm $(LLVM_CMAKE_ARGS) \
		-DCMAKE_C_FLAGS=-static -DCMAKE_CXX_FLAGS=-static \
		-DCMAKE_EXE_LINKER_FLAGS=-static \
		-DCMAKE_C_COMPILER=$(shell pwd)/musl/output/bin/i686-linux-musl-gcc \
		-DCMAKE_CXX_COMPILER=$(shell pwd)/musl/output/bin/i686-linux-musl-g++ \
		-DCMAKE_ASM_COMPILER=$(shell pwd)/musl/output/bin/i686-linux-musl-gcc; \
	ninja -j $(NPROC) flang-new

bin:
	mkdir -p bin

ifeq ($(MULTILIB), Yes)
bin/32/flang-new: bin build/x86/bin/flang-new
	mkdir -p bin/32
	cp build/x86/bin/flang-new bin/32/flang-new
else
bin/32/flang-new: bin build/i686/bin/flang-new
	mkdir -p bin/32
	cp build/i686/bin/flang-new bin/32/flang-new
endif

bin/64/flang-new: bin build/x86_64/bin/flang-new
	mkdir -p bin/64
	cp build/x86_64/bin/flang-new bin/64/flang-new

bin.tar.gz: bin/64/flang-new bin/32/flang-new
	tar zcf bin.tar.gz bin

clean:
	rm -rf bin build conftest
	if [ -f musl/Makefile ]; then \
		cd musl; \
		make clean; \
	fi

clean-force: clean
	make -f Extract.inc clean

.PHONY: all build32 clean patch clean-force
