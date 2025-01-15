#!/bin/env bash

if [ -z $1 ]; then
	echo "gnu_build_system.sh PROJECT_NAME"
	echo "you must provide a PROJECT_NAME"
	exit 1;
fi

dir="$(pwd)/$1"
lang="$2"
mkdir "$dir"
mkdir "$dir/tools"
mkdir "$dir/m4"
mkdir "$dir/build_aux"
mkdir "$dir/src"
mkdir "$dir/src/lib"
mkdir "$dir/src/po"
mkdir "$dir/build"
mkdir "$dir/build/po"

echo "AC_INIT([tdl],[1.0])
AC_CONFIG_AUX_DIR([build_aux])
AM_INIT_AUTOMAKE([foreign -Wall -Werror])
AC_PREREQ([2.69])
AC_PROG_CC
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile src/Makefile])
AC_CONFIG_SRCDIR([src/main.c])
AC_OUTPUT" > "$dir/configure.ac"

echo "SUBDIRS = src" > "$dir/Makefile.am"

echo "bin_PROGRAMS = main
main_SOURCES = main.c" > "$dir/src/Makefile.am"

echo "#include <config.h>
#include <libintl.h>
#include <stdio.h>
#include <locale.h>

#define _(String) gettext(String)

int main(int argc, char** argv) {
	setlocale(LC_ALL, \"\");
	bindtextdomain(\"messages\",\"../build/locale\");
	textdomain(\"messages\");

	printf(\"%s\", _(\"Hello World!\n\"));

	return 0;
}
" > "$dir/src/main.c"

echo "xgettext --keyword=_ --language=c -o - \$(find .. -name \"*.c\") | msginit -i - -o ../src/po/\${1,,}.po --locale=\$1.UTF-8" > "$dir/tools/translation_file_generator.sh"
