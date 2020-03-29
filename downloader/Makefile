BIN := ~/.local/bin/hexdownloader

.PHONY: build
build:
		docker build -t hexdownloader:latest .

.PHONY: unregister
unregister:
		test -f ${BIN} && rm ${BIN} || true

.PHONY: register
register:
		test -f ${BIN} && rm ${BIN} || true
		cp hexdownloader.sh ${BIN} && \
		chmod u+x ${BIN}