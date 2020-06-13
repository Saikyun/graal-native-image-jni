GRAALVM = $JAVA_HOME

clean:
	-rm src/*.class
	-rm src/*.h
	-rm *.jar
	-rm *.so
	-rm helloworld

src/HelloWorld.class: src/HelloWorld.java
	javac src/HelloWorld.java

src/HelloWorld.h: src/HelloWorld.java
	javac -h src src/HelloWorld.java

libHelloWorld.jnilib: src/HelloWorld.h src/HelloWorld.c
	gcc -shared -Wall -Werror -I$(JAVA_HOME)/include -I$(JAVA_HOME)/include/darwin -o libHelloWorld.jnilib -fPIC src/HelloWorld.c

HelloWorld.jar: src/HelloWorld.class src/manifest.txt
	cd src && jar cfm ../HelloWorld.jar manifest.txt HelloWorld.class

run-jar: HelloWorld.jar libHelloWorld.jnilib
	LD_LIBRARY_PATH=./ java -jar HelloWorld.jar

helloworld: HelloWorld.jar libHelloWorld.jnilib
	$(GRAALVM_HOME)/bin/native-image \
		-jar HelloWorld.jar \
		-H:Name=helloworld \
		-H:+ReportExceptionStackTraces \
		-H:ConfigurationFileDirectories=config-dir \
		--initialize-at-build-time \
		--verbose \
		--no-fallback \
		--no-server \
		"-J-Xmx1g" \
		-H:+TraceClassInitialization -H:+PrintClassInitialization

run-native: helloworld libHelloWorld.jnilib
	LD_LIBRARY_PATH=./ ./helloworld
