#!/usr/bin/bash
#----------------------------------------------------------------------------------------
#
#	Welcome to lcs.sh [ (l)umination (c)ontrol (s)cript ]
#	Or call it simply: (l)amp (c)ontrol (s)cript"
#
#	Repository: https://github.com/jrie/lcs
#
#	Version 0.0.2 by Jan Riechers ( jan@dwrox.net )
#	Using "nova" [used version: Nova v1.7.0] as
#	API driver for the Govee.com web API"
#
#	Govee: https://govee.com/"
#	Nova: https://github.com/neroist/nova
#
#----------------------------------------------------------------------------------------
# HELPERS
#----------------------------------------------------------------------------------------
function show_usage() {
	echo "[LCS][HELP] Version \"v0.0.2\""
	echo
	echo '(L)uminance (c)ontrol (s)cript'
	echo 'Or simply: (l)amp (c)ontrol (s)cript'
	echo
	echo 'is a helper script to control "Govee" (light)'
	echo 'devices by command line.'
	echo
	echo 'The official Govee.com web API with "Nova" as'
	echo 'API driver/API commands is used.'
	echo
	echo 'References:'
	echo 'Govee: https://govee.com/'
	echo 'Nova: https://github.com/neroist/nova'
	echo
	echo 'Note: "Nova" has its own usage system,'
	echo 'this script just extends at Nova.'
	echo 'Tested with: \"Nova v1.7.0\"'
	echo
	echo "[LCS][HELP] Functions and usage"
	echo
	echo 'Help:'
	echo 'This help function.'
	echo
	echo 'help			=	No parameter, just type \"lcs.sh help\"'
	echo
	echo 'Device control:'
	echo 'Query can be used in conjunction with all commands.'
	echo 'To access a partiuclar device by its "id" or "all".'
	echo 'The only exception is "state" right now.'
	echo
	echo 'd|device		=	Number|String'
	echo 'd=0				Operate on device id "0" (default)'
	echo 'd=2				Operate on device id "2"'
	echo 'd=all				Operate on "all devices"'
	echo 'd=a				Shortcut "a" for "all devices"'
	echo
	echo 'State information:'
	echo 'Query and print the state of a single(!) device.'
	echo 'Should be used with "device" by id.'
	echo
	echo 's|state			=	No parameters (currently, on it..)'
	echo '				Use with "d=1" or "d=2" and so on to query device ids.'
	echo
	echo 'Brightness control:'
	echo 'Control the brightness of devices.'
	echo 'Can be used with "device" id, defaults to device id "0".'
	echo
	echo 'b|brigthness		= 	Without parameters, query brightness of device'
	echo
	echo 'b=34			=	Set the brightness of device to 34%'
	echo 'b=+12			=	Increase brightness of the device by 12% relatively'
	echo 'b=-10			=	Decrease brightness of the device by -10% relatively'
	echo 'b=*1.33			=	Multiply brightness by 2.2 relatively, supports fractions.'
	echo 'b=/2			=	Divide the brightness by 2 relatively, supports fractions.'
	echo
	echo 'Color control:'
	echo 'Control the color of one or all(!) devices.'
	echo 'Can be used with "device" like "brightness", defaults to device id "0".'
	echo 'Funny things follow, really.'
	echo
	echo 'Note:	You can operate on all or single channels and on one or ALL DEVICES(!)'
	echo '	using the "device" or "d" command.'
	echo
	echo 'c|color			= 	Without parameters, query color of device'
	echo 'c=#ff1000		= 	Set a fixed hex color value'
	echo 'c=orange		= 	Use a HTML color name, some are supported'
	echo 'c=123,80,0		= 	Set the rgb - red, green and blue color channels'
	echo '				in this example:'
	echo '				red = 123, green = 80, blue = 0'
	echo '				Possible values range from "0" to "255"'
	echo 'c=+10,*0.5,-3		= 	No joke, works. Similar to "brightness" parameter.'
	echo '				In this example:'
	echo '				red + 10, green * 0.5, blue - 3 (relatively)'
	echo 'c==64,/0.5,+128		= 	Translates: red = 64, green / 0.5, blue + 128'
	echo
	echo 'You can do one funny thing too:'
	echo 'c=+0,0,*0.125		= 	Translates: red + 0 (stays), green = 0, blue * 0.125'
	echo
	echo 'Single channel color operations'
	echo 'At the moment, following commands can not be chained/used together.'
	echo 'So, if you use "cr", you can not use "cg" or "cb" commands.'
	echo
	echo 'cr			=	Operate on "c"olor channel "r"ed'
	echo 'cg			=	Operate on "c"olor channel "g"reen'
	echo 'cb			=	Operate on "c"olor channel "b"lue'
	echo
	echo 'Examples:'
	echo 'cr=+12"		Increases red by 12'
	echo 'cr=0"		Sets red to 0'
	echo 'cr=-7"	Decreased red by 7'
	echo
	echo
	echo 'Note: All color channels support, the following operations.'
	echo 'Query (no value), set, addition, substraction, multiplication and division.'
	echo 'Without value, the color for the particular channel is displayed.'
	echo
	echo
	echo 'Turn control:'
	echo 'Controls the "on" and "off" states of one or all devices.'
	echo 'Use "device" or "d" switch to target one partiuclar device or all.'
	echo 'By default device with id "0" is operated on.'
	echo
	echo 't|turn			=	No paramter, query device on/off status'
	echo 't=on			=	Turn a device on'
	echo 't=off			=	Turn a device off'
	echo 't=toggle		=	Toggle the device on/off, if on turn off, if off on'
	echo 't=t			=	Shortcut for "toggle"'
	echo
	echo 'Other features:'
	echo "A lot of former switches, and planned features. :)"
	echo
	echo 'For updates, thxs, bugs and blames visit: https://github.com/jrie/lcs'
}

#----------------------------------------------------------------------------------------
function echo_debug_lcs() {
	if [[ $debugInspect == true ]]; then
		echo "$1"
	fi
}

#----------------------------------------------------------------------------------------
function echo_debug_nova() {
	if [[ $debugNova == true ]]; then
		echo "$1"
	fi
}

#----------------------------------------------------------------------------------------
function return_operationShort_index() {
	actionIndex=-1

	case "$1" in
	'=')
		actionIndex=1
		;;
	'+')
		actionIndex=2
		;;
	'-')
		actionIndex=3
		;;
	'/')
		actionIndex=4
		;;
	'*')
		actionIndex=5
		;;
	*)
		actionIndex=-1
		;;
	esac

	echo "$actionIndex"
}

#----------------------------------------------------------------------------------------
function return_action_name() {
	commandName=-1

	case "$1" in
	'b')
		commandName="brightness"
		;;
	't')
		commandName="turn"
		;;
	'c')
		commandName="color"
		;;
	'p')
		commandName="picker"
		;;
	's')
		commandName="state"
		;;
	*)
		commandName=-1
		;;
	esac

	echo "$commandName"
}

#----------------------------------------------------------------------------------------
function contains_element() {
	for value in $1; do
		if [[ "$value" == "$2" ]]; then
			return 0
		fi
	done

	return 1
}

#----------------------------------------------------------------------------------------
function check_and_clamp_value() {
	local value="$1"
	local lowerLimit="$2"
	local upperLimit="$3"

	if [[ "$value" -gt "$upperLimit" ]]; then
		echo "$upperLimit"
	elif [[ "$value" -lt "$lowerLimit" ]]; then
		echo "$lowerLimit"
	else
		echo "$value"
	fi
}

#----------------------------------------------------------------------------------------
# DEFAULTS
allDevices=false
calcOperator=''
commandInput=5
commandParameter=''
commandProvided=false
commandValues=()
debugInspect=false
debugNova=false
debugPrefix='[DEBUGGING]'
defaultColor="#7C5C00"
deviceId=0
deviceQuery="-d=$deviceId"
hasAction=false
hasOperation=false
hasValue=false
novaVersion=-1
operationShort='b'
possibleChannels=('r' 'g' 'b')
processedValue=-1
workOnColorChannel=''
workOnSingleChannel=false
quitAfterDebug=false
silent=false

declare -A colorValues
# Provided by Nova
colorValues["random"]='random'
colorValues["rand"]='rand'

