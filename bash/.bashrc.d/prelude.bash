pathmunge ()
{
    if ! echo "$PATH" | /bin/grep -Eq "(^|:)$1($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH="$PATH:$1"
        else
            PATH="$1:$PATH"
        fi
    fi
}

path_prepend_if_missing ()
{
    local pathname="$1"
    if [ -d $pathname ]; then
        pathmunge $pathname
    fi
}

rg_cpp()
{
    rg -g "*.c" -g "*.cpp" -g "*.h" $@
}

rg_cmake()
{
    rg -g "*.cmake" -g "CMakeLists.txt" $@
}

gsearch()
{
    local search_term=$(urlencode $@)
    local url="https://google.com/search?q=${search_term}"
    sensible-browser $url
}

copy_last_command ()
{
    # http://stackoverflow.com/a/23710535/1777162
    history -p '!!' |tr -d \\n | clip;
}

simple_date ()
{
    date +"%d%m%Y-%H%M%S"
}

top10_commands ()
{
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
}

# 40% quality seems to give good compression ratio and the output
# looks fine for the images I've needed to compress.
img_compress ()
{
    extension="${1##*.}"
    filename="${1%.*}"
    filename_smaller="${filename}_smaller"
    convert -strip -quality 40 $1 $filename_smaller.$extension
}

extract ()
{
    if [ -z "$1" ]; then
        # display usage if no parameters given
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
        echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
        return 1
    else
        for n in $@
        do
            if [ -f "$n" ] ; then
                case "${n%,}" in
                    *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar) 
                        tar xvf "$n"       ;;
                    *.lzma)      unlzma ./"$n"      ;;
                    *.bz2)       bunzip2 ./"$n"     ;;
                    *.rar)       unrar x -ad ./"$n" ;;
                    *.gz)        gunzip ./"$n"      ;;
                    *.zip)       unzip ./"$n"       ;;
                    *.z)         uncompress ./"$n"  ;;
                    *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar)
                        7z x ./"$n"        ;;
                    *.xz)        unxz ./"$n"        ;;
                    *.exe)       cabextract ./"$n"  ;;
                    *)
                        echo "extract: '$n' - unknown archive method"
                        return 1
                        ;;
                esac
            else
                echo "'$n' - file does not exist"
                return 1
            fi
        done
    fi
}
