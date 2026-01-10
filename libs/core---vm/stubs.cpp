#include "pxt.h"

namespace pxt {
    // Minimal definition to satisfy the linker. 
    // In a full PXT build, this would be generated containing all exported C++ functions.
    const OpcodeDesc staticOpcodes[] = {
        { 0, 0, 0 }
    };
}
