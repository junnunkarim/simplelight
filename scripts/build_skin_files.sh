#!/bin/bash

# get script directory
script_dir="$(dirname "$(readlink -f "$0")")"
# cd into script directory
cd "$script_dir" || exit

# file location
source="../source/images/dark/"
image_sizes="../source/images/image_sizes.h"

echo "  Source location: $source"
echo "  'image_sizes.h' location : $image_sizes"
echo

# process each `bmp` file in the source directory
for input in "$source"*.bmp; do
  input_name="${input##*/}"
  input_name="${input_name%.*}"

  # process the file
  echo "  Processing Bitmap: ${source}${input_name}.bmp"

  # grit generated `.c` files in current directory
  grit "${source}${input_name}.bmp" -gu8 -gb -gB16 -ftc -s "gImage_${input_name}"

  # grit generated output files contain extra postfix that needs to be removed.
  #
  # for example, this is a generated output:
  # `const unsigned char gImage_iconsBitmap[1344] __attribute__((aligned(4))) __attribute__((visibility("hidden")))=`
  #
  # here, `Bitmap` after `icons` and before `[1344]` needs to be removed
  # `__attribute__((visibility("hidden")))` also needs to be removed
  sed -i -e "s/gImage_${input_name}Bitmap/gImage_${input_name}/" "${input_name}.c"
  sed -i -e 's/__attribute__((visibility("hidden")))//' "${input_name}.c"

  rm -f "${input_name}.h"
  mv "${input_name}.c" "${source}/${input_name}.h"
done

echo
echo "  Complete..."
