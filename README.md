# 定制化开发

## LuatTool 输出日志
log.info()

##　二次开发：dtu.openluat.com 后台-分組管理-參數配置-任务
1. 往串口发送数据： sys.publish('NET_RECV_WAIT'..uid, uid, data)
	- uid： 串口1或者串口2
	- data: lua字符串
2. 往网络通道发送数据：sys.publish('NET_SENT_RDY_'..uid, data) # UART_RECV_ID 已被替换为 NET_SENT_RDY_
	- uid： 通道1~12（查看dtu.openluat.com 后台-分組管理-參數配置-网络通道参数）
	- data: lua字符串	

## 数据接收和发送控制：dtu.openluat.com 后台-分組管理-參數配置-数据流模板-接收数据流模板
### 接收数据流模板：控制GPIO口输出电平数据流模板
	- 校验：根据协议校验指令内容。命令字+crc16数据校验
	- 设置：根据命令内容，计算控制GPIO时间，设置GPIO输出电平的持续时间
		- 准备工作：
			- 线程中指执行一次设置。
	- 返回：GPIO口没有返回再设置完之后返回数据。如果校验不通过则无需返回

	----------------------------- 测试版------------------------
	```
	function
		local str = ...
		log.info('接收到服务器的数据：', str)

		-- 循环定时输出电平
		function ledPwm(c, bl, bd, gap, gi, pinFun)
			-- 每组重复c次后停止
			for i = 1, c do
				pinFun(1)
				-- 输出电平一次持续时间
				sys.wait(bl)
				pinFun(0)
				-- 停止输出电平一次持续时间
				sys.wait(bd)
				-- 一个循环等待时间
				sys.wait(gap)
			end
			-- 每组间隔
			sys.wait(gi)
		end

		-- 指定时长输出电平
		function fixPwm(timeMs, pinFun)
			pinFun(1)
			sys.wait(timeMs)
			pinFun(0)
		end

		-- 创建一个任务线程,在模块最末行调用该函数并注册模块中的任务函数
		-- 调用的函数必须先声明后调用。否则报错
		sys.taskInit(function()
			log.info('taskInit------------------------------------------')

			-- 初始化一个 GPIO。比如：网络指示灯:64;RI:56;DTR:77
			local pinFun = pins.setup(77, 0)
			pinFun(0)

			-- 创建循环定时输出电平任务
			-- while true do 
			-- 	log.info('taskInit-while-----------------------------')

			-- ledPwm(5, 100, 100, 500, 3000, pinFun)
			-- end

			-- 指定时长输出电平
			fixPwm(5000, pinFun)

		end)

		-- 是否自动发送
		local autoSend = true
		if autoSend then
			local uid = 1
			local sendPackData = pack.pack('>b6', 0x40, 0x02, 0x01, 0x00, 0xB7, 0x0D)
			log.info('自动发送的字符串：', sendPackData)
			sys.publish('NET_SENT_RDY_'..uid, sendPackData)
		end

		return str

	end
	```
	----------------------------- 测试版-end------------------------
	

	----------------------------- 正式版------------------------
	```
	function
		local str = ...
		log.info('接收到服务器的数据02：', str)
		log.info('接收到服务器的数据长度02：', string.len(str))
		-- 下面一句不能添加，否则报错
		-- log.info('接收ASCII码，返回对应的控制字符', string.char(str))
		log.info('接收控制字符，返回ASCII码', string.byte(str))

		local nextpos, cmdid, cmdlen, devnum, ohours, omiu, rm, sig  = pack.unpack(str, '>b7')
		log.info('接收数据之后解析结果：', nextpos, cmdid, cmdlen, devnum, ohours, omiu, rm, sig)

		controlTime = ohours * 3600 + omiu * 60
		cryptData = cmdid..cmdlen..devnum..ohours..omiu..rm
		cryptCrc16 = crypto.crc16("CCITT-FALSE", cryptData)

		if cryptCrc16 != sig then
			return
		end


		local nextpos, cmdid, cmdlen, cmdcnt  = pack.unpack(str, '>b3')
		log.info('接收数据之后解析结果-cmdcnt：', nextpos, cmdid, cmdlen, cmdcnt)

		-- 指定时长输出电平
		function fixPwm(timeMs, pinFun)
			pinFun(1)
			sys.wait(timeMs)
			pinFun(0)
		end

		-- 创建一个任务线程,在模块最末行调用该函数并注册模块中的任务函数
		-- 调用的函数必须先声明后调用。否则报错
		sys.taskInit(function()
			log.info('taskInit------------------------------------------')

			-- 初始化一个 GPIO。比如：网络指示灯:64;RI:56;DTR:77
			local pinFun = pins.setup(77, 0)
			pinFun(0)

			-- 指定时长输出电平
			fixPwm(controlTime, pinFun)

		end)

		-- 是否自动发送
		local autoSend = true
		if autoSend then
			local uid = 1
			local sendPackData = pack.pack('>b6', 0x40, 0x02, 0x01, 0x00, 0xB7, 0x0D)
			log.info('自动发送的字符串：', sendPackData)
			sys.publish('NET_SENT_RDY_'..uid, sendPackData)
		end

		return str

	end


	```
	----------------------------- 正式版-end------------------------

## 任务： dtu.openluat.com 后台-分組管理-參數配置-任务
### 通电之后GPIO停止输出电平-任务

```
以下方案已测试，并未成功，需要修改源码进行二次开发即可！，修改源码后打包成新的固件，以便后续使用

方案1：

function
	sys.taskInit(function()
		log.info('gpioOutput-taskInit------------------------------------------')

		-- 初始化一个 GPIO。比如：网络指示灯:64;RI:56;DTR:77
		local pinFun = pins.setup(77, 0)
		pinFun(0)

	end)
end

方案2：
function
	log.info('gpioOutpt------------------------------------------')
	sys.wait(10000)
	-- 初始化一个 GPIO。比如：网络指示灯:64;RI:56;DTR:77
	local pinFun = pins.setup(77, 0)
	pinFun(0)

end

方案3：
function
	log.info('gpioOutput-01------------------------------------------')
	sys.timerStart(function()
		log.info('gpioOutput-01------------------------------------------')

		-- 初始化一个 GPIO。比如：网络指示灯:64;RI:56;DTR:77
		local pinFun = pins.setup(77, 0)
		pinFun(0)
	end, 20000)
end
```
