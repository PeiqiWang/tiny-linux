cmd_sound/core/snd.o := ld -m elf_x86_64   -r -o sound/core/snd.o sound/core/sound.o sound/core/init.o sound/core/memory.o sound/core/info.o sound/core/control.o sound/core/misc.o sound/core/device.o sound/core/isadma.o sound/core/sound_oss.o sound/core/info_oss.o sound/core/vmaster.o sound/core/ctljack.o 
