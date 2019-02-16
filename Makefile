SRC_DIR=src
BUILD_DIR=build
TARGET=nuthouse
OBJS=$(BUILD_DIR)/main.o
DEPS=src/* inc/* cfg/* chr/* pal/* nam/* map/* atr/* ent/*
ASSEMBLER=ca65
LINKER=ld65
ASSEMBLER_ARGS=--debug-info
LINKER_ARGS=-C cfg/nes.cfg --dbgfile $(BUILD_DIR)/$(TARGET).dbg

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm $(DEPS)
	$(ASSEMBLER) $(ASSEMBLER_ARGS) -o $@ \
		-I inc \
		--bin-include-dir chr \
		--bin-include-dir pal \
		--bin-include-dir nam \
		--bin-include-dir map \
		--bin-include-dir atr \
		--bin-include-dir ent \
		$<

$(BUILD_DIR)/$(TARGET).nes: $(OBJS)
	$(LINKER) $(LINKER_ARGS) -o $@ $^

.PHONY: clean

clean:
	rm $(BUILD_DIR)/*