# Provided built-in color names
colorValues["aliceblue"]='#f0f8ff'
colorValues["antiquewhite"]='#faebd7'
colorValues["aqua"]='#00ffff'
colorValues["aquamarine"]='#7fffd4'
colorValues["azure"]='#f0ffff'
colorValues["beige"]='#f5f5dc'
colorValues["bisque"]='#ffe4c4'
colorValues["black"]='#000000'
colorValues["blanchedalmond"]='#ffebcd'
colorValues["blue"]='#0000ff'
colorValues["blueviolet"]='#8a2be2'
colorValues["brown"]='#a52a2a'
colorValues["burlywood"]='#deb887'
colorValues["cadetblue"]='#5f9ea0'
colorValues["chartreuse"]='#7fff00'
colorValues["chocolate"]='#d2691e'
colorValues["coral"]='#ff7f50'
colorValues["cornflowerblue"]='#6495ed'
colorValues["cornsilk"]='#fff8dc'
colorValues["crimson"]='#dc143c'
colorValues["cyan"]='#00ffff'
colorValues["darkblue"]='#00008b'
colorValues["darkcyan"]='#008b8b'
colorValues["darkgoldenrod"]='#b8860b'
colorValues["darkgray"]='#a9a9a9'
colorValues["darkgreen"]='#006400'
colorValues["darkkhaki"]='#bdb76b'
colorValues["darkmagenta"]='#8b008b'
colorValues["darkolivegreen"]='#556b2f'
colorValues["darkorange"]='#ff8c00'
colorValues["darkorchid"]='#9932cc'
colorValues["darkred"]='#8b0000'
colorValues["darksalmon"]='#e9967a'
colorValues["darkseagreen"]='#8fbc8b'
colorValues["darkslateblue"]='#483d8b'
colorValues["darkslategray"]='#2f4f4f'
colorValues["darkturquoise"]='#00ced1'
colorValues["darkviolet"]='#9400d3'
colorValues["deeppink"]='#ff1493'
colorValues["deepskyblue"]='#00bfff'
colorValues["dimgray"]='#696969'
colorValues["dodgerblue"]='#1e90ff'
colorValues["firebrick"]='#b22222'
colorValues["floralwhite"]='#fffaf0'
colorValues["forestgreen"]='#228b22'
colorValues["fuchsia"]='#ff00ff'
colorValues["gainsboro"]='#dcdcdc'
colorValues["ghostwhite"]='#f8f8ff'
colorValues["gold"]='#ffd700'
colorValues["goldenrod"]='#daa520'
colorValues["gray"]='#808080'
colorValues["green"]='#008000'
colorValues["greenyellow"]='#adff2f'
colorValues["grey"]='#808080'
colorValues["honeydew"]='#f0fff0'
colorValues["hotpink"]='#ff69b4'
colorValues["indianred"]='#cd5c5c'
colorValues["indigo"]='#4b0082'
colorValues["ivory"]='#fffff0'
colorValues["khaki"]='#f0e68c'
colorValues["lavender"]='#e6e6fa'
colorValues["lavenderblush"]='#fff0f5'
colorValues["lawngreen"]='#7cfc00'
colorValues["lemonchiffon"]='#fffacd'
colorValues["lightblue"]='#add8e6'
colorValues["lightcoral"]='#f08080'
colorValues["lightcyan"]='#e0ffff'
colorValues["lightgoldenrodyellow"]='#fafad2'
colorValues["lightgray"]='#d3d3d3'
colorValues["lightgreen"]='#90ee90'
colorValues["lightpink"]='#ffb6c1'
colorValues["lightsalmon"]='#ffa07a'
colorValues["lightseagreen"]='#20b2aa'
colorValues["lightskyblue"]='#87cefa'
colorValues["lightslategray"]='#778899'
colorValues["lightsteelblue"]='#b0c4de'
colorValues["lightyellow"]='#ffffe0'
colorValues["lime"]='#00ff00'
colorValues["limegreen"]='#32cd32'
colorValues["linen"]='#faf0e6'
colorValues["magenta"]='#ff00ff'
colorValues["maroon"]='#800000'
colorValues["mediumaquamarine"]='#66cdaa'
colorValues["mediumblue"]='#0000cd'
colorValues["mediumorchid"]='#ba55d3'
colorValues["mediumpurple"]='#9370db'
colorValues["mediumseagreen"]='#3cb371'
colorValues["mediumslateblue"]='#7b68ee'
colorValues["mediumspringgreen"]='#00fa9a'
colorValues["mediumturquoise"]='#48d1cc'
colorValues["mediumvioletred"]='#c71585'
colorValues["midnightblue"]='#191970'
colorValues["mintcream"]='#f5fffa'
colorValues["mistyrose"]='#ffe4e1'
colorValues["moccasin"]='#ffe4b5'
colorValues["navajowhite"]='#ffdead'
colorValues["navy"]='#000080'
colorValues["oldlace"]='#fdf5e6'
colorValues["olive"]='#808000'
colorValues["olivedrab"]='#6b8e23'
colorValues["orange"]='#ffa500'
colorValues["orangered"]='#ff4500'
colorValues["orchid"]='#da70d6'
colorValues["palegoldenrod"]='#eee8aa'
colorValues["palegreen"]='#98fb98'
colorValues["paleturquoise"]='#afeeee'
colorValues["palevioletred"]='#db7093'
colorValues["papayawhip"]='#ffefd5'
colorValues["peachpuff"]='#ffdab9'
colorValues["peru"]='#cd853f'
colorValues["pink"]='#ffc0cb'
colorValues["plum"]='#dda0dd'
colorValues["powderblue"]='#b0e0e6'
colorValues["purple"]='#800080'
colorValues["rebeccapurple"]='#663399'
colorValues["red"]='#ff0000'
colorValues["rosybrown"]='#bc8f8f'
colorValues["royalblue"]='#4169e1'
colorValues["saddlebrown"]='#8b4513'
colorValues["salmon"]='#fa8072'
colorValues["sandybrown"]='#f4a460'
colorValues["seagreen"]='#2e8b57'
colorValues["seashell"]='#fff5ee'
colorValues["sienna"]='#a0522d'
colorValues["silver"]='#c0c0c0'
colorValues["skyblue"]='#87ceeb'
colorValues["slateblue"]='#6a5acd'
colorValues["slategray"]='#708090'
colorValues["snow"]='#fffafa'
colorValues["springgreen"]='#00ff7f'
colorValues["steelblue"]='#4682b4'
colorValues["tan"]='#d2b48c'
colorValues["teal"]='#008080'
colorValues["thistle"]='#d8bfd8'
colorValues["tomato"]='#ff6347'
colorValues["turquoise"]='#40e0d0'
colorValues["violet"]='#ee82ee'
colorValues["wheat"]='#f5deb3'
colorValues["white"]='#ffffff'
colorValues["whitesmoke"]='#f5f5f5'
colorValues["yellow"]='#ffff00'
colorValues["yellowgreen"]='#9acd32'

#----------------------------------------------------------------------------------------
# Argument parsing not using getopts
#----------------------------------------------------------------------------------------
module='[EXTCOMMAND PARSER]'
#echo "[LCS]$module Extended command and parameter parsing init."
validCommands=('action' 'a' 'color' 'c' 'brightness' 'b' 'channel' 'ch' 'cr' 'cg' 'cb' 'picker' 'state' 'device' 'd' 'debug' 'ndebug' 'turn' 't' 'value' 'v' '?' 'h' 'help' 'q' 'silent')

declare -A commandsArray
for argument in "$@"; do
	echo_debug_lcs "argument: $argument"
	commandName=$(echo "$argument" | tr '[:upper:]' '[:lower:]' | grep -oE '^[a-z0-9]+' | head -n1)

	if contains_element "${validCommands[*]}" "$commandName"; then
		echo_debug_lcs "Command name is valid: \"$commandName\""
		if [[ "${argument:${#commandName}:1}" == '=' ]]; then
			commandValue=$(echo "$argument" | tr -s '\=\+\-\*\/\#\.\,' | cut -d'=' -f2)
			if [[ "$commandValue" != '' ]]; then
				echo_debug_lcs "commandInput: $commandValue"
				commandsArray["$commandName"]="$commandValue"
			fi
		else
			commandsArray["$commandName"]=""
		fi
	fi
done

for command in "${!commandsArray[@]}"; do
	commandValue=${commandsArray[$command]}

	echo_debug_lcs "commandName	= \"$command\""
	echo_debug_lcs "commandValue	= \"$commandValue\""

	case "$command" in
	'silent')
		commandsArray[$command]='true'
		silent=true
		;;
	'q')
		commandsArray[$command]='true'
		debugInspect=true
		quitAfterDebug=true
		;;
	'color' | 'c')
		commandProvided=true
		commandName="color"
		commandParameter="-c"

		if [[ "$commandValue" != '' ]]; then
			commandInput="$commandValue"
			hasValue=true
		fi
		;;
	'brightness' | 'b')
		commandProvided=true
		commandName="brightness"
		commandParameter='-b'

		if [[ "$commandValue" != '' ]]; then
			commandInput="$commandValue"
			hasValue=true
		fi
		;;
	'picker')
		commandProvided=true
		commandName="picker"
		commandValues=('true' 'false' 't' 'f')
		commandParameter='-s'

		if [[ "$commandValue" != '' ]]; then
			deviceId="$commandValue"
			hasValue=true
		fi
		;;
	'state')
		commandProvided=true
		commandName="state"

		if [[ "$commandValue" != '' ]]; then
			deviceId="$commandValue"
			hasValue=true
		fi
		;;
	'turn' | 't')
		commandProvided=true
		commandName="turn"
		commandValues=('on' 'off' 'toggle' 't')
		commandParameter='-s'

		if [[ "$commandValue" != '' ]]; then
			commandInput="$commandValue"
			hasValue=true
		fi
		;;
	'value' | 'v')
		if [[ "$commandValue" != '' ]]; then
			commandInput="$commandValue"
			hasValue=true
		fi
		;;
	'device' | 'd')
		deviceId="$commandValue"
		;;
	'action' | 'a')
		calcOperator="$commandValue"
		hasAction=true
		;;
	'debug')
		debugInspect=true
		commandsArray[$command]='true'
		echo "[LCS] Debug active!"
		;;
	'ndebug')
		debugNova=true
		commandsArray[$command]='true'
		echo "[LCS] Debug \"Nova\" partially active!"
		;;
	'channel' | 'ch')
		commandProvided=true
		commandName="color"
		commandParameter="-c"

		if [[ "$commandValue" != '' ]]; then
			workOnColorChannel="$commandValue"
			hasValue=true
		fi

		workOnSingleChannel=true
		;;

	'cr' | 'cg' | 'cb')
		commandProvided=true
		commandName="color"
		commandParameter="-c"
		case "$command" in
		'cr') workOnColorChannel="r" ;;
		'cg') workOnColorChannel="g" ;;
		'cb') workOnColorChannel="b" ;;
		esac

		workOnSingleChannel=true
		if [[ "$commandValue" != '' ]]; then
			commandInput="$commandValue"
			hasValue=true
		fi
		;;
	'help' | 'h' | '?')
		show_usage
		exit 0
		;;
	*)
		echo "[LCS]$module Unhandled command: $command"
		;;
	esac
