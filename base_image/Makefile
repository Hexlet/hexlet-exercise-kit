build:
	docker build -t hexlet/hexlet-vagrant .

run:
	docker run -it --read-only -p 8000:8000 hexlet/hexlet-vagrant /bin/bash

publish:
	docker push hexlet/hexlet-vagrant

.PHONY: build run
