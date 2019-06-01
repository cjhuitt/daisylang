default: all tests

all: parser.rb

tests:
	echo "Dir.glob('./test/*_test.rb').each { |file| require file}" | ruby -Itest

parser.rb: grammar.y
	racc -o parser.rb grammar.y
