--OPTIMIZATION
-- DONT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING!
config.uitop_sleep = 2000
config.gear_sleep = 700
config.lights_sleep = 1000
config.direction_sleep = 2500
config.NuiCarhpandGas_sleep = 2500
config.car_mainloop_sleep = 1000
config.rpm_speed_loop = 40
config.idle_rpm_speed_sleep = 151
config.Rpm_sleep = 130 -- around 10-20-50-200 is a good value (depends on UTILS animation ms)
config.Rpm_sleep_2 = 45
config.Speed_sleep = 151
config.Speed_sleep_2 = 41

--UTILS UI SETTINGS -- the default settings is optimized for CPU usage, (DEFAULT: 'unset',0ms,'unset') Use this if you know else leave default.
-- THIS PART AFFECT OVERALL CPU USAGE FROM TASK MANAGER
-- NON VEHICLE CSS ANIMATION
config.acceleration = 'unset' -- (none,gpu,hardware) use hardware acceleration = cpu / gpu = gpu resource to some UI animation and effects?, option = hardware,gpu (looks like this is the same result)
config.animation_ms = '0ms' -- animation delay ( this affects cpu usage of animations ) DEFAULT '0ms'
config.transition = 'unset' -- ease, linear, or leave it like = '' (blank) or unset DEFAULT 'unset'
-- VEHICLE CSS ANIMATION
config.accelerationcar = 'unset' -- (none,gpu,hardware) use hardware acceleration = cpu / gpu = gpu resource to some UI animation and effects?, option = hardware,gpu (looks like this is the same result)
config.animation_mscar = '0ms' -- animation delay ( this affects cpu usage of animations ) DEFAULT '0ms'
config.transitioncar = 'unset' -- ease, linear, or leave it like = '' (blank) or unset DEFAULT 'unset'
-- DEFAULT UTIL SETTING is the optimize for CPU in task manager not in resmon!, but the animation or transition is sucks, you may want to configure the transition and animation_ms to your desire settings and desire beautiful transition of circlebars,carhud etc.
config.uiconfig = {acceleration = config.acceleration, animation_ms = config.animation_ms, transition = config.transition,accelerationcar = config.accelerationcar, animation_mscar = config.animation_mscar, transitioncar = config.transitioncar}