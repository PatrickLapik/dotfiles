# Cache file for holding the current wallpaper
wallpaper_folder="$HOME/dotfiles/wallpapers"

cache_file="$HOME/.cache/current_wallpaper"
current_wallpaper=$(cat $cache_file)

# Create cache file if not exists
if [ ! -f $cache_file ] ;then
    touch $cache_file
    echo "$wallpaper_folder/dark-green-leaves.jpg" > "$cache_file"
fi

matugen_schemes=("scheme-content" "scheme-expressive" "scheme-fidelity" "scheme-fruit-salad" "scheme-monochrome" " scheme-neutral" "scheme-rainbow" "scheme-tonal-spot")

PS3="Choose a matugen scheme: "

chosen_scheme=""

select choice in ${matugen_schemes[@]}; do
   chosen_scheme=$choice 
   break
done

if [ ! $1 ] ;then
    swww img $current_wallpaper
    matugen image $current_wallpaper -t $chosen_scheme
else
    swww img $1
    matugen image $1 -t $chosen_scheme

    echo $1 > "$cache_file"
fi
