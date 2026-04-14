#include <stdio.h>
#include <dlfcn.h>

int main() {
    char op[6];
    int num1, num2;

    while (scanf("%s %d %d", op, &num1, &num2) == 3) {
        char libname[16];
        snprintf(libname, sizeof(libname), "./lib%s.so", op);

        void* handle = dlopen(libname, RTLD_LAZY);
        int (*func)(int, int) = dlsym(handle, op);
        printf("%d\n", func(num1, num2));
        dlclose(handle);
    }

    return 0;
}