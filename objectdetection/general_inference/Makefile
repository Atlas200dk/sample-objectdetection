all : libgeneral_inference.so
#DEVICE COMPILER		
ifndef DDK_HOME
$(error "Can not find DDK_HOME env, please set it in environment!.")
endif

ifeq ($(mode),)
mode=AtlasDK
endif

ifeq ($(mode), AtlasDK)
CC := aarch64-linux-gnu-g++
else ifeq ($(mode), ASIC)
CC := $(DDK_HOME)/uihost/toolchains/aarch64-linux-gcc6.3/bin/aarch64-linux-gnu-g++
else
$(error "Unsupported mode: "$(mode)", please input: AtlasDK or ASIC.")
endif

# current directory
LOCAL_DIR  := ./

SRC_DIR = $(LOCAL_DIR)
BUILD_DIR = tmp
OUT_DIR = ../out
OBJ_DIR = $(BUILD_DIR)/obj
DEPS_DIR  = $(BUILD_DIR)/deps

# include
INC_DIR = \
	-I$(SRC_DIR) \
	-I$(DDK_HOME)/include/inc \
	-I$(DDK_HOME)/include/inc/custom \
	-I$(DDK_HOME)/include/third_party/opencv/include \
	-I$(DDK_HOME)/include/third_party/protobuf/include \
	-I$(DDK_HOME)/include/third_party/cereal/include \
	-I$(DDK_HOME)/include/libc_sec/include \
	-I../common/include \
	-I$(HOME)/ascend_ddk/include \

# link parameters
CC_FLAGS := $(INC_DIR) -g -std=c++11 -fPIC -DCPU_ONLY

ifeq ($(mode),)
mode=AtlasDK
endif

ifeq ($(mode), AtlasDK)
CC := aarch64-linux-gnu-g++
LNK_FLAGS := \
	-L$(HOME)/ascend_ddk/device/lib -L$(DDK_HOME)/device/lib/ \
	-lDvpp_api \
	-lDvpp_jpeg_decoder \
	-lDvpp_jpeg_encoder \
	-lDvpp_vpc \
	-lmedia_mini \
	-lhiai_server \
	-lidedaemon \
	-lhiai_common \
	-lopencv_world \
	-lascend_ezdvpp \
	-shared
else ifeq ($(mode), ASIC)
CC := $(DDK_HOME)/toolchains/aarch64-linux-gcc6.3/bin/aarch64-linux-gnu-g++
LNK_FLAGS := \
	-L$(HOME)/ascend_ddk/device/lib -L$(DDK_HOME)/device/lib/ \
	-lDvpp_api \
	-lDvpp_jpeg_decoder \
	-lDvpp_jpeg_encoder \
	-lDvpp_vpc \
	-lidedaemon \
	-lopencv_world \
	-shared

else
$(error "Unsupported mode: "$(mode)", please input: AtlasDK or ASIC.")
endif

DIRS := $(shell find $(SRC_DIR) -maxdepth 3 -type d)
CUSTOM_DIRS := $(shell find $(SRC_DIR) -maxdepth 3 -type d)

VPATH = $(DIRS)

SOURCES  = $(foreach dir, $(DIRS), $(wildcard $(dir)/*.cpp))
CUSTOM_SOURCES  = $(foreach dir, $(CUSTOM_DIRS), $(wildcard $(dir)/*.cpp))
OBJS   = $(addprefix $(OBJ_DIR)/,$(patsubst %.cpp,%.o,$(notdir $(SOURCES))))
OBJS_customop = $(addprefix $(OBJ_DIR)/,$(patsubst %.cpp,%.o,$(notdir $(CUSTOM_SOURCES))))
OBJS_no_customop := $(filter-out $(OBJS_customop), $(OBJS))
DEPS  = $(addprefix $(DEPS_DIR)/, $(patsubst %.cpp,%.d,$(notdir $(SOURCES))))

libgeneral_inference.so: $(OBJS_customop)
	$(CC) $^ $(LNK_FLAGS) -o $@
	rm -rf $(BUILD_DIR)

$(OBJ_DIR)/%.o:%.cpp
	@if [ ! -d $(OBJ_DIR) ]; then mkdir -p $(OBJ_DIR); fi;
	$(CC) -c $(CC_FLAGS) -o $@ $<

$(DEPS_DIR)/%.d:%.cpp
	@if [ ! -d $(DEPS_DIR) ]; then mkdir -p $(DEPS_DIR); fi;
	set -e; rm -f $@;
	$(CC) -MM $(CC_FLAGS) $< > $@.$$$$;
	sed 's,\($*\)\.o[ :]*,$(OBJ_DIR)/\1.o $@ : ,g' < $@.$$$$ > $@;
	rm -f $@.$$$$

ifneq ($(MAKECMDGOALS), clean)
	-include $(DEPS)
endif

.PHONY : clean install
clean:
	rm -rf $(BUILD_DIR) lib*.so *.o
install: libgeneral_inference.so
	mv *.so $(OUT_DIR)
