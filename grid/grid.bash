#!/bin/bash
## grid.bash -- Generate a markdown overview document from all images in the current directory. Requires pandoc for the (optional) final conversion to HTML.
##
## Written by Tim Schäfer (https://rcmd.org/ts/), 2018-07-21.
## This is free software, released under the MIT License (see https://opensource.org/licenses/MIT)
##
## Note: The latest version is available at https://github.com/dfsp-spirit/shell-tools
##
## Usage: Place this in some directory on your $PATH (a typical directory is ~/bin/ I guess).
##        Then call it in the directory where you want the overview gallery to be created. No need for command line arguments, but you can use '--help' to see optional ones.

APPTAG="[GEN_SLD]"                  # Just an arbitrary tag used in all output of this script to stdout (so you can tell what output came from this script)
INPUT_IMAGE_FILE_EXTENSION="png"
OUTPUT_FILE_NO_EXT="gallery"
TITLE="${PWD##*/}"                  # Use directory name as a guess for the title


echo "$APPTAG +++ GRID -- GeneRate Image Document here (run with '--help' for more info) +++"

if [ -n "$1" ]; then
    if [ "$1" = "--help" -o "$1" = "-h" ]; then
        echo "$APPTAG GRID -- Generates a Markdown overview document from all images in the current directory. If available, uses 'pandoc' to generate more formats."
        echo "$APPTAG Usage: $0 [<img_file_ext> [<outfile_bn>]]"
        echo "$APPTAG    <img_file_ext>: the file extension of images that should be included. Example: 'jpg'. Defaults to 'png' if omitted."
        echo "$APPTAG    <outfile_bn>: the base name (i.e., name without file extension) of the output gallery file. Example: 'my_image_gallery'. Defaults to 'gallery' if omitted."
        exit 0
    fi
    INPUT_IMAGE_FILE_EXTENSION="$1"
fi

if [ -n "$2" ]; then
    OUTPUT_FILE_NO_EXT="$2"
    TITLE=$(echo "$2" | tr '-' ' ' | tr '_' ' ')                     # If the user supplied a file name, that may be an even better guess for the title (with underscores and dashes replaced by spaces)
fi


OUTPUT_FILE_MARKDOWN="${OUTPUT_FILE_NO_EXT}.md"
OUTPUT_FILE_HTML="${OUTPUT_FILE_NO_EXT}.html"

##### Generate the markdown file #####

## Generate header
echo "# ${TITLE}" > "${OUTPUT_FILE_MARKDOWN}"
echo "" >> "${OUTPUT_FILE_MARKDOWN}"

## Generate the headings and add the images

NUM_MATCHED_IMAGE_FILES=$(ls -1 *.${INPUT_IMAGE_FILE_EXTENSION} | wc -l)
NUM_MATCHED_IMAGE_FILES=$(echo -e "${NUM_MATCHED_IMAGE_FILES}" | tr -d '[:space:]')    # The 'wc' command is broken under MacOS: it outputs whitespace in addition to the number (><), so we have to remove that.

if [ ${NUM_MATCHED_IMAGE_FILES} -lt 1 ]; then
    echo "$APPTAG WARNING: No image files with image file extension '${INPUT_IMAGE_FILE_EXTENSION}' found in current directory. Your gallery will be empty."
    echo "$APPTAG NOTE   : You can run '$0 --help' to see optional command line arguments which allow you to set a custom file extension."
else
    echo "$APPTAG Found ${NUM_MATCHED_IMAGE_FILES} image files with requested extension '${INPUT_IMAGE_FILE_EXTENSION}' in current directory."
    for IMAGE_FILE in *.${INPUT_IMAGE_FILE_EXTENSION}
    do
        IMAGE_FILE_NO_EXTENSION="${IMAGE_FILE%.*}"
        GUESSED_IMAGE_SECTION_TITLE=$(echo "${IMAGE_FILE_NO_EXTENSION}" | tr '-' ' ' | tr '_' ' ')            # Out guess is the filename, with underscores and dashes replaced by spaces
        echo "## ${GUESSED_IMAGE_SECTION_TITLE}" >> "${OUTPUT_FILE_MARKDOWN}"
        echo "![](${IMAGE_FILE})" >> "${OUTPUT_FILE_MARKDOWN}"
        echo "" >> "${OUTPUT_FILE_MARKDOWN}"
    done
fi

echo "$APPTAG Markdown output file written to '${OUTPUT_FILE_MARKDOWN}'."

##### Use pandoc to create other formats from the Markdown file #####

## Generate HTML if pandoc is available
PANDOC_PATH=$(which pandoc)
if [ -n "$PANDOC_PATH" ]; then
    echo "$APPTAG Generating HTML format from Markdown file '${OUTPUT_FILE_MARKDOWN}', writing to file '${OUTPUT_FILE_HTML}'."
    pandoc -s --toc -o "${OUTPUT_FILE_HTML}" "${OUTPUT_FILE_MARKDOWN}"
    exit $?
fi