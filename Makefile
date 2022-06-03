# 生成文件: dict.h lib$(TARGET).c lib$(TARGET).so 
# $(TARGET)依赖: $(TARGET).dict 
TARGET = flypy wubi98
DEPENDENCY_TARGET = $(TARGET:%=%_dependency)
LIB_TARGET = $(TARGET:%=$(BUILD_DIR)/lib%.so)
CFLAGS = -shared -fPIC -llua -I$(BUILD_DIR) -I$(SOURCE_DIR)
SOURCE_DIR = src
BUILD_DIR = build
DICT_DIR = dict

all: $(TARGET)
$(TARGET): %:%_dependency $(BUILD_DIR)/lib%.so
	@echo "build $@ success!"
$(LIB_TARGET): $(BUILD_DIR)/%.so:$(BUILD_DIR)/%.c $(SOURCE_DIR)/dict.c 
	$(CC) $(CFLAGS) $^ -o $@

$(DEPENDENCY_TARGET): %_dependency:$(BUILD_DIR) $(DICT_DIR)/%.dict
	cd $(BUILD_DIR) ; lua ../$(SOURCE_DIR)/gen_c_header.lua ../$(DICT_DIR)/$(@:%_dependency=%.dict)
	cd $(BUILD_DIR) ; lua ../$(SOURCE_DIR)/gen_c_entry.lua $(@:%_dependency=lib%)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHOPY: clean
clean:
	-rm -rf $(BUILD_DIR)
