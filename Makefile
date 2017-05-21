docker-machine-run:
	eval "$(docker-machine env default)"

pull:
	docker pull hexlet/hexlet-python
	docker pull hexlet/hexlet-java
	docker pull hexlet/hexlet-javascript
	docker pull hexlet/hexlet-php

javascript-setup:
	sudo npm install -g hexlet-pairs hexlet-pairs-data hexlet-points
	sudo npm install -g import-documentation
