out_file ?= my-docs
route ?= ./lib

run: build execute

clean:
	rm mkdocs.yml
	rm -rf .github
	rm -rf docs

build: $(route)/$(out_file).zig
	zig build-exe $(route)/$(out_file).zig -fstrip -fsingle-threaded -target x86_64-linux -O ReleaseSafe
	mv $(out_file) $(route)
	rm $(out_file).o

execute: $(route)/$(out_file)
	./$(route)/$(out_file) $(args)