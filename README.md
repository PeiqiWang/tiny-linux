#Tiny-linux#

这是高级操作系统课程最后的大作业，主要实现的功能和要求如下：
+ 完成对linux的裁剪，形成一个满足要求的最小的Linux系统。
+ 要求用linux-4.0.4和 BusyBox 1.23.2 （用作shell+网络命令行工具），libc可以选择musl libc, uclibc等
+ 最终的系统可以用ifconfig等网络命令, 和简单的网络程序(完成100MB的tcp/ip传输)，可以在qemu 模拟的x86-64 或 x86-32中跑起来

附加功能：
+ 将应用程序busybox运行在内核态

从开始完全不懂linux内核裁剪，到最后的结果可以满足实验要求，整个课程中非常感谢[**杨海宇同学**](https://github.com/ir193/)以及[**杨松霖同学**](https://github.com/SunliyMonkey/)的帮助！！感谢他们能够抽出时间不厌其烦地回答我的问题，细心帮我解决实验中所遇到的问题！！
##项目构成与思路分析##
想要启动一个linux，需要两个必要的组成部分
>* linux内核镜像
>
>* 可挂载的文件系统镜像

这也是我们这个项目的两大组成部分。简单的来说，就是在一个文件系统镜像上启动linux内核，[linux内核的启动过程](http://blog.chinaunix.net/uid-27052262-id-3404074.html)按照如下步骤：
> 1.内核解压缩和重定位

> 2.Linux进入非压缩内核的入口，在非压缩的内核入口中，系统完成各种初始化任务

> 3.跳转到C语言的入口处startkernel（）运行

我们使用的内核是linux最终生成的bzImage，[具体生成过程](http://blog.chinaunix.net/uid-25909619-id-3380535.html)以及与vmlinux的区别有兴趣的同学可以详细阅读，这里不再赘述。

上面我们所提到的文件系统镜像，需要支持上述的两阶段引导过程，因此这里我们使用具有Linux初始RAM磁盘（initrd）。initrd是在系统引导过程中挂载的一个临时根文件系统，包含了各种可执行程序和驱动程序，它们可以用来挂载实际的根文件系统，然后再将这个 initrd RAM磁盘卸载，并释放内存。在本实验中，initrd就是最终的根文件系统。

接下来，我们对上述[两阶段引导过程](http://www.ruanyifeng.com/blog/2013/08/linux_boot_process.html)具体进一步详细分析：

> 1. 操作系统接管硬件以后，首先读入内核文件

>     这里的内核文件指的就是我们裁剪后生产的内核镜像bzImage

> 2. 启动初始化进程

>     内核文件加载以后，就开始运行第一个程序/sbin/init，它的作用是初始化系统环境。由于init是第一个运行的程序，它的进程编号（pid）就是1。其他所有进程都从它衍生，都是它的子进程。

> 3. 初始化进程启动daemon

>     许多程序需要开机启动，它们在Linux中被称为就叫做"守护进程"（daemon）。init进程的一大任务，就是去运行这些开机启动的程序。init进程首先读取文件 /etc/inittab，文件中指定了需要启动的daemon

>     接下来需要按照inittab中的内容加载开机启动程序，启动脚本通常统一放在/etc/init.d目录中。/etc/init.d 这个目录名最后一个字母d，是directory的意思，表示这是一个目录，用来与程序 /etc/init 区分。执行系统初始化命令行，缺省情况下会使用/etc/init.d/rcS

> 4. 用户登录

> 开机启动程序加载完毕以后，就要让用户登录了,打开login shell，整个linux启动的流程就结束了，自此用户直接与操作系统通过命令行或图形界面等方式进行交互。 

通过上述的分析，我们基本上清楚了linux内核的作用以及根文件系统initrd应该如何构建。因此我们的实验思路如下：
+ 编译生成linux内核bzImahe
+ 构建生成initrd根文件系统
+ 实现实验要求功能的设置
+ 对linux内核进行裁剪
+ 将应用程序busybox运行在内核态

接下来我们将给出详细的实验过程和步骤。

##编译 linux-4.0.4##
首先我们建立一个新的工程文件
        mkdir my-linux
        cd my-linux
下载所需要的linux内核，我们使用的是[linux-4.0.4]（https://www.kernel.org/）版本的内核，现在最新版本的是4.0.5。可以选择手动下载，解压后放置在'my-linux/'目录下，也可以选择使用命令行的方式
        sudo apt-get install curl
        curl https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.0.4.tar.xz | tar xJf -
现在你的'my-linux/'目录下包含了一个'linux-4.0.4'的文件夹，其中是编译生成bzImage的源文件。为了后面对linux内核进行裁剪时的版本控制和调试，我们选择将make生成的文件和源文件分开存放。因此，可以使用如下命令对linux内核进行编译：
        mkdir obj
        mkdir obj/linux-defconfig
        cd linux-4.0.4
        make O=../obj/linux-defconfig defconfig
我们在'my-linux/obj/linux-defconig/'文件夹中存储了linux内核编译生成的Makefile等相应配置文件，采用的是默认的配置，其中'defconfige'默认为'x86_defconfig'，即生成的是64位内核文件，如需要生成32位内核文件，可以使用如下命令：
        make O=../obj/linux-defconfig i386_defconfig
这时我们对配置文件进行'make'就可以生成内核镜像，通过-j的参数指定编译时的线程数目
        cd ../obj/linux-defconfig
        make -j8
编译成功后，会看到如下信息：
> Kernel: arch/x86/boot/bzImage is ready  (#1)

由此也可以看出，生成的bzImage的位置，为了便于操作，我们将其移动到'obj/'的目录下
        cp arch/x86/boot/bzImage ../bzImage

##编译 RAM Disk##
##网络连接##
##linux内核裁剪##
##将应用程序运行在内核态##









