default: all

all: daisy tests hello

daisy: parser.rb

tests: parser.rb
	echo "Dir.glob('./test/*_test.rb').each { |file| require file}" | ruby -Itest

parser: parser.rb test/parser_test.rb
	ruby -Itest test/parser_test.rb

lexer: lexer.rb test/lexer_test.rb
	ruby -Itest test/lexer_test.rb

interpreter: runtime/interpreter.rb test/interpreter_test.rb
	ruby -Itest test/interpreter_test.rb

check: tests

parser.rb: grammar.y
	racc -g -o parser.rb grammar.y

samples: arrays calc classical fibo hello lights mirror printing truthy

arrays: daisy samples/arrays.daisy
	./daisy samples/arrays.daisy

calc: daisy samples/calc.daisy
	./daisy samples/calc.daisy

classical: daisy samples/classical.daisy
	./daisy samples/classical.daisy

fibo: daisy samples/fibo.daisy
	./daisy samples/fibo.daisy

hello: daisy samples/hello.daisy
	./daisy samples/hello.daisy

lights: daisy samples/lights.daisy
	./daisy samples/lights.daisy

mirror: daisy samples/mirror.daisy
	./daisy samples/mirror.daisy

printing: daisy samples/printing.daisy
	./daisy samples/printing.daisy

truthy: daisy samples/truthy.daisy
	./daisy samples/truthy.daisy

