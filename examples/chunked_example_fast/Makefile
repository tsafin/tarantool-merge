SHELL = bash
TARANTOOL ?= tarantool

default: test

start: clean
	mkdir -p storage_1
	mkdir -p storage_2
	$(TARANTOOL) ./storage_1.lua
	$(TARANTOOL) ./storage_2.lua

.ONESHELL:
stop:
	if test -f storage_1.pid ; then
		PID=$$(cat storage_1.pid)
		kill $$PID
	fi
	while kill -0 $$PID 2>/dev/null; do
		sleep 0.1
	done
	if test -f storage_2.pid ; then
		PID=$$(cat storage_2.pid)
		kill $$PID
	fi
	while kill -0 $$PID 2>/dev/null; do
		sleep 0.1;
	done

test:
	$(MAKE) start
	$(TARANTOOL) ./frontend.lua
	$(MAKE) stop

.ONESHELL:
clean:
	rm -f storage_[12]/*.{xlog,snap}
	rmdir storage_[12] || true
	rm -f storage_[12].{log,pid,instance.uuid,cluster.uuid}
	rm -f *.{xlog,snap}