done

#----------------------------------------------------------------------------------------
# FLAGS with getopts
#----------------------------------------------------------------------------------------
while getopts 'o:a:v:d:c:inhs' flag; do
	case "${flag}" in
	'o')
		operationShort="${OPTARG}"

		if [[ "$operationShort" == 'c' ]]; then
			commandParameter="-c"
		fi
		;;
	'a')
		calcOperator="${OPTARG}"
		hasAction=true
		;;
	'v')
		commandInput="${OPTARG}"
		hasValue=true
		;;
	'd')
		deviceId="${OPTARG}"
		;;
	'i')
		debugInspect=true
		echo "[LCS] Debug active!"
		;;
	'c')
		commandName="color"
		commandParameter='-c'
		workOnColorChannel="${OPTARG}"
		workOnSingleChannel=true
		;;
	'n')
		debugNova=true
		echo "[LCS] Debug \"Nova\" partially active!"
		;;
	's')
		silent=true
		;;
	'h' | '?')
		show_usage
		exit 0
		;;
	*)
		if [[ "$commandProvided" != true ]]; then
			echo "[LCS]$module Unknown command provided. Use \"-h\" for help."
		fi
		;;
	esac
done

if [[ "$silent" == false ]]; then
	echo "[LCS]$module Ended command and parameter parsing."
fi

#----------------------------------------------------------------------------------------
if [[ "$silent" == false ]]; then
	echo '#----------------------------------------------------------------------------------------'
	echo '#'
	echo '#	Welcome to lcs.sh [(l)umination (c)ontrol (s)cript]'
	echo '#	Or call it simply: (l)amp (c)ontrol (s)cript'
	echo '#'
	echo '#	Version "0.0.1" by Jan Riechers (jan@dwrox.net)'
	echo '#'
	echo '#	For updates, thxs, bugs and blames visit:'
	echo '#	https://github.com/jrie/lcs'
	echo '#'
	echo '#	Using "Nova" [tested with: Nova v1.7.0]'
	echo '#	as API driver for the Govee.com web API'
	echo '#'
	echo '#	Govee: https://govee.com/'
	echo '#	Nova: https://github.com/neroist/nova'
	echo '#'
	echo '#----------------------------------------------------------------------------------------'
fi

hash nova &>/dev/null || {
	echo "\"Nova\" not found or installed. Get it from \"https://github.com/neroist/nova\"."
	exit 1
}

#----------------------------------------------------------------------------------------
novaOutput='-o=false'
novaVersion=$(nova --version)

if [[ $debugNova == true ]]; then
	novaOutput='-o=true'
fi

#----------------------------------------------------------------------------------------
if [[ "$commandProvided" == false ]]; then
	if [[ "$workOnSingleChannel" == false ]]; then
		commandName=$(return_action_name "$operationShort")
	fi

	if [[ "$commandName" -eq -1 ]]; then
		echo "[LCS][OPERATOR] Unknown short operator: \"$operationShort\", use \"-h\" or \"help\" to get a overview."
		exit 3
	fi
fi

#----------------------------------------------------------------------------------------
# Generalize and sanitize inputs
#----------------------------------------------------------------------------------------
commandName=$(echo "$commandName" | tr '[:upper:]' '[:lower:]')
operationShort=$(echo "$operationShort" | tr '[:upper:]' '[:lower:]')
commandInput=$(echo "$commandInput" | tr '[:upper:]' '[:lower:]' | tr -s '[\-\+\*\.\,\#]')
workOnColorChannel=$(echo "$workOnColorChannel" | tr '[:upper:]' '[:lower:]')

#---------------------------------------------------------------------------------------
# Some regular expressions for input matching
#----------------------------------------------------------------------------------------
deviceRE='^([0-9]+|all|a)$'
hexRE='^#([0-9a-fA-F]{3}){1,2}$'
numberRE='^[0-9]+([\.][0-9]+)?$'
startDigitRE='^[0-9]'
hasNotOnlyDigitsRE='([^0-9]+)'
cleanInputRE='^([\+\-\*\/0-9]{0,})([\.]{0,1}[0-9]{0,})?[0-9]+'

#----------------------------------------------------------------------------------------
# Input check and sanitation, hex values are evaluated inside the functions
#----------------------------------------------------------------------------------------
module='[INPUT VALIDATION]'
if [[ "$silent" == false ]]; then
	echo "[LCS]$module Starting input validation and sanitation."
fi

if [[ "$workOnSingleChannel" == true ]]; then
	if ! contains_element "${possibleChannels[*]}" "$workOnColorChannel"; then
		echo "[LCS]$module only the following color channels can be modified:"

		for channel in "${possibleChannels[@]}"; do
			case $channel in
			'r') colorName='red' ;;
			'g') colorName='green' ;;
			'b') colorName='blue' ;;
			esac
			echo "\"$channel\" for \"$colorName\""
		done

		echo
		exit
	fi
fi

