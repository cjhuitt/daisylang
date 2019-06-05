default: all

all: daisy tests hello

daisy: parser.rb

tests: parser.rb
	echo "Dir.glob('./test/*_test.rb').each { |file| require file}" | ruby -Itest

check: tests

parser.rb: grammar.y
	racc -g -o parser.rb grammar.y

samples: calc fibo hello mirror printing truthy

hello: daisy samples/hello.daisy
	./daisy samples/hello.daisy

calc: daisy samples/calc.daisy
	./daisy samples/calc.daisy

fibo: daisy samples/fibo.daisy
	./daisy samples/fibo.daisy

truthy: daisy samples/truthy.daisy
	./daisy samples/truthy.daisy

mirror: daisy samples/mirror.daisy
	./daisy samples/mirror.daisy

printing: daisy samples/printing.daisy
	./daisy samples/printing.daisy

