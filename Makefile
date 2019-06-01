default: all tests

all: parser.rb

tests:
	echo "Dir.glob('./test/*_test.rb').each { |file| require file}" | ruby -Itest

parser.rb: grammar.y
	racc -o parser.rb grammar.y

samples: hello

hello: samples/hello.daisy

samples/hello.daisy: all
	./daisy samples/hello.daisy