if [[ "${commandInput:0:1}" != '#' ]]; then
	if [[ "$hasValue" == true && -v colorValues["$commandInput"] ]]; then
		if [[ "$silent" == false ]]; then
			echo "[LCS]$module Valid color name \"$commandInput\" provided."
		fi
	elif [[ "$hasAction" == true && "$hasValue" == true ]]; then
		singleValueFloat=$(echo "$commandInput" | grep -oE '([0-9]+(\.){0,1}[0-9]{0,})')
		commandInput="$singleValueFloat"

		if [[ "$singleValueFloat" != "$commandInput" ]]; then
			echo "[LCS]$module Action used but not a single number set as input value for calculation."
			exit
		elif [[ "${singleValueFloat: -1}" == '.' ]]; then
			singleValueFloatCorrected+="0"
			commandInput="$singleValueFloatCorrected"
			echo "[LCS]$module Corrected your input from \"$singleValueFloat\" to \"$singleValueFloatCorrected\""
		fi
	elif [[ "$hasValue" == true && "$commandName" == 'color' && "$workOnSingleChannel" == false ]]; then
		#rgbValues=$(echo "$commandInput" | tr -s '\=\+\-\*\/\,' | grep -oE "$cleanInputRE" | grep -oE '^(([\+\-\*\/]{0,1}[0-9]{1,3})(,|\s|\+|\-|\*|\/){0,1})+')
		#| grep -oE '^(([\+\-\*\/]{0,1}[0-9]{1,3})(,|\s|\+|\-|\*|\/){0,1})+'
		rgbValues=$(echo "$commandInput" | tr -s '\=\+\-\*\/\,' | tr -d '[:alpha:]' | grep -oE '^(((\+|\-|\*|\/){0,}[0-9]{1,3}[\.]{0,1}[0-9]{0,})(,|\s|\+|\-|\*|\/){0,1})+')
		echo_debug_lcs "[LCS]$module [DEBUG] rgbValues: $rgbValues"

		rgbArray=()
		IFS=',' read -ra rgbArray <<<"$rgbValues"

		if [[ "${#rgbArray[@]}" -ne 3 ]]; then
			echo "[LCS]$module ${#rgbArray[@]} RGB values provided. Required are 3 comma separated values from \"0\" to \"255\" like \"255,0,0\" for \"red\"."
			exit 6
		fi

		valueIndex=0
		hasError=false
		for value in "${rgbArray[@]}"; do
			hasOperator=false

			if ! [[ "$value" =~ $startDigitRE ]]; then
				testOperator=${value:0:1}
				testValue=${value:1}
				hasOperator=true
			else
				testValue="$value"
			fi

			if [[ "$hasOperator" == true ]]; then
				if [[ ! "$testOperator" =~ /\./ ]]; then
					if [[ "$testOperator" == '+' || "$testOperator" == '-' ]]; then
						testValue=$(echo "$testValue" | cut -d'.' -f1)
					else
						continue
					fi
				fi

				if [[ "$testValue" -lt -255 || "$testValue" -gt 255 ]]; then
					echo "[LCS]$module RGB value \"$value\" at index \"$valueIndex\" is out of bounds. Use a value from \"0\" to \"255\"."
					hasError=true
				else
					rgbArray[valueIndex]="$testOperator$testValue"
				fi
			elif [[ "$testValue" -lt 0 || "$testValue" -gt 255 ]]; then
				echo "[LCS]$module RGB value \"$value\" at index \"$valueIndex\" is out of bounds. Use a value from \"0\" to \"255\"."
				hasError=true
			fi

			# TODO: End here for debugging of color input
			echo_debug_lcs "Start here for debugging of color input!"
			echo_debug_lcs "Test Value: \"$testValue\""
			((valueIndex++))
		done

		if [[ "$hasError" == true ]]; then
			exit
		fi

		commandInput=$(
			IFS=','
			echo "${rgbArray[*]}"
		)
	elif [[ "$hasValue" == true && "$commandName" == 'color' && "$workOnSingleChannel" == true ]]; then
		value=$(echo "$commandInput" | grep -oE '(\-|\+|\*|\/){0,1}[0-9]{1,3}(\.){0,1}[0-9]{0,}')
		valueCount=$(
			IFS=""
			echo "$value" | wc -l
		)
		if [[ "$valueCount" -ne 1 ]]; then
			echo "[LCS]$module Provided RGB value has \"$valueCount\" values, but must be only one value from \"-255\" to \"255\"."
			exit 6
		fi

		if [[ "$value" =~ $hasNotOnlyDigitsRE ]]; then
			#TODO: Improve this parsing to check of "0.5" and alike
			compareValue=$(echo "$value" | grep -oE '[0-9]+' | head -n1)

			if [[ "${value:0:1}" == '+' || "${value:0:1}" == '-' ]]; then
				if [[ "$compareValue" -lt -255 || "$compareValue" -gt 255 ]]; then
					echo "[LCS]$module Provided RGB calculation value is \"${value:0:1}$compareValue\" but must be a value from \"-255\" to \"255\"."
					exit 6
				elif [[ "$compareValue" -eq 0 ]]; then
					echo "[LCS]$module Provided RGB value is \"${value:0:1}$compareValue\" but addition or substraction must be not exactly \"0\""
					exit 6
				fi
			elif [[ "${value:0:1}" != '=' && "$compareValue" -eq 0 || "$compareValue" -eq 1 ]]; then

				echo "[LCS]$module When multiplication or division is used a value of exactly \"0\" or \"1\" will not do anything. Aborting."
			#exit 6
			fi
		elif [[ "$value" -lt -255 || "$value" -gt 255 ]]; then
			echo "[LCS]$module Provided RGB value is \"$value\" but must be a value from \"-255\" to \"255\"."
			exit 6
		else
			commandInput="$value"
		fi

		if [[ "${commandInput:0:1}" =~ $startDigitRE ]]; then
			if [[ "$hasAction" == false ]]; then
				calcOperator='='
			fi
		else
			calcOperator="${commandInput:0:1}"
			commandInput="${commandInput:1}"
		fi

		echo_debug_lcs "[LCS]$module Working on single channel with command input value \"$commandInput\" and calculation operater \"$calcOperator\"."
	fi

	if [[ "$hasValue" == true && "$commandName" == 'brightness' ]]; then
		if [[ "$hasOperation" == false ]]; then
			calcOperator='='
		fi

		if ! [[ "${commandInput:0:1}" =~ $startDigitRE ]]; then
			calcOperator="${commandInput:0:1}"
			commandInput="${commandInput:1}"
			hasOperation=true
		fi

		commandInputCleaned=$(echo "${commandInput}" | grep -oE "$cleanInputRE")

		if [[ "$calcOperator" == '+' || "$calcOperator" == '-' || "$calcOperator" == '=' ]]; then
			commandInputCleaned=$(echo "${commandInput}" | grep -oE "$cleanInputRE" | grep -oE '^([0-9]+)')
		fi

		echo_debug_lcs "[LCS]$module commandInputCleaned: \"$commandInputCleaned\" cleaned."

		if [[ "$commandInputCleaned" =~ $hasNotOnlyDigitsRE ]]; then
			afterZeros=$(echo "$commandInputCleaned" | cut -d'.' -f2)
			zerosRemoved=$(printf "%.*f" "${#afterZeros}" "$commandInputCleaned")
			echo_debug_lcs "[LCS]$module zerosRemoved 1: \"$zerosRemoved\" cleaned."
		else
			zerosRemoved=$(echo "$commandInputCleaned" | bc)
			echo_debug_lcs "[LCS]$module zerosRemoved 2: \"$zerosRemoved\" cleaned."
		fi

		commandInput="$zerosRemoved"

		echo_debug_lcs "[LCS]$module commandInput with operator/value: \"$calcOperator\" \"$commandInput\" cleaned."

		if ! [[ "$commandInput" =~ $hasNotOnlyDigitsRE ]] && [[ "$calcOperator" != '*' && "$calcOperator" != '/' ]]; then
			if [[ "$commandInput" -lt 1 || "$commandInput" -gt 100 ]]; then
				commandInputClamped=$(check_and_clamp_value "$commandInput" "1" "100")
				if [[ "$commandInputClamped" -ne "$commandInput" ]]; then
					echo "[LCS]$module Clamped value for brightness change to \"$commandInputClamped\""
				fi
			fi
		fi

		if [[ "$hasOperation" == true ]] && [[ ! "$commandInputCleaned" =~ $hasNotOnlyDigitsRE && "$calcOperator" == '*' || "$calcOperator" == '/' ]]; then
			if [[ "$commandInput" -lt -100 || "$commandInput" -gt 100 ]]; then
				echo "[LCS]$module Provided value \"$calcOperator$commandInput\" for brightness calculation should be either or be between \"-100\" and \"100\""
				exit
			fi
		fi
	fi

	echo_debug_lcs "[LCS]$module Here we should be fine with the input/output of \"$commandInput\""
else
	if [[ "${#commandInput}" -ne 7 ]]; then
		inputLength="${#commandInput}"
		((inputLength--))

		echo "[LCS]$module Hex value provided does not match, it should be in format: \"#ab12de\", you provided \"$inputLength\" of \"6\" hex digits/letters"
		exit 1
	fi
fi

#----------------------------------------------------------------------------------------
# Check for proper device id/value and adapt the query command to Nova
#----------------------------------------------------------------------------------------
if [[ "$deviceId" =~ $deviceRE ]]; then
	if [[ "$deviceId" == 'all' || "$deviceId" == 'a' ]]; then
		deviceQuery="-a=true"
		allDevices=true
		deviceId='all devices'
	else
		deviceQuery="-d=$deviceId"
		allDevices=false
	fi
fi

#----------------------------------------------------------------------------------------
# Check for proper device id/value and adapt the query command to Nova
#----------------------------------------------------------------------------------------
if [[ "$deviceId" =~ $deviceRE ]]; then
	if [[ "$deviceId" == 'all' || "$deviceId" == 'a' ]]; then
		deviceQuery="-a=true"
		allDevices=true
		deviceId='all devices'
	else
		deviceQuery="-d=$deviceId"
		allDevices=false
	fi
fi

#----------------------------------------------------------------------------------------
# Debug output if enabled with '-i' flag
#----------------------------------------------------------------------------------------
if [[ $debugInspect == true ]]; then
	echo
	echo '[LCS][DEBUGGING VARIABLES]'
	echo "commandName		=	\"$commandName\""
	echo "commandParameter	=	\"$commandParameter\""
	echo "operationShort		=	\"$operationShort\""
	echo "deviceId		=	\"$deviceId\""
	echo "deviceQuery		=	\"$deviceQuery\""
	echo "allDevices		=	\"$allDevices\""
	echo "defaultColor		=	\"$defaultColor\""
	echo
	echo "commandsArray (in case of extend commands)"
	for command in "${!commandsArray[@]}"; do
		echo "\"$command\"		-->	${commandsArray[$command]}"
	done
	echo
	echo "calcOperator		=	\"$calcOperator\""
	echo "commandInput		=	\"$commandInput\""
	echo
	echo "workOnColorChannel	=	\"$workOnColorChannel\""
	echo "workOnSingleChannel	=	\"$workOnSingleChannel\""
	echo
	echo "debugInspect		=	\"$debugInspect\""
	echo "silent			=	\"$silent\""
	echo "debugNova		=	\"$debugNova\""
	echo
	echo "Nova version		=	\"$novaVersion\""
	echo "novaOutput		=	\"$novaOutput\""
	echo
	echo "hasOperation		=	\"$hasOperation\""
	echo "hasAction		=	\"$hasAction\""
	echo "hasValue		=	\"$hasValue\""
	echo
	echo "deviceRE		=	$deviceRE"
	echo "hexRE			=	$hexRE"
	echo "numberRE		=	$numberRE"
	echo "startDigitRE		=	$startDigitRE"
	echo "hasNotOnlyDigitsRE	=	$hasNotOnlyDigitsRE"
	echo "cleanInputRE		=	$cleanInputRE"
	echo '[/DEBUGGING]'
	echo
