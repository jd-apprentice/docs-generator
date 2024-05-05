out_file ?= my-docs
route ?= ./lib
args ?= --help

run: build execute

install: build move

clean:
	rm mkdocs.yml
	rm -rf .github
	rm -rf docs

build: $(route)/$(out_file).zig
	zig build-exe $(route)/$(out_file).zig -fstrip -fsingle-threaded -target x86_64-linux -O ReleaseSafe
	mv $(out_file) $(route)
	rm $(out_file).o

execute: $(route)/$(out_file)
	my-docs $(args)

move:
	sudo mv $(route)/$(out_file) /usr/local/bin