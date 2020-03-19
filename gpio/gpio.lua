--- 模块功能：gpio功能测试.
-- @author leeprince
-- @module gpio.testGpioSingle
-- @license MIT
-- @copyright openLuat
-- @release 2019.12.31
require"pins"
module(...,package.seeall)


testpin = pins.setup(54, function(msg)
	if msg == cpu.INT_GPIO_POSEDGE then
		log.info('GPIO_54 被松开')
	else
		log.info('GPIO_54 被按下')
	end

end, pio.PULLUP)