MUSL_URL=https://github.com/richfelker/musl-cross-make/archive/refs/tags/v0.9.9.tar.gz
MUSL_SHA256=ff3e2188626e4e55eddcefef4ee0aa5a8ffb490e3124850589bcaf4dd60f5f04
F18_LLVM_URL=https://github.com/SomeDevHere/f18-llvm-project/archive/pkg-202112180.tar.gz
F18_LLVM_SHA256=efc3732722bbb0b4d7ccb435d78b5f6db2f0810e3d38c15357fe3944d703cf5c
FLANG_URL=https://github.com/SomeDevHere/flang/archive/pkg-202112100.tar.gz
FLANG_SHA256=c6baad977b8826796ee852da1de6dc63de6ba9b623e8916f867ea4dec669d10f

musl:
	wget $(MUSL_URL) -O musl.tar.gz
	echo "$(MUSL_SHA256) musl.tar.gz" | sha256sum -c
	tar zxf musl.tar.gz
	mv musl-cross-make-0.9.9 musl
	rm musl.tar.gz

f18-llvm-project:
	wget $(F18_LLVM_URL) -O f18.tar.gz
	echo "$(F18_LLVM_SHA256) f18.tar.gz" | sha256sum -c
	tar zxf f18.tar.gz
	mv f18-llvm-project-pkg-202112180 f18-llvm-project
	for pat in patches/*.patch; do \
		patch -p1 < $$pat; \
	done
	rm f18.tar.gz

# for libpgmath
flang:
	wget $(FLANG_URL) -O flang.tar.gz
	echo "$(FLANG_SHA256) flang.tar.gz" | sha256sum -c
	tar zxf flang.tar.gz
	mv flang-pkg-202112100 flang
	rm flang.tar.gz

clean:
	rm -rf musl f18-llvm-project flang f18.tar.gz musl.tar.gz flang.tar.gz