fi

if [[ "$quitAfterDebug" == true ]]; then
	exit
fi

#----------------------------------------------------------------------------------------
# Furter testing for valid action operator, division by zero and one
#----------------------------------------------------------------------------------------
if [[ "$hasOperation" == true ]]; then
	calcOperationIndex=$(return_operationShort_index "$calcOperator")
	if [[ $calcOperationIndex -eq -1 ]]; then
		echo '[LCS] Unknown calculation operater parameter provided, use either: "=", "+", "-", "*" or "/"'
		#exit 9
	fi
fi

#----------------------------------------------------------------------------------------
# Check for proper device id
#----------------------------------------------------------------------------------------
if [[ "$allDevices" == false ]]; then
	if ! [[ "$deviceId" =~ $deviceRE ]]; then
		echo "[LCS][DEVICE ID] Unknown value for device id: \"$deviceId\""
		exit 5
	fi
fi

#----------------------------------------------------------------------------------------
# Pre-check for divison by zero or divsion by one
#----------------------------------------------------------------------------------------
if [[ "$calcOperator" == '/' ]]; then
	if [[ "$commandInput" == '0' ]]; then
		echo "[LCS]$module When division is used, a value greater than \"0\" must be used."
		exit 6
	fi

	if [[ "$commandInput" == '1' ]]; then
		echo "[LCS]$module When division is used using a value of exactly \"1\" will not do anything. Aborting."
		exit 6
	fi
fi

#----------------------------------------------------------------------------------------
# Pre-check for multiplication by exactly one
#----------------------------------------------------------------------------------------
if [[ "$calcOperator" == '*' ]]; then
	if [[ "$commandInput" == '1' ]]; then
		echo "[LCS]$module When multiplication is used a value of exactly \"1\" will not do anything. Aborting."
		exit 6
	fi
fi

#----------------------------------------------------------------------------------------
# Pre-check for addition or substraction of 0
#----------------------------------------------------------------------------------------
if [[ "$calcOperator" == '+' || "$calcOperator" == '-' ]]; then
	if [[ "$commandInput" == '0' ]]; then
		echo "[LCS]$module When addition or substraction is used a value of exactly \"0\" will not do anything. Aborting."
		exit 6
	fi
fi

if [[ "$silent" == false ]]; then
	echo "[LCS]$module Finished succesfully."
fi
#----------------------------------------------------------------------------------------
# / End of input validation
#----------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------
# Start script work
#----------------------------------------------------------------------------------------
if [[ "$silent" == false ]]; then
	echo "[LCS][START JOB] Working on: \"$commandName\""
fi

if [[ "$commandName" == 'picker' || "$commandName" == 'state' ]]; then
	module='[PICKER]'

	if [[ "$commandName" == 'picker' ]]; then
		module='[PICKER]'
	else
		module='[STATE]'
	fi

	echo_debug_nova "[NOVA ACTION]$module Running \"$commandName\" query command on \"$deviceId\""

	if [[ "$commandName" == 'picker' ]]; then
		if [[ "$commandInput" == 'true' || "$commandInput" == 't' ]]; then
			tmpValue=$(nova "$commandName" "$deviceQuery" "$commandParameter"=true)
		else
			tmpValue=$(nova "$commandName" "$deviceQuery" "$commandParameter"=false)
		fi
	else
		tmpValue=$(nova "$commandName" "$deviceQuery")
	fi

	invalidDevice=$(echo "$tmpValue" | tail -n1 | grep -iE 'Invalid device')
	if [[ "$invalidDevice" != '' ]]; then
		echo "[LCS]$module Device with id \"$deviceId\" is invalid."
		exit 1
	fi

	if [[ "$commandName" == 'state' ]]; then
		echo "$tmpValue"
	fi

	echo_debug_nova "[NOVA ACTION]$module Finished \"$commandName\" query command on device \"$deviceId\""

	echo "[LCS]$module Finished, in case of errors, use \"-i\" or better \"debug\" and \"ndebug\" parameters to get some insights."
	exit 0
