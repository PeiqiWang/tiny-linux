cmd_arch/x86/vdso/vdso32-sysenter.so.dbg := gcc -nostdlib -o arch/x86/vdso/vdso32-sysenter.so.dbg -fPIC -shared  -Wl,--hash-style=sysv  -Wl,--build-id -Wl,-Bsymbolic  -m32 -Wl,-m,elf_i386 -Wl,-soname=linux-gate.so.1 -Wl,-T,arch/x86/vdso/vdso32/vdso32.lds arch/x86/vdso/vdso32/vclock_gettime.o arch/x86/vdso/vdso32/note.o arch/x86/vdso/vdso32/sysenter.o && sh /home/child/my-linux/linux-patched/arch/x86/vdso/checkundef.sh 'nm' 'arch/x86/vdso/vdso32-sysenter.so.dbg'
