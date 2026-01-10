#include <stdio.h>
#include <dlfcn.h>

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("Usage: %s <dylib>\n", argv[0]);
        return 1;
    }
    void* handle = dlopen(argv[1], RTLD_LAZY);
    if (!handle) {
        printf("dlopen failed: %s\n", dlerror());
        return 1;
    }
    printf("dlopen success\n");

    const char* syms[] = {"pxt_get_audio_samples", "_pxt_get_audio_samples", "pxt_vm_start", "_pxt_vm_start"};
    for (int i = 0; i < 4; i++) {
        void* ptr = dlsym(handle, syms[i]);
        if (ptr) {
            printf("Found %s at %p\n", syms[i], ptr);
        } else {
            printf("Could not find %s\n", syms[i]);
        }
    }
    return 0;
}
