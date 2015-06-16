#tiny-linux#

这是高级操作系统课程最后的大作业，主要实现的功能和要求如下：
+ 完成对linux的裁剪，形成一个满足要求的最小的Linux系统。
+ 要求用linux-4.0.4和 BusyBox 1.23.2 （用作shell+网络命令行工具），libc可以选择musl libc, uclibc等
+ 最终的系统可以用ifconfig等网络命令, 和简单的网络程序(完成100MB的tcp/ip传输)，可以在qemu 模拟的x86-64 或 x86-32中跑起来
附加功能：
+ 将应用程序busybox运行在内核态

  从开始完全不懂linux内核裁剪，到最后的结果可以满足实验要求，整个课程中非常感谢[**杨海宇同学**](https://github.com/ir193/)以及[**杨松霖同学**](https://github.com/SunliyMonkey/)的帮助！！感谢他们能够抽出时间不厌其烦地回答我的问题，细心帮我解决实验中所遇到的问题！！
