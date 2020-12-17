#!/bin/sh

# https://github.com/dylanaraps/pure-sh-bible
basename() {
    dir=${1%${1##*[!/]}}
    dir=${dir##*/}
    dir=${dir%"$2"}
    printf '%s\n' "${dir:-/}"
}

# https://github.com/dylanaraps/pure-sh-bible
dirname() {
    dir=${1:-.}
    dir=${dir%%"${dir##*[!/]}"}
    [ "${dir##*/*}" ] && dir=.
    dir=${dir%/*}
    dir=${dir%%"${dir##*[!/]}"}
    printf '%s\n' "${dir:-/}"
}

cd "$(dirname "$0")" || exit 1

echo "$0" | grep -q '.*\.git' && {
	echo "cannot use a repo that ends in git"
	exit 1
}

#shellcheck disable=2016
[ -z "$1" ] && {
	echo '$1 is empty'
	exit 1
}

#shellcheck disable=2016
[ -z "$2" ] && {
	echo '$2 is empty'
	exit 1
}

# $1 = full path to repo
# $2 = file which lists repo paths

DESTDIR="doc/git"
REPODIR="$DESTDIR/$(basename "$1")"

rm -rf "$REPODIR"
mkdir -p "$REPODIR"
(cd "$REPODIR" && stagit "$1")

cat > "$REPODIR/style.css" <<-EOF
body{background:#fffff0;}
*{
    font-family: "Bitstream Vera Serif", "Times New Roman", "serif";
}
pre {
    font-family: monospace;
}
h1,h2,h3,h4,h5,h6{
    font-weight: normal;
    border-bottom: 1px dashed black;
}
hr{border-top: 1px dashed black;}
img{display:none;}
EOF
[ -f "$DESTDIR/style.css" ] || cat > "$DESTDIR/style.css" <<-EOF
body{background:#fffff0;}
*{
    font-family: "Bitstream Vera Serif", "Times New Roman", "serif";
}
pre {
    font-family: monospace;
}
h1,h2,h3,h4,h5,h6{
    font-weight: normal;
    border-bottom: 1px dashed black;
}
hr{border-top: 1px dashed black;}
img{display:none;}
EOF

[ -f "$2" ] || :> "$2"
in=false
while read -r line; do
	[ "$line" = "$1" ] && {
		in=true
		break
	}
done < "$2"
[ "$in" = true ] || echo "$1" >> "$2"

# url
reponame="$(basename "$1")"
repodir="$(dirname "$1")"
printf 'git://depsterr.com/git/%s\n' "$reponame" > "$repodir/$reponame/url"
echo 'deppy' > "$repodir/$reponame/owner"

# make file accessible
:> "$repodir/$reponame/git-daemon-export-ok"

# shellcheck disable=2046
stagit-index $(cat "$2") > "$DESTDIR/index.html"
