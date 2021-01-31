#!/bin/sh

BASE_DIR="SVGViewTests"
cd $BASE_DIR

HEADER="# W3C SVG Test Suite Coverage\n\n"
HEADER+="This page is automatically generated and shows actual coverage of the [W3C SVG Test Suite](https://github.com/web-platform-tests/wpt/tree/master/svg) by this \`SVGView\` implementation. "
HEADER+="Currently there are two standards supported: [SVG 1.1 (Second Edition)](https://www.w3.org/TR/SVG11/) and [SVG Tiny 1.2](https://www.w3.org/TR/SVGTiny12/).\n\n"
FOOTER=""

function addTitle() {
    HEADER+="  * [$2](#$3): "
    REF_COUNT=$(find "w3c/$1/refs" -type f -regex '.*\.ref$' | wc -l | xargs)
    SVG_COUNT=$(find "w3c/$1/svg" -type f -regex '.*\.svg$' | wc -l | xargs)

    PERCENT=$((REF_COUNT * 1000 / SVG_COUNT))
    PERCENT_FORMAT="$((PERCENT / 10)).$((PERCENT % 10))"
    HEADER+="\`$PERCENT_FORMAT%\`\n"

    FOOTER+="\n## [$2]($4)\n\n"
    FOOTER+="\`$PERCENT_FORMAT%\` of tests covered ($REF_COUNT/$SVG_COUNT). "
    FOOTER+="They can be splitted into following categories:\n"

    SUBTITLES="$(find "w3c/$1/svg" -type f -name '*.svg' | cut -f4 -d"/" | cut -f1 -d"-" | sort -u)"
    for ST in $SUBTITLES; do
        addSubTitle "$ST" "$1" "$4" "$5"
    done
}

function addSubTitle() {
    # uppercase first character
    TITLE="$(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1}"
    HEADER+="    * [$TITLE](#$1-$4): "
    REF_COUNT=$(find "w3c/$2/refs" -type f -name "$1-*" | wc -l | xargs)
    SVG_COUNT=$(find "w3c/$2/svg" -type f -name "$1-*" | wc -l | xargs)

    PERCENT=$((REF_COUNT * 1000 / SVG_COUNT))
    PERCENT_FORMAT="$((PERCENT / 10)).$((PERCENT % 10))"
    HEADER+="\`$PERCENT_FORMAT%\`\n"

    FOOTER+="\n### <a name='$1-$4'></a> [$TITLE]($3$1.html): \`$PERCENT_FORMAT%\`\n\n"

    FOOTER+="<details>\n"
    FOOTER+="  <summary>($REF_COUNT/$SVG_COUNT) tests covered...</summary>\n\n"
    FOOTER+="|Status  | Name|\n"
    FOOTER+="|------|-------|\n"

    SVGS="$(find "w3c/$2/svg" -type f -name "$1-*" | sort)"
    for F in $SVGS; do
        BASENAME=$(basename ${F%.*})
        FILENAME="w3c/$2/refs/$BASENAME.ref"
        if [ -f "$FILENAME" ]; then
            FOOTER+="|✅|"
        else
            FOOTER+="|❌|"
        fi 
        FOOTER+="[$BASENAME]($BASE_DIR/$F)|\n"
    done

    FOOTER+="</details>\n"
}

addTitle "1.1F2" "SVG 1.1 (Second Edition)" "svg-11-second-edition" "https://www.w3.org/TR/SVG11/" "1"
addTitle "1.2T" "SVG Tiny 1.2" "svg-tiny-12" "https://www.w3.org/TR/SVGTiny12/" "2"

echo "$HEADER$FOOTER" > ../w3c-coverage.md
