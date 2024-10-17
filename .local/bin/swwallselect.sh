#!/bin/bash
#  ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗  █████╗ ██████╗ ███████╗██████╗
#  ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
#  ██║ █╗ ██║███████║██║     ██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝
#  ██║███╗██║██╔══██║██║     ██║     ██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
#  ╚███╔███╔╝██║  ██║███████╗███████╗██║     ██║  ██║██║     ███████╗██║  ██║
#   ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
#
#  ██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗███████╗██████╗
#  ██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║██╔════╝██╔══██╗
#  ██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║█████╗  ██████╔╝
#  ██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║██╔══╝  ██╔══██╗
#  ███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████╗██║  ██║
#  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

# Set some variables
WALL_DIR="${HOME}/Pictures/wallpaper"
CACHE_DIR="${HOME}/.cache/wallselect/${theme}"
ROFI_CMD="rofi -dmenu -theme ${HOME}/.config/rofi/wallSelect.rasi -theme-str ${rofi_override}"
TRANSITION_BEZIER="0.25,0.1,0.25,1.0"
TRANSITION_TYPE="grow"
TRANSITION_DURATION="0.6"
TRANSITION_POS=$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")

# Create cache dir if not exists
if [ ! -d "${CACHE_DIR}" ] ; then
        mkdir -p "${CACHE_DIR}"
    fi


physical_monitor_size=24
monitor_res=$(hyprctl monitors |grep -A2 Monitor |head -n 2 |awk '{print $1}' | grep -oE '^[0-9]+')
dotsperinch=$(echo "scale=2; $monitor_res / $physical_monitor_size" | bc | xargs printf "%.0f")
monitor_res=$(( $monitor_res * $physical_monitor_size / $dotsperinch ))

rofi_override="element-icon{size:${monitor_res}px;border-radius:0px;}"

# Convert images in directory and save to cache dir
for IMAGE in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
	if [ -f "$IMAGE" ]; then
		FILENAME=$(basename "$IMAGE")
			if [ ! -f "${CACHE_DIR}/${FILENAME}" ] ; then
				magick convert -strip "$IMAGE" -thumbnail 500x500^ -gravity center -extent 500x500 "${CACHE_DIR}/${FILENAME}" 2>/dev/null
			fi
    fi
done

# Select a picture with rofi
wall_selection=$(find "${WALL_DIR}"  -maxdepth 1  -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | while read -r A ; do  echo -en "$A\x00icon\x1f""${CACHE_DIR}"/"$A\n" ; done | $ROFI_CMD)

# Set the wallpaper
[[ -n "$wall_selection" ]] || exit 1
swww img ${WALL_DIR}/${wall_selection} \
        --transition-bezier "$TRANSITION_BEZIER" \
        --transition-type "$TRANSITION_TYPE" \
        --transition-duration "$TRANSITION_DURATION" \
        --transition-pos "$TRANSITION_POS" \
        --invert-y

exit 0