elif [[ "$commandName" == 'color' ]]; then
	module='[COLOR]'

	#TODO: Add a parameter to trigger default color swithc, it is a very easy pick
	#if [[ "$hasValue" == false && "$hasAction" == false ]]; then
	#	echo "[LCS]$module No color provided, using default color value: \"$defaultColor\""
	#	processedValue="$defaultColor"
	isColorValue=false

	if [[ -v colorValues["$commandInput"] ]]; then
		echo_debug_lcs "[LCS]$debugPrefix Color is valid color name: \"$commandInput\""
		processedValue="${colorValues["$commandInput"]}"
		isColorValue=true
		if [[ "$hasAction" == true ]]; then
			echo "[LCS]$module you provided \"$commandInput\" as color name which is valid, but also provided action \"$operationShort\""
		fi
	elif [[ "$commandInput" =~ $hexRE && "${#commandInput}" -eq 7 ]]; then
		echo_debug_lcs "[LCS]$debugPrefix Color is valid hex color: \"$commandInput\""
		processedValue="$commandInput"
		isColorValue=true
	elif [[ "${commandInput:0:1}" == '#' ]]; then
		inputLength="${#commandInput}"
		((inputLength--))

		echo "[LCS]$module Hex value provided does not match, should be in format: \"#ab12de\", you provided $inputLength hex digits/letters"
		exit 1
	elif [[ "$hasAction" == true && "$hasValue" == true ]] || [[ "$workOnSingleChannel" == true && "$hasValue" == true ]]; then
		currentValues=()

		if [[ "$allDevices" == false ]]; then
			tmpValue=$(nova "$commandName" "$deviceQuery" $commandParameter)
			currentValues+=("$tmpValue")
			deviceIndex="$deviceId"
		else
			# shellcheck disable=SC2178 # Array is provied by command
			currentValues=($(nova "$commandName" "$deviceQuery" $commandParameter))
			deviceIndex=0
		fi

		for value in "${currentValues[@]}"; do
			invalidDevice=$(echo "$value" | grep -iE 'Invalid device')
			if [[ "$invalidDevice" != '' ]]; then
				echo "[LCS]$module Device with id \"$deviceIndex\" is invalid."
				((deviceIndex++))
				continue
			fi

			originalHexColor=$(echo "$value" | grep -oE '#[0-9a-fA-F]+$')
			echo_debug_lcs "[LCS]$module Original hex color value \"$originalHexColor\""

			decimalHexColors=()
			outputHexColors=()

			slicePosition=1
			for ((x = 0; x < 3; ++x)); do
				hexValue=${originalHexColor:$slicePosition:2}
				decimalHexColors+=("$(echo "ibase=16; $hexValue" | bc)")
				((slicePosition += 2))
			done

			echo_debug_lcs "[LCS]$module Converted decimal hex color values \"${decimalHexColors[*]}\""

			if [[ "$workOnSingleChannel" == true ]]; then
				echo_debug_lcs "[LCS]$module Work on single color channel on device \"$deviceIndex\"."

				case $workOnColorChannel in
				'r') channel=0 ;;
				'g') channel=1 ;;
				'b') channel=2 ;;
				esac

				case $channel in
				0) colorName='red' ;;
				1) colorName='green' ;;
				2) colorName='blue' ;;
				esac

				commandInput=$(echo "$commandInput" | bc)

				if [[ "$calcOperator" != '=' ]]; then
					if [[ "$silent" == false ]]; then
						echo "[LCS]$module Value for \"$colorName\" color channel on device id \"$deviceIndex\" is a change by \"$calcOperator$commandInput\""
					fi
				else
					if [[ "$silent" == false ]]; then
						echo "[LCS]$module Value for \"$colorName\" color channel on device id \"$deviceIndex\" requested value is \"$commandInput\""
					fi
				fi

				# TODO: Check here wtih report of information
				if [[ "${decimalHexColors[$channel]}" -eq 0 ]]; then
					if [[ "$calcOperator" == '*' || "$calcOperator" == '/' ]]; then
						actionName='multiply'
						if [[ "$calcOperator" == '*' ]]; then
							actionName='multiply'
						else
							actionName='divide'
						fi

						echo "[LCS]$module Channel \"$colorName\" value is \"0\", cannot $actionName the value. Not changing."
						continue
					fi
				fi

				colorIndex=0
				# TODO: Add clamping check control like in below
				for decimalValue in "${decimalHexColors[@]}"; do
					if [[ "$colorIndex" -eq "$channel" ]]; then
						echo_debug_lcs "[LCS]$module Decimal value before calculation \"$decimalValue\""
						if [[ "$calcOperator" == '=' ]]; then
							calculatedDecimal="$commandInput"
						else
							echo_debug_lcs "[LCS]$module BC command input: \"base=10;scale=0; $decimalValue $calcOperator $commandInput\""
							calculatedDecimal=$(echo "base=10;scale=0; $decimalValue $calcOperator $commandInput" | bc | cut -d'.' -f1)
						fi

						echo_debug_lcs "[LCS]$module Decimal value after calculation \"$calculatedDecimal\""
					else
						calculatedDecimal="$decimalValue"
					fi

					if [[ "$colorIndex" -ne "$channel" ]]; then
						hexFilled=$(printf "%02x" "$decimalValue")
						outputHexColors+=("$(echo "$hexFilled" | tr '[:upper:]' '[:lower:]')")
						((colorIndex++))
						continue
					fi

					if [[ "$calculatedDecimal" -lt 0 || "$calculatedDecimal" -gt 255 ]]; then
						calculatedDecimalClamped=$(check_and_clamp_value "$calculatedDecimal" "0" "255")
						case $colorIndex in
						0) colorName='red' ;;
						1) colorName='green' ;;
						2) colorName='blue' ;;
						esac

						echo "[LCS]$module Clamped value of \"$commandName\" \"$colorName\" to \"$calculatedDecimalClamped\" for device id \"$deviceIndex\" instead of \"$calculatedDecimal\""
					else
						calculatedDecimalClamped="$calculatedDecimal"
					fi

					if [[ "$calculatedDecimalClamped" != "$decimalValue" ]]; then
						echo "[LCS]$module New value for \"$colorName\" color channel on device id \"$deviceId\" was \"$decimalValue\" is now at \"$calculatedDecimalClamped\""
					else
						if [[ "$silent" == false ]]; then
							echo "[LCS]$module No value change for \"$colorName\" color channel on device id \"$deviceId\""
						fi
					fi

					echo_debug_lcs "[LCS]$module Decimal value after clamp \"$calculatedDecimalClamped\""

					hexFilled=$(printf "%02x" "$calculatedDecimalClamped")
					outputHexColors+=("$(echo "$hexFilled" | tr '[:upper:]' '[:lower:]')")

					((colorIndex++))
				done

				processedValue=$(
					IFS=''
					echo "#${outputHexColors[*]}"
				)
				echo_debug_lcs "[LCS]$module Calculated hex color: \"$processedValue\""

				newHexColorLowered=$(echo "$processedValue" | tr '[:upper:]' '[:lower:]')
				originalHexColorLowered=$(echo "$originalHexColor" | tr '[:upper:]' '[:lower:]')

				if [[ "$newHexColorLowered" == "$originalHexColorLowered" ]]; then
					echo "[LCS]$module Calculated hex color is equal to current one. Not changing."
					continue
				fi
			elif [[ "$calcOperator" != '=' ]]; then
				echo_debug_lcs "[LCS]$module Work on all color channels."

				colorIndex=0
				# TODO: Add clamping check control like above
				for decimalValue in "${decimalHexColors[@]}"; do
					echo_debug_lcs "[LCS]$module Decimal value before calculation \"$decimalValue\""
					if [[ "$calcOperator" != '=' ]]; then
						calculatedDecimal=$(echo "base=10;scale=0; $decimalValue $calcOperator $commandInput" | bc | cut -d'.' -f1)
					else
						calculatedDecimal="$commandInput"
					fi

					echo_debug_lcs "[LCS]$module Decimal value after calculation \"$calculatedDecimal\""

					if [[ "$calculatedDecimal" -lt 0 || "$calculatedDecimal" -gt 255 ]]; then
						calculatedDecimalClamped=$(check_and_clamp_value "$calculatedDecimal" "0" "255")
						case $colorIndex in
						0) colorName='red' ;;
						1) colorName='green' ;;
						2) colorName='blue' ;;
						esac

						echo "[LCS]$module Clamped value of \"$commandName\" \"$colorName\" to \"$calculatedDecimalClamped\" for device id \"$deviceIndex\" instead of \"$calculatedDecimal\""
					else
						calculatedDecimalClamped="$calculatedDecimal"
					fi

					echo_debug_lcs "[LCS]$module Decimal value after clamp \"$calculatedDecimalClamped\""

					hexFilled=$(printf "%02x" "$calculatedDecimalClamped")
					outputHexColors+=("$(echo "$hexFilled" | tr '[:upper:]' '[:lower:]')")

					((colorIndex++))
				done
			fi

			processedValue=$(
				IFS=''
				echo "#${outputHexColors[*]}"
			)
			echo_debug_lcs "[LCS]$module Calculated hex color: \"$processedValue\""

			newHexColorLowered=$(echo "$processedValue" | tr '[:upper:]' '[:lower:]')
			originalHexColorLowered=$(echo "$originalHexColor" | tr '[:upper:]' '[:lower:]')

			if [[ "$newHexColorLowered" == "$originalHexColorLowered" ]]; then
				echo "[LCS]$module Calculated hex color is equal to current one. Not changing."
				continue
			fi

			echo_debug_nova "[NOVA ACTION]$module Running in 1 \"$commandName\" command on device id \"$deviceId\""
			nova "$commandName" "$deviceQuery" "$novaOutput" "$commandParameter$processedValue"
			echo_debug_nova "[NOVA ACTION]$module Finished in 1 \"$commandName\" query command on device id \"$deviceIndex\" with result \"$currentValue\""
			echo "[LCS]$module New value for \"$commandName\" on device \"$deviceIndex\" is now \"$processedValue\""
		done

		exit
	elif [[ "$hasValue" == true && "$hasAction" == false && "${processedValue:0:1}" != '#' ]]; then
		echo_debug_lcs "[LCS][DEBUG]$module commandInput: $commandInput"
		rgbValues=$(echo "$commandInput" | cut -d',' -f 1-3)
		echo_debug_lcs "[LCS][DEBUG]$module rgbValues $rgbValues"

		rgbArray=()
		IFS=',' read -ra rgbArray <<<"$rgbValues"

		if [[ "${#rgbArray[@]}" -ne 3 ]]; then
			echo "[LCS]$module ${#rgbArray[@]} RGB values provided. Required are 3 comma separated values from \"0\" to \"255\" like \"255,0,0\" for \"red\""
			exit 6
		fi

		colorIndex=0
		hexColors=()
		currentValues=()
		hasError=false
		rgbStrippedTest=$(echo "$rgbValues" | tr -d ',')

		rgbValues=()

		# TODO: Debug here
		if [[ "$rgbStrippedTest" =~ $hasNotOnlyDigitsRE ]]; then
			echo_debug_lcs "Has operations..."
			valueIndex=0
			for value in "${rgbArray[@]}"; do
				calcOperator="${value:0:1}"
				# TODO: Add input debugging for multiplication and division!
				if [[ "$calcOperator" == '+' || "$calcOperator" == '-' ]]; then
					calcValueTmp="${value:1}"
					calcValueCorrected=$(echo "$calcValueTmp" | grep -oE '^[0-9]+')

					if [[ "$calcValueCorrected" -lt -255 || "$calcValueCorrected" -gt 255 ]]; then
						echo "[LCS]$module RGB value at position \"$(colorIndex+1)\" (\"$colorName\") is \"$value\", possible values range from \"-255\" to \"255\""
						hasError=true
					else
						rgbArray[valueIndex]="$calcOperator$calcValueCorrected"
					fi
				fi

				((valueIndex++))
			done

			if [[ "$hasError" == true ]]; then
				exit
			fi

			echo_debug_nova "[NOVA ACTION]$module Running \"$commandName\" query command on device id \"$deviceId\""

			if [[ "$allDevices" == false ]]; then
				tmpValue=$(nova "$commandName" "$deviceQuery" $commandParameter)
				currentValues+=("$tmpValue")
				deviceIndex="$deviceId"
			else
				# shellcheck disable=SC2178 # Array is provied by command
				currentValues=($(nova "$commandName" "$deviceQuery" $commandParameter))
				deviceIndex=0
			fi

			for value in "${currentValues[@]}"; do
				invalidDevice=$(echo "$value" | grep -iE 'Invalid device')
				if [[ "$invalidDevice" != '' ]]; then
					echo "[LCS]$module Device with id \"$deviceIndex\" is invalid."
					((deviceIndex++))
					continue
				fi

				finalizedHexNumberArray=()

				currentValue=$(echo "$value" | grep -oE '[#0-9a-fA-Z]+$')
				echo_debug_nova "[NOVA ACTION]$module Finished \"$commandName\" query command on device id \"$deviceIndex\" with result \"$currentValue\""

				startPosition=1
				for ((x = 0; x < 3; x++)); do
					hexValue=${currentValue:$startPosition:2}
					decimalValue=$(echo "scale=0;ibase=16; $hexValue" | bc)

					case "$x" in
					0) colorName='red' ;;
					1) colorName='green' ;;
					2) colorName='blue' ;;
					esac

					echo "[LCS]$module Value for \"$colorName\" on device \"$deviceIndex\" reported as hex value \"$hexValue\" or decimal value of \"$decimalValue\""

					rgbItem="${rgbArray[$x]}"

					calcOperator="${rgbItem:0:1}"
					calcValue="${rgbItem:1}"

					echo_debug_lcs "[LCS][DEBUG]$module rgbItem: $rgbItem"
					echo_debug_lcs "[LCS][DEBUG]$module calcOperator: $calcOperator"
					echo_debug_lcs "[LCS][DEBUG]$module calcValue: $calcValue"

					if [[ "$calcOperator" =~ $startDigitRE ]]; then
						hexFilled=$(printf "%02x" "$rgbItem")
						finalizedHexNumberArray+=("$hexFilled")
					else
						calculatedDecimal=$(echo "scale=0; $decimalValue $calcOperator $calcValue" | bc)

						if [[ ! "$calculatedDecimal" =~ /./ ]]; then
							calculatedDecimal=$(echo "$calculatedDecimal" | cut -d'.' -f1)
						fi

						calculatedDecimalClamped=$(check_and_clamp_value "$calculatedDecimal" "0" "255")

						if [[ "$calculatedDecimalClamped" -ne "$calculatedDecimal" ]]; then
							echo "[LCS]$module Clamped value for \"$colorName\" color channel to \"$calculatedDecimalClamped\" instead of \"$calculatedDecimal\""
							calculatedDecimal="$calculatedDecimalClamped"
						fi

						hexFilled=$(printf "%02x" "$calculatedDecimal")
						echo "[LCS]$module New value for \"$colorName\" color channel was \"$decimalValue\" is now at \"$calculatedDecimal\" or \"$hexFilled\" hex"

						finalizedHexNumberArray+=("$hexFilled")
					fi

					((startPosition += 2))
				done

				hexValue=$(
					IFS=''
					echo "#${finalizedHexNumberArray[*]}"
				)
				if [[ "$silent" == false ]]; then
					echo "[LCS]$module New calculated value on device \"$deviceIndex\" hex value \"$hexValue\""
				fi

				processedValue="$hexValue"

				if [[ "$currentValue" == "$processedValue" ]]; then
					echo "[LCS]$module Value for \"$commandName\" on device \"$deviceIndex\" is already set to \"$processedValue\", not changing."
					((deviceIndex++))
					continue
				fi

				echo_debug_nova "[NOVA ACTION]$module Running in 2 \"$commandName\" command on device id \"$deviceId\""
				nova "$commandName" "$deviceQuery" "$novaOutput" "$commandParameter"="$processedValue"
				echo_debug_nova "[NOVA ACTION]$module Finished in 2 \"$commandName\" query command on device id \"$deviceIndex\" with result \"$processedValue\""

				if [[ "$silent" == false ]]; then
					echo "[LCS]$module Value for \"$commandName\" on device \"$deviceIndex\" set from \"$currentValue\" to \"$processedValue\""
				fi

				((deviceIndex++))
			done

			if [[ "$silent" == false ]]; then
				echo "[LCS]$module Finished, in case of errors, use \"-i\" or better \"debug\" and \"ndebug\" parameters to get some insights."
			fi
			exit
		else
			for value in "${rgbArray[@]}"; do
				if [[ "$value" -lt 0 || "$value" -gt 255 ]]; then
					case $colorIndex in
					1) colorName='red' ;;
					2) colorName='green' ;;
					3) colorName='blue' ;;
					esac
					echo "[LCS]$module RGB value at position \"$(colorIndex+1)\" (\"$colorName\") is \"$value\", possible values range from \"0\" to \"255\" like \"255,0,0\" for \"red\""
					hasError=true
				fi

				hexFilled=$(printf "%02x" "$value")

				hexColors+=("$hexFilled")
				((colorIndex++))
			done

			if [[ "$hasError" == true ]]; then
				exit
			fi

			processedValue=$(
				IFS=''
				echo "#${hexColors[*]}"
			)

			echo_debug_lcs "[LCS]$debugPrefix Color \"${processedValue[*]}\" are valid rgb color values."
			if [[ "$silent" == false ]]; then
				echo "[LCS]$module Converted \"${processedValue[*]}\" color values to hexadecimal color: \"$processedValue\""
			fi
		fi
	elif [[ "${processedValue:0:1}" != '#' && "$hasValue" == false ]]; then
		currentValues=()

		echo_debug_nova "[NOVA ACTION]$module Running \"$commandName\" query command on device id \"$deviceId\""

		if [[ "$allDevices" == false ]]; then
			tmpValue=$(nova "$commandName" "$deviceQuery" $commandParameter)
			currentValues+=("$tmpValue")
			deviceIndex="$deviceId"
		else
			# shellcheck disable=SC2178 # Array is provied by command
			currentValues=($(nova "$commandName" "$deviceQuery" $commandParameter))
			deviceIndex=0
		fi

		for value in "${currentValues[@]}"; do
			invalidDevice=$(echo "$value" | grep -iE 'Invalid device')
			if [[ "$invalidDevice" != '' ]]; then
				echo "[LCS]$module Device with id \"$deviceIndex\" is invalid."
				((deviceIndex++))
				continue
			fi

			currentValue=$(echo "$value" | grep -oE '#[0-9a-fA-Z]+$')

			if [[ "$currentValue" == '' ]]; then
				continue
			fi

			echo_debug_nova "[NOVA ACTION]$module Finished \"$commandName\" query command on device id \"$deviceIndex\" with result \"$currentValue\""
			if [[ "$workOnSingleChannel" == false ]] && [[ "$isColorValue" != true || "$hasValue" == false ]]; then
				echo "[LCS]$module Value for \"$commandName\" on device \"$deviceIndex\" reported as hex value \"$currentValue\""
				((deviceIndex++))
				continue
			fi

			echo_debug_lcs "[LCS]$module Work on single color channel on device \"$deviceIndex\"."

			case "$workOnColorChannel" in
			'r') channel=0 ;;
			'g') channel=1 ;;
			'b') channel=2 ;;
			esac

			case "$channel" in
			0) colorName='red' ;;
			1) colorName='green' ;;
			2) colorName='blue' ;;
			esac

			startPosition=1
			for ((x = 0; x < 3; x++)); do
				if [[ "$x" -ne "$channel" ]]; then
					((startPosition += 2))
					continue
				fi

				hexValue=${currentValue:$startPosition:2}
				decimalValue=$(echo "scale=0;ibase=16; $hexValue" | bc)
				echo "[LCS]$module Value for \"$colorName\" on device \"$deviceIndex\" reported as hex value \"$hexValue\" or decimal value of \"$decimalValue\""
				break
			done

			((deviceIndex++))
		done

		if [[ "$silent" == false ]]; then
			echo "[LCS]$module Finished, in case of errors, use \"-i\" or better \"debug\" and \"ndebug\" parameters to get some insights."
		fi

		exit 0
	fi

	echo_debug_nova "[NOVA ACTION]$module Running \"$commandName\" query command on device id \"$deviceId\""
	currentValues=()

	if [[ "$allDevices" == false ]]; then
		tmpValue=$(nova "$commandName" "$deviceQuery" $commandParameter)
		currentValues+=("$tmpValue")
		deviceIndex="$deviceId"
	else
		# shellcheck disable=SC2178 # Array is provied by command
		currentValues=($(nova "$commandName" "$deviceQuery" $commandParameter))
		deviceIndex=0
	fi

	for value in "${currentValues[@]}"; do
		invalidDevice=$(echo "$value" | grep -iE 'Invalid device')
		if [[ "$invalidDevice" != '' ]]; then
			echo "[LCS]$module Device with id \"$deviceIndex\" is invalid."
			((deviceIndex++))
			continue
		fi

		currentValue=$(echo "$value" | grep -oE '[#0-9a-fA-Z]+$' | tr '[:upper:]' '[:lower:]')

		if [[ "$currentValue" == "$processedValue" ]]; then
			echo "[LCS]$module Value for \"$commandName\" on device \"$deviceIndex\" is already set to \"$processedValue\", not changing."
			continue
		fi

		echo_debug_nova "[NOVA ACTION]$module Running in 1 \"$commandName\" command on device id \"$deviceId\""
		nova "$commandName" "$deviceQuery" "$novaOutput" "$commandParameter"="$processedValue"
		echo_debug_nova "[NOVA ACTION]$module Finished in 1 \"$commandName\" query command on device id \"$deviceIndex\" with result \"$currentValue\""

		if [[ "$silent" == false ]]; then
			echo "[LCS]$module Value for \"$commandName\" on device \"$deviceIndex\" set to \"$processedValue\""
		fi
		((deviceIndex++))
	done

	if [[ "$silent" == false ]]; then
		echo "[LCS]$module Finished, in case of errors, use \"-i\" or better \"debug\" and \"ndebug\" parameters to get some insights."
	fi
	exit 0
