packages = $(wildcard *)
packages.update = $(addsuffix .update,$(packages))

$(packages.update): # Here for autocompletion
%.update: dir = $*
%.update:
	cd $(dir); \
	./update.sh
