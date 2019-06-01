default: all tests

all: parser.rb

tests:
	echo "Dir.glob('./test/*_test.rb').each { |file| require file}" | ruby -Itest

parser.rb: grammar.y
	racc -o parser.rb grammar.y

samples: hello calc

hello: samples/hello.daisy

calc: samples/calc.daisy

samples/hello.daisy: all
	./daisy samples/hello.daisy

samples/calc.daisy: all
	./daisy samples/calc.daisy