elif [[ "$commandName" == 'turn' ]]; then
	module='[TURN]'

	if [[ "$hasAction" == true || "$hasValue" == true ]]; then
		if ! contains_element "${commandValues[*]}" "$commandInput"; then
			echo -n "[LCS]$module \"$commandName\" supports either:"
			for command in "${commandValues[@]}"; do
				echo -n " \"$command\""
			done

			echo
			exit 7
		fi
	fi

	currentValues=()

	if [[ "$allDevices" == false ]]; then
		tmpValue=$(nova "$commandName" "$deviceQuery" $commandParameter)
		currentValues+=("$tmpValue")
		deviceIndex="$deviceId"
	else
		# shellcheck disable=SC2178 # Array is provied by command
		currentValues=($(nova "$commandName" "$deviceQuery" $commandParameter))
		deviceIndex=0
	fi

	echo_debug_nova "[NOVA ACTION]$module Running \"$commandName\" query command on \"$deviceId\""

	for value in "${currentValues[@]}"; do
		invalidDevice=$(echo "$value" | grep -iE 'Invalid device')
		if [[ "$invalidDevice" != '' ]]; then
			echo "[LCS]$module Device with id \"$deviceIndex\" is invalid."
			((deviceIndex++))
			continue
		fi

		currentValue=$(echo "$value" | grep -oE '(on|off)$')
		if [[ "$currentValue" == '' ]]; then
			continue
		fi

		echo_debug_nova "[NOVA ACTION]$module Finished \"$commandName\" query command on device \"$deviceIndex\" with result \"$currentValue\""

		if [[ "$hasValue" == false || "$commandInput" == '0' || "$commandInput" == false ]]; then
			echo "[LCS]$module Current value for \"$commandName\" on device \"$deviceIndex\" is \"$currentValue\""
			((deviceIndex++))
			continue
		fi

		if [[ "$currentValue" == "$commandInput" ]]; then
			echo "[LCS]$module Not changing \"$commandName\" for device \"$deviceIndex\" because the state is already \"$currentValue\""
			((deviceIndex++))
			continue
		elif [[ "$commandInput" == 'toggle' || "$commandInput" == 't' ]]; then
			if [[ "$currentValue" == 'on' ]]; then
				processedValue="off"
			else
				processedValue="on"
			fi
		else
			processedValue="$commandInput"
		fi

		echo_debug_nova "[NOVA OUTPUT]$module"
		nova "$commandName" "$deviceQuery" "$novaOutput" "$commandParameter=$processedValue"
		echo_debug_nova "[/NOVA OUTPUT]$module"

		echo_debug_lcs "[LCS]$debugPrefix Value changefor \"$commandName\" from \"$currentValue\" to \"$processedValue\""
		if [[ "$silent" == false ]]; then
			echo "[LCS]$module Changed value for \"$commandName\" on device \"$deviceIndex\" from \"$currentValue\" to \"$processedValue\""
		fi

		((deviceIndex++))
	done

	if [[ "$silent" == false ]]; then
		echo "[LCS]$module Finished, in case of errors, use \"-i\" or better \"debug\" and \"ndebug\" parameters to get some insights."
	fi

	exit 0
