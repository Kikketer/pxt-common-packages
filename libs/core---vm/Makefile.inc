PXT_CPP = scheduler.cpp target.cpp verify.cpp vm.cpp vmcache.cpp vmload.cpp
keys.cpp ../core---linux/platform.cpp ../core---linux/dmesg.cpp
../core---linux/codalemu.cpp ../core---linux/control.cpp
../core---linux/config.cpp PXT_OBJS := $(addprefix bld/, $(PXT_CPP:.cpp=.o))
