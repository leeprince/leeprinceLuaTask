# luat硬件开发手册

## luat环境

## Console demo『C:\Users\Administrator\Desktop\2\LuaTools 1.7.15\asr1802\lib\demo\console』 的使用（console demo）
1. main.lua 组成
2. luattask调度系统

## GPIO demo『C:\Users\Administrator\Desktop\2\LuaTools 1.7.15\asr1802\lib\demo\gpio』 的使用（console demo + GPIO demo + pins 接口）
1. 准备资料： 硬件手册、原理图
2. Console 调试 GPIO
3. 第一个LED程序（pins接口）
4. GPIO 中断和技巧
	- require - module 包管理

## ADC 外设的使用:读取原始测量数据和电压值（adc 扩展库）
1. ADC 在任务的基本用法
2. ADC 调试方法

## 定时器的使用：定时器、循环定时器(sys 接口、rtos扩展库)
1. 基本用法
	- 注意： 每创建一个任务会用掉一个定时器，总定时器个数不能超过32个
2. 高级用法

## I2c：数字电容式温湿度传感器(I2c扩展库)
1. I2c 使用注意事项：注意电源管理
2. I2c 从机器件的地址是7bit地址，如果硬件手册给的是8bitdizhi,要右移1位


## uart（串口） demo 【uart的理解：https://ask.openluat.com/article/924】（LuaTools 1.7.15\script\script_LuaTask\demo\uart\v3\demo.lua）
1. UART 的读缓冲区和写缓冲区
	- 单片机接收数据的时候，是依靠中断或者DMA. 而一般的单片机DMA最多几K.
	- 我们的单片机或者模块的资源是有限的，不是无穷的。
	- 使用DMA或者自定义的内存做缓冲区的，基本都是环形缓冲区（FIFO）。
2. uart 通常使用异步串口（收发是单独的，全双工），其他不常用的是同步串口
3. 串口的数据存在分包的情况
	- 通常的串口传输协议有这几种方法保证数据完整性
		1. 帧头 + 帧尾
		2. 帧头 + 长度 + CRC
		3. 超时 （分包）
4. Luat的串口机制
	1. 接收数据
		1. DMA的硬件FIFO是8字节，当DM达到8字节后产生中断，同时将这8个字节的数据写入8K的RAM的FIFO。（0033之前的lod是1460字节）
		2. DMA的硬件FIFO产生的中断会通知Lua虚拟机有新的数据可以读取了。 产生的通知条件是：DMA的硬件FIFO是从“非空”到“空”时才会产生中断并通知；如果DMA的FIFO非空，那么新来的数据则不会产生通知。
	2. 发送数据
		1. TX-done 上来（通知）后，只是表示RAM的FIFO数据发送成功，但是DMA的硬件FIFO的缓冲区并不一定发送完成。
	3. 如果一次写入的数据大于1460或者8960字节的时候，要分包，等待数据发送完成。
5. demo版本
	- v1: 是串口数据流
	- v2：是轮训工作模式
	- v3: 是消息回调

6. 控制GPIO电平-数据流模版方案

function 
    local str = ...
    sys.taskInit(function() 
        log.info('taskInit_________________________')
        local pinFun = pins.setup(77, 0)
        
        pinFun(0)

        while treu do
            pinFun(1)
            sys.wait(200)
            pinFun(0)
            sys.wait(400)
        end
    end)
end
















