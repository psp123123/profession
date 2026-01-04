
## top详细解读



```bash
top - 10:26:09 up 12 days, 12:52,  5 users,  load average: 131.98, 131.64, 131.20
Tasks: 589 total,  16 running, 573 sleeping,   0 stopped,   0 zombie
%Cpu(s): 42.5 us, 23.8 sy,  0.0 ni, 33.6 id,  0.0 wa,  0.0 hi,  0.1 si,  0.0 st
MiB Mem :  32088.4 total,    854.4 free,  14561.0 used,  16673.0 buff/cache
MiB Swap:   4096.0 total,   4090.6 free,      5.4 used.  16705.4 avail Mem

```

### load average

系统负载，top的信息输出中，表示1分钟，5分钟，15分钟

负载值 ≈ 等待运行的进程数（包括运行中和可运行的）



### 任务/进程统计

```bash
Tasks: 589 total,  16 running, 573 sleeping,   0 stopped,   0 zombie
```

* 589 total: 总进程数（包括线程）
* 16 running：正在运行的进程数（CPU正在处理）
* 573 sleeping：睡眠 / 等待中的进程数
* 0 stopped：被停止的进程数（SIGSTOP信号）
* 0 zombie：僵尸进程数（已完成但父进程未回收）



**注：进程的几种状态：**

* R(Running / Runnable) - 运行 / 可运行

* S(Sleeping / interruptible)- 休眠（可中断）
* D(Disk Sleep / Uniterrptible) - 磁盘休眠（不可中断）
* T(Stopped / Traced) - 停止/被跟踪
* Z (Zombie) - 僵尸

**特殊状态修饰符：**

这些字符出现在基本状态后面：

```
<   高优先级（负nice值）
N   低优先级（正nice值）
L   有页面锁定在内存中（实时进程）
s   会话领导者（session leader）
l   多线程进程
+   前台进程组
```



### CPU使用率统计

```
%Cpu(s): 42.5 us, 23.8 sy,  0.0 ni, 33.6 id,  0.0 wa,  0.0 hi,  0.1 si,  0.0 st
```

- **us**: **42.5%** - 用户空间CPU使用率（应用程序）
- **sy**: **23.8%** - 内核空间CPU使用率（系统调用）
- **ni**: **0.0%** - 调整过优先级的进程CPU使用率
- **id**: **33.6%** - 空闲CPU百分比（还有空闲资源）
- **wa**: **0.0%** - 等待I/O的CPU时间（I/O无瓶颈）
- **hi**: **0.0%** - 硬件中断处理时间
- **si**: **0.1%** - 软件中断处理时间
- **st**: **0.0%** - 被虚拟机偷走的时间（虚拟化环境）



### 物理内存使用

```
MiB Mem :  32088.4 total,    854.4 free,  14561.0 used,  16673.0 buff/cache
```



- **total**: 32,088.4 MiB ≈ **32GB** 总物理内存
- **free**: 854.4 MiB 空闲内存（**很低，需关注**）
- **used**: 14,561.0 MiB 已使用的内存
- **buff/cache**: 16,673.0 MiB 缓存/缓冲区内存

**内存分析**：

- 实际可用内存 = free + buff/cache中可回收部分
- Linux会利用空闲内存做缓存，buff/cache在需要时可被释放
- 但free仅854MB，可能影响新进程创建



### 交换分区使用

text

```
MiB Swap:   4096.0 total,   4090.6 free,      5.4 used.  16705.4 avail Mem
```



- **total**: 4,096.0 MiB ≈ **4GB** 交换分区大小
- **free**: 4,090.6 MiB 空闲交换空间（基本未使用）
- **used**: 5.4 MiB 已使用的交换空间
- **avail Mem**: 16,705.4 MiB ≈ **16.3GB** 可用内存估算值
