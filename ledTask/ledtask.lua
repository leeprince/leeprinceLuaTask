--- 模块功能：led功能测试.
-- @author leeprince
-- @module gpio.testGpioSingle
-- @license MIT
-- @copyright openLuat
-- @release 2019.12.31
require"pins"
module(...,package.seeall)


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
	while true do 
		ledPwm(5, 100, 100, 500, 3000, pinFun)
	end

	-- 指定时长输出电平
	-- fixPwm(3000, pinFun)

end)


