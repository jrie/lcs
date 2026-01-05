# lcs
[L]uminance [c]ontrol [s]cript - control Govee light devices using Govee web API in a command line.
Using "[Nova](https://github.com/neroist/nova)" under the hood.

## What is lcs
A bash script, which builds upon "Nova" (https://github.com/neroist/nova) - with some very cool features.

**But please note:** This is not officially by "Govee" or the "Nova" project themself. The script nutures on "Nova" as **API connector and driver** and uses the **Govee web API**. You need a **Govee API key to make use of "Nova" and "LCS". But getting a API key is quite straight forward and is free of charge provided.

### Usage

**First: I spend some time on the documentation, so I paste it here from within the script, I am lazy, mostly.**

#### Preparations
- In short, `chmod +x lcs.sh` to allow execution of the script (provided you setup [Nova](https://github.com/neroist/nova)
- Then run `lcs.sh help` - which provides the following help to get you started.

#### Examples
- `lcs.sh brightness` - shows you the brightness of the device at "device id" "0" ("0" is default)
- `lcs.sh color device=3` - shows you the color of the device at "device id" "3"
- `lcs.sh turn d=1` - shows you the on/off state at device at "device id" "1"
- `lcs.sh color=orange` - Sets the device color to "orange" (html color names!)
- `lcs.sh brightness=32` - sets the device brightness to 32%
- `lcs.sh brightness=+20 d=5` - increases the device brightness of device id "5" by 20% relatively
- `lcs.sh c=255,120,0` - RGB color values, sets "red=255", "green=120" and "blue=0"

There is more to discover.. this are just some examples. You should continue reading the help.

### Help? - You got covered!
```md
[LCS][HELP] Version v0.0.1

(L)uminance (c)ontrol (s)cript
Or simply: (l)amp (c)ontrol (s)cript

is a helper script to control "Govee" (light)
devices by command line.

The official Govee.com web API with "Nova" as
API driver/API commands is used.

References:
Govee: https://govee.com/
Nova: https://github.com/neroist/nova

Note: "Nova" has its own usage system,
this script just extends at Nova.
Tested with: "Nova v1.7.0"

[LCS][HELP] Functions and usage

    Help:
	This help function.

    help			=	No parameter, just type "lcs.sh help"

Device control:
	Query can be used in conjunction with all commands.
	To access a partiuclar device by its "id" or "all".
	The only exception is "state" right now.

	d|device		=	Number|String
	d=0					Operate on device id "0" (default)
	d=2					Operate on device id "2"
	d=all				Operate on "all devices"
	d=a					Shortcut "a" for "all devices"

State information:
	Query and print the state of a single(!) device.
	Should be used with "device" by id.

	s|state			=	No parameters (currently, on it..)
					Use with "d=1" or "d=2" and so on to query device ids.

Brightness control:
	Control the brightness of devices.
	Can be used with "device" id, defaults to device id "0".

	b|brigthness	= 	Without parameters, query brightness of device
	b=34			=	Set the brightness of device to 34%
	b=+12			=	Increase brightness of the device by 12% relatively
	b=-10			=	Decrease brightness of the device by -10% relatively
	b=*1.33			=	Multiply brightness by 2.2 relatively, supports fractions.
	b=/2			=	Divide the brightness by 2 relatively, supports fractions.

Color control:
	Control the color of one or all(!) devices.
	Can be used with "device" like "brightness", defaults to device id "0".
	Funny things follow, really.

Note:	You can operate on all or single channels and on one or ALL DEVICES(!)
		using the "device" or "d" command.

	c|color			= 	Without parameters, query color of device
	c=#ff1000		= 	Set a fixed hex color value
	c=orange		= 	Use a HTML color name, some are supported
	c=123,80,0		= 	Set the rgb - red, green and blue color channels
						in this example:
						red = 123, green = 80, blue = 0
						Possible values range from "0" to "255"

	c=+10,*0.5,-3		= 	No joke, works. Similar to "brightness" parameter.
						In this example:
						red + 10, green * 0.5, blue - 3 (relatively)

	c==64,/0.5,+128		= 	Translates: red = 64, green / 0.5, blue + 128

	You can do one funny thing too:
	c=+0,0,*0.125		= 	Translates: red + 0 (stays), green = 0, blue * 0.125

Single channel color operations
	At the moment, following commands can not be chained/used together.
	So, if you use "cr", you can not use "cg" or "cb" commands.

	cr			=	Operate on "c"olor channel "r"ed
	cg			=	Operate on "c"olor channel "g"reen
	cb			=	Operate on "c"olor channel "b"lue

Examples:
	cr=+12			Increases red by 12
	cr=0			Sets red to 0
	cr=-7			Decreased red by 7


Note: All color channels support, the following operations.
	Query (no value), set, addition, substraction, multiplication and division.
	Without value, the color for the particular channel is displayed.

Turn control:
	Controls the "on" and "off" states of one or all devices.
	Use "device" or "d" switch to target one partiuclar device or all.
	By default device with id "0" is operated on.

	t|turn			=	No paramter, query device on/off status
	t=on			=	Turn a device on
	t=off			=	Turn a device off
	t=toggle		=	Toggle the device on/off, if on turn off, if off on
	t=t				=	Shortcut for "toggle"

Other features:
	A lot of former switches, and planned features. :)

For updates, thxs, bugs and blames visit: https://github.com/jrie/lcs
```
