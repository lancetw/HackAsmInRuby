all:
	ruby main.rb ./test/*.asm

clean:
	rm -rf ./test/*.hack