elif [[ "$commandName" == "brightness" ]]; then
	module='[BRIGHTNESS]'
	deviceIndex=0
	commandParameter="-b"

	if [[ "$hasValue" == false && "$hasOperation" == false && "$hasAction" == false ]]; then
		if [[ "$allDevices" == true ]]; then
			# shellcheck disable=SC2178 # Array is provied by command
			currentValues=($(nova "$commandName" "$deviceQuery"))
			echo_debug_nova "[NOVA ACTION]$module Finished queries \"$commandName\" on \"$deviceId\""
			deviceIndex=0
		else
			tmpValue=$(nova "$commandName" "$deviceQuery")

			invalidDevice=$(echo "$tmpValue" | grep -iE 'Invalid device')
			if [[ "$invalidDevice" != '' ]]; then
				echo "[LCS]$module Device with id \"$deviceId\" is invalid."
				exit 1
			fi
			echo_debug_nova "[NOVA ACTION]$module Finished query \"$commandName\" on \"$deviceId\""

			currentValues+=("$tmpValue")
			deviceIndex="$deviceId"
		fi

		for value in "${currentValues[@]}"; do
			invalidDevice=$(echo "$value" | grep -iE 'Invalid device')
			if [[ "$invalidDevice" != '' ]]; then
				echo "[LCS]$module Device with id \"$deviceIndex\" is invalid."
				((deviceIndex++))
				continue
			fi

			currentValue=$(echo "$value" | grep -oE '[0-9]{1,3}%')
			if [[ "$currentValue" == '' ]]; then
				continue
			fi

			echo "[LCS] Value for \"$commandName\" on device \"$deviceIndex\" reported as \"$currentValue\""
			((deviceIndex++))
		done

		if [[ "$silent" == false ]]; then
			echo "[LCS]$module Finished, in case of errors, use \"-i\" or better \"debug\" and \"ndebug\" parameters to get some insights."
		fi

		exit 0
	elif [[ "$hasValue" != true && "$hasAction" != true ]]; then
		tmpValue=$(nova "$commandName" "$deviceQuery")

		invalidDevice=$(echo "$tmpValue" | grep -iE 'Invalid device')
		if [[ "$invalidDevice" != '' ]]; then
			echo "[LCS]$module Device with id \"$deviceId\" is invalid."
			exit 1
		fi

		currentValue=$(echo "$tmpValue" | grep -oE '([0-9]){1,3}%$' | tail -n1)
		echo_debug_nova "[NOVA ACTION]$module Finished query \"$commandName\" on device \"$deviceIndex\" with result \"$currentValue\""

		echo "[LCS]$module Value for \"$commandName\" on device \"$deviceIndex\" reported as \"$currentValue\""

		if [[ "$silent" == false ]]; then
			echo "[LCS]$module Finished, in case of errors, use \"-i\" or better \"debug\" and \"ndebug\" parameters to get some insights."
		fi

		exit 0
	elif [[ ! $commandInput =~ $numberRE && "$hasValue" == true ]]; then
		echo "[LCS]$module Please provide either a unsigned integer or a whole floating point number."
		exit 8
	fi

	echo_debug_lcs "[DEBUGGING CALCULATION]"
	echo_debug_lcs "[LCS][DEBUG] [Operator/Value] \"$calcOperator\" $commandInput\""
	echo_debug_lcs "[LCS][DEBUG] [operationShort index] \"$calcOperationIndex\""
	currentValues=()

	if [[ "$allDevices" == true ]]; then
		# shellcheck disable=SC2178 # Array is provied by command
		currentValues=($(nova "$commandName" "$deviceQuery"))
		echo_debug_nova "[NOVA ACTION]$module Finished queries \"$commandName\" on \"$deviceId\""
		deviceIndex=0
	else
		tmpValue=$(nova "$commandName" "$deviceQuery")
		echo_debug_nova "[NOVA ACTION]$module Finished query \"$commandName\" on \"$deviceId\""
		currentValues+=("$tmpValue")
		deviceIndex="$deviceId"
	fi

	for value in "${currentValues[@]}"; do
		invalidDevice=$(echo "$value" | grep -iE 'Invalid device')
		if [[ "$invalidDevice" != '' ]]; then
			echo "[LCS]$module Device with id \"$deviceIndex\" is invalid."
			((deviceIndex++))
			continue
		fi

		currentValue=$(echo "$value" | grep -oE '[0-9]{1,3}%$' | cut -d'%' -f1)

		if [[ "$calcOperator" != '=' ]] && [[ "$hasAction" == true || "$hasOperation" == true ]]; then
			processedValue=$(echo "scale=0; $currentValue $calcOperator $commandInput" | bc | grep -oE '^[0-9]+')
		else
			echo_debug_lcs "[DEBUG COMMAND] \"Set value to \"$commandInput\""
			processedValue="$commandInput"
		fi

		processedValue=$(check_and_clamp_value "$processedValue" "1" "100")

		echo_debug_lcs "[LCS][DEBUG] processedValue = $processedValue"
		echo_debug_lcs "[/DEBUGGING CALCULATION]"

		if [[ "$processedValue" -eq "$currentValue" ]]; then
			echo "[LCS]$module Not changing \"$commandName\" for device id \"$deviceIndex\" because the value is already at \"$currentValue%\""
			((deviceIndex++))
			continue
		fi

		if [[ "$silent" == false ]]; then
			echo "[LCS]$module Changing \"$commandName\" from \"$currentValue%\" to \"$processedValue%\""
		fi
		nova "$commandName" "$deviceQuery" "$novaOutput" "$commandParameter"="$processedValue"

		if [[ "$silent" == false ]]; then
			echo "[LCS]$module Changed \"$commandName\" for device id \"$deviceIndex\" to \"$processedValue%\""
		fi

		((deviceIndex++))
	done

	echo_debug_nova "[NOVA ACTION]$module Finished \"$commandName\" query command on device \"$deviceId\""

	if [[ "$silent" == false ]]; then
		echo "[LCS]$module Finished, in case of errors, use \"-i\" or better \"debug\" and \"ndebug\" parameters to get some insights."
	fi

	exit 0
fi

#----------------------------------------------------------------------------------------
# / END SCRIPT
#----------------------------------------------------------------------------------------
