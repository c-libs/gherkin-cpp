.PHONY: test

CXXFLAGS:=-std=c++11 -I include -I libs/gherkin-c/include -I libs/gherkin-c/src -I libs/fmem/build/gen

all: gherkin-c fmem
	$(CXX) $(CXXFLAGS) -c src/parser.cpp -o p.o
	$(CXX) $(CXXFLAGS) -c src/compiler.cpp -o c.o
	ar x libs/gherkin-c/libs/libgherkin.a
	ar x libs/fmem/build/libfmem.a
	ar rvs libgherkin-cpp.a *.o
	$(CXX) $(CXXFLAGS)-fPIC -shared -o libgherkin-cpp.so *.o

gherkin-c:
	cd libs/gherkin-c && make libs

fmem:
	cd libs/fmem && mkdir build && cd build && CFLAGS="-fPIC" cmake .. -DBUILD_TESTING=0 && make

test:
	$(CXX) $(CXXFLAGS) test/main.cpp libgherkin-cpp.a -o test.out
	make `find test/testdata -iname "*.feature" | xargs -i% echo %.test`

%.feature.test:
	@./test.out $*.feature > $*.feature.tmp
	diff $*.feature.out $*.feature.tmp
	@rm -f $*.feature.tmp

clean:
	rm -f *.o *.a *.so *.out
	rm -rf libs/fmem/build