SOURCE_DIRS=src
VPATH=$(SOURCE_DIRS) # http://www.ipp.mpg.de/~dpc/gmake/make_27.html#SEC26
EBIN_DIR=ebin
LIB_DIR=lib
ET_DIR=et
PREFIX=$(DESTDIR)/usr
ERLSHA2_NIF_EBIN=lib/erlang/lib/erlsha2_nif-1.0/ebin

CONTRIBS = $(shell echo `ls -d contrib/*/ 2>/dev/null`)
CONTRIB_PATH=$(foreach dir, ${CONTRIBS}, -pa $(dir)ebin)
CONTRIB_INCLUDES=$(foreach dir, ${CONTRIBS}, -I"$(dir)include")

INCLUDE_DIRS=include

INCLUDES=$(foreach dir, $(INCLUDE_DIRS), $(wildcard $(dir)/*.hrl))

INCLUDE_FLAGS += $(foreach dir, $(INCLUDE_DIRS), -I $(dir))

SOURCES=$(foreach dir, $(SOURCE_DIRS), $(wildcard $(dir)/*.erl))
TARGETS=$(foreach dir, $(SOURCE_DIRS), $(patsubst $(dir)/%.erl, $(EBIN_DIR)/%.beam, $(wildcard $(dir)/*.erl))) nif

ERLC_OPTS=$(INCLUDE_FLAGS) $(CONTRIB_INCLUDES) $(CONTRIB_PATH) -o $(EBIN_DIR) -Wall +debug_info # +native -v

MODULES=$(shell echo $(basename $(notdir $(TARGETS))) | sed 's_ _,_g')

all: $(EBIN_DIR) $(LIB_DIR) $(TARGETS)

export CC:=gcc

nif: 
	./c_src/config.sh
	gcc -fPIC -shared -o $(LIB_DIR)/erlsha2_nif.so.1 c_src/erlsha2_nif.c

$(EBIN_DIR)/%.beam: %.erl $(INCLUDES)
	erlc $(ERLC_OPTS) $<

$(EBIN_DIR):
	mkdir -p $(EBIN_DIR)

$(LIB_DIR):
	mkdir -p $(LIB_DIR)

install:
	install -d $(PREFIX)/lib
	install lib/erlsha2_nif.so.1 $(PREFIX)/lib
	cd $(PREFIX)/lib && ln -sf erlsha2_nif.so.1 erlsha2_nif.so
	install -d $(PREFIX)/$(ERLSHA2_NIF_EBIN)
	install ebin/erlsha2.beam $(PREFIX)/$(ERLSHA2_NIF_EBIN)

uninstall:
	rm $(PREFIX)/lib/erlsha2_nif.so
	rm $(PREFIX)/lib/erlsha2_nif.so.1
	rm -fr $(PREFIX)/$(ERLSHA2_NIF_EBIN)
	
clean:
	rm -f ebin/*.beam
	rm -f $(TARGETS)
	rm -fr $(EBIN_DIR)
	rm -fr $(LIB_DIR)
