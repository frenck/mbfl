# string.sh --
#
# Part of: Marco's BASH functions library
# Contents: string library
# Date: Fri Apr 18, 2003
#
# Abstract
#
#       This is a collection of string functions for the GNU BASH shell.
#
#       The functions make heavy usage of special variable substitutions
#       (like ${name:num:num})  so, maybe, other Bourne  shells will not
#       work at all.
#
# Copyright (c) 2003-2005, 2009, 2013, 2014, 2018 Marco Maggi
# <marco.maggi-ipsu@poste.it>
#
# This is free software; you  can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the
# Free Software  Foundation; either version  3.0 of the License,  or (at
# your option) any later version.
#
# This library  is distributed in the  hope that it will  be useful, but
# WITHOUT   ANY  WARRANTY;   without  even   the  implied   warranty  of
# MERCHANTABILITY  or FITNESS  FOR A  PARTICULAR PURPOSE.   See  the GNU
# Lesser General Public License for more details.
#
# You  should have  received a  copy of  the GNU  Lesser  General Public
# License along  with this library; if  not, write to  the Free Software
# Foundation, Inc.,  59 Temple Place,  Suite 330, Boston,  MA 02111-1307
# USA.
#

#page
#### quoted characters

function mbfl_string_is_quoted_char () {
    mbfl_mandatory_parameter(STRING, 1, string)
    mbfl_mandatory_integer_parameter(POS, 2, position)
    local -i COUNT
    let --POS
    for ((COUNT=0; POS >= 0; --POS))
    do
	if test "${STRING:${POS}:1}" = \\
        then let ++COUNT
        else break
	fi
    done
    let ${COUNT}%2
}
function mbfl_string_is_equal_unquoted_char () {
    mbfl_mandatory_parameter(STRING, 1, string)
    mbfl_mandatory_integer_parameter(POS, 2, position)
    mbfl_mandatory_parameter(CHAR, 3, known char)
    test "${STRING:${POS}:1}" = "$CHAR" || mbfl_string_is_quoted_char "$STRING" "$POS"
}

function mbfl_string_quote_var () {
    mbfl_mandatory_nameref_parameter(RESULT_VARREF, 1, result variable name)
    mbfl_optional_parameter(STRING, 2)
    local -i i
    local ch
    RESULT_VARREF=
    for ((i=0; i < ${#STRING}; ++i))
    do
        ch="${STRING:$i:1}"
        test "$ch" = \\ && ch=\\\\
        RESULT_VARREF+=$ch
    done
}
function mbfl_string_quote () {
    mbfl_optional_parameter(STRING, 1)
    local RESULT_VARNAME
    if mbfl_string_quote_var RESULT_VARNAME "$STRING"
    then printf '%s\n' "$RESULT_VARNAME"
    else return $?
    fi
}

#page
#### inspecting a string

function mbfl_string_length () {
    # We  want this  function to  accept empty  strings, so  we use  the
    # "optional" macro here.
    mbfl_optional_parameter(STRING, 1)
    echo ${#STRING}
}
function mbfl_string_length_equal_to () {
    mbfl_mandatory_integer_parameter(LENGTH, 1, length of string)
    # We  want this  function to  accept empty  strings, so  we use  the
    # "optional" macro here.
    mbfl_optional_parameter(STRING, 2)
    test ${#STRING} -eq $LENGTH
}
function mbfl_string_is_empty () {
    # We  want this  function to  accept empty  strings, so  we use  the
    # "optional" macro here.
    mbfl_optional_parameter(STRING, 1)
    test -z "$STRING"
}
function mbfl_string_is_not_empty () {
    # We  want this  function to  accept empty  strings, so  we use  the
    # "optional" macro here.
    mbfl_optional_parameter(STRING, 1)
    test -n "$STRING"
}

function mbfl_string_first_var () {
    mbfl_mandatory_nameref_parameter(RESULT_VARREF, 1, result variable name)
    mbfl_mandatory_parameter(STRING, 2, string)
    mbfl_mandatory_parameter(CHAR, 3, char)
    mbfl_optional_parameter(BEGIN, 4, 0)
    local -i i
    for ((i=$BEGIN; i < ${#STRING}; ++i))
    do
	if test "${STRING:$i:1}" = "$CHAR"
	then
            RESULT_VARREF=$i
	    # Found!  Return with exit status 0.
            return 0
        fi
    done
    # Not found!  Return with exit status 1.
    return 1
}
function mbfl_string_first () {
    mbfl_mandatory_parameter(STRING, 1, string)
    mbfl_mandatory_parameter(CHAR, 2, char)
    mbfl_optional_parameter(BEGIN, 3)
    local RESULT_VARNAME
    # Be  careful  to  return  the  same exit  status  of  the  call  to
    # "mbfl_string_first_var".
    if mbfl_string_first_var RESULT_VARNAME "$STRING" "$CHAR" "$BEGIN"
    then printf '%s\n' "$RESULT_VARNAME"
    else return $?
    fi
}

function mbfl_string_last_var () {
    mbfl_mandatory_nameref_parameter(RESULT_VARREF, 1, result variable name)
    mbfl_mandatory_parameter(STRING, 2, string)
    mbfl_mandatory_parameter(CHAR, 3, char)
    mbfl_optional_parameter(BEGIN, 4)
    local -i i
    for ((i=${BEGIN:-((${#STRING}-1))}; i >= 0; --i))
    do
	if test "${STRING:$i:1}" = "$CHAR"
	then
	    # Found!  Return with exit status 0.
            RESULT_VARREF=$i
	    return 0
        fi
    done
    # Not found!  Return with exit status 1.
    return 1
}
function mbfl_string_last () {
    mbfl_mandatory_parameter(STRING, 1, string)
    mbfl_mandatory_parameter(CHAR, 2, char)
    mbfl_optional_parameter(BEGIN, 3)
    local RESULT_VARNAME
    # Be  careful  to  return  the  same exit  status  of  the  call  to
    # "mbfl_string_last_var".
    if mbfl_string_last_var RESULT_VARNAME "$STRING" "$CHAR" "$BEGIN"
    then printf '%s\n' "$RESULT_VARNAME"
    else return $?
    fi
}

function mbfl_string_index_var () {
    mbfl_mandatory_nameref_parameter(RESULT_VARREF, 1, result variable name)
    mbfl_mandatory_parameter(STRING, 2, string)
    mbfl_mandatory_parameter(INDEX, 3, index)
    RESULT_VARREF=${STRING:$INDEX:1}
}
function mbfl_string_index () {
    mbfl_mandatory_parameter(STRING, 1, string)
    mbfl_mandatory_parameter(INDEX, 2, index)
    printf "${STRING:$INDEX:1}\n"
}

function mbfl_string_range_var () {
    mbfl_mandatory_nameref_parameter(RESULT_VARREF, 1, result variable name)
    mbfl_mandatory_parameter(STRING, 2, string)
    mbfl_mandatory_parameter(BEGIN, 3, begin)
    mbfl_optional_parameter(END, 4)
    if test -z "$END" -o "$END" = 'end' -o "$END" = 'END'
    then RESULT_VARREF=${STRING:$BEGIN}
    else RESULT_VARREF=${STRING:$BEGIN:$END}
    fi
}
function mbfl_string_range () {
    mbfl_mandatory_parameter(STRING, 1, string)
    mbfl_mandatory_parameter(BEGIN, 2, begin)
    mbfl_optional_parameter(END, 3)
    local RESULT_VARNAME
    if mbfl_string_range_var RESULT_VARNAME "$STRING" "$BEGIN" "$END"
    then printf '%s\n' "$RESULT_VARNAME"
    else return $?
    fi
}

#page
function mbfl_string_chars () {
    mbfl_mandatory_parameter(STRING, 1, string)
    local -i i j
    local ch
    for ((i=0, j=0; i < ${#STRING}; ++i, ++j))
    do
        ch="${STRING:$i:1}"
        if test "$ch" != $'\\'
        then SPLITFIELD[$j]="$ch"
        else
            let ++i
            if test $i != ${#STRING}
            then SPLITFIELD[$j]="${ch}${STRING:$i:1}"
            else SPLITFIELD[$j]="$ch"
            fi
        fi
    done
    SPLITCOUNT=$j
    return 0
}
#page
function mbfl_string_equal_substring () {
    mbfl_mandatory_parameter(STRING, 1, string)
    mbfl_mandatory_parameter(POSITION, 2, position)
    mbfl_mandatory_parameter(PATTERN, 3, pattern)
    local i
    test $(($POSITION+${#PATTERN})) -gt ${#STRING} && return 1
    for ((i=0; $i < "${#PATTERN}"; ++i))
    do test "${PATTERN:$i:1}" != "${STRING:$(($POSITION+$i)):1}" && \
        return 1
    done
    return 0
}
function mbfl_string_split () {
    mbfl_mandatory_parameter(STRING, 1, string)
    mbfl_mandatory_parameter(SEPARATOR, 2, separator)
    local i j k=0 first=0
    for ((i=0; $i < ${#STRING}; ++i))
    do
        test $(($i+${#SEPARATOR})) -gt ${#STRING} && break
        mbfl_string_equal_substring "${STRING}" $i "${SEPARATOR}" && {
            # here $i is the index of the first char in the separator
            SPLITFIELD[$k]="${STRING:$first:$(($i-$first))}"
            let ++k
            i=$(($i+${#SEPARATOR}-1))
	    # place the "first" marker to the beginning of the
	    # next substring; "i" will be incremented by "for",
	    # that is why we do "+1" here
            first=$(($i+1))
        }
    done
    SPLITFIELD[$k]="${STRING:$first}"
    let ++k
    SPLITCOUNT=$k
    return 0
}
#page
function mbfl_string_equal () {
    mbfl_optional_parameter(STR1, 1)
    mbfl_optional_parameter(STR2, 2)
    test "$STR1" '=' "$STR2"
}
function mbfl_string_not_equal () {
    mbfl_optional_parameter(STR1, 1)
    mbfl_optional_parameter(STR2, 2)
    test "$STR1" '!=' "$STR2"
}

function mbfl_string_less () {
    mbfl_optional_parameter(STR1, 1)
    mbfl_optional_parameter(STR2, 2)
    test "$STR1" '<' "$STR2"
}

function mbfl_string_greater () {
    mbfl_optional_parameter(STR1, 1)
    mbfl_optional_parameter(STR2, 2)
    test "$STR1" '>' "$STR2"
}

function mbfl_string_less_or_equal () {
    mbfl_optional_parameter(STR1, 1)
    mbfl_optional_parameter(STR2, 2)
    test "$STR1" '<' "$STR2" -o "$STR1" '=' "$STR2"
}

function mbfl_string_greater_or_equal () {
    mbfl_optional_parameter(STR1, 1)
    mbfl_optional_parameter(STR2, 2)
    test "$STR1" '>' "$STR2" -o "$STR1" '=' "$STR2"
}
#page
function mbfl_string_is_alpha_char () {
    mbfl_mandatory_parameter(CHAR, 1, char)
    ! test \( "${CHAR}" \< A -o Z \< "${CHAR}" \) -a \( "${CHAR}" \< a -o z \< "${CHAR}" \)
}
function mbfl_string_is_digit_char () {
    mbfl_mandatory_parameter(CHAR, 1, char)
    ! test "${CHAR}" \< 0 -o 9 \< "${CHAR}"
}
function mbfl_string_is_alnum_char () {
    mbfl_mandatory_parameter(CHAR, 1, char)
    mbfl_string_is_alpha_char "${CHAR}" || mbfl_string_is_digit_char "${CHAR}"
}
function mbfl_string_is_name_char () {
    mbfl_mandatory_parameter(CHAR, 1, char)
    mbfl_string_is_alnum_char "${CHAR}" || test "${CHAR}" = _
}
function mbfl_string_is_identifier_char () {
    mbfl_mandatory_parameter(CHAR, 1, char)
    mbfl_string_is_alnum_char "${CHAR}" || test "${CHAR}" = '_' -o "${CHAR}" = '-'
}
function mbfl_string_is_extended_identifier_char () {
    mbfl_mandatory_parameter(CHAR, 1, char)
    mbfl_string_is_alnum_char "${CHAR}" || test "${CHAR}" = '_' -o "${CHAR}" = '-' -o "${CHAR}" = '.'
}
function mbfl_string_is_noblank_char () {
    mbfl_mandatory_parameter(CHAR, 1, char)
    test \( "${CHAR}" != " " \) -a \
	\( "${CHAR}" != $'\n' \) -a \( "${CHAR}" != $'\r' \) -a \
	\( "${CHAR}" != $'\t' \) -a \( "${CHAR}" != $'\f' \)
}
for class in alpha digit alnum noblank ; do
    alias "mbfl_string_is_${class}"="mbfl_p_string_is $class"
done
function mbfl_p_string_is () {
    mbfl_mandatory_parameter(CLASS, 1, class)
    # Accept $2  even if  it is  empty; for  this reason  we do  not use
    # MBFL_MANDATORY_PARAMETER.
    local STRING=$2
    local -i i
    test ${#STRING} = 0 && return 1
    for ((i=0; $i < ${#STRING}; ++i))
    do "mbfl_string_is_${CLASS}_char" "${STRING:$i:1}" || return 1
    done
    return 0
}
function mbfl_string_is_name () {
    # Accept $1  even if  it is  empty; for  this reason  we do  not use
    # MBFL_MANDATORY_PARAMETER.
    local STRING=$1
    test -n "$STRING" && \
	mbfl_p_string_is name "${STRING}" && ! mbfl_string_is_digit "${STRING:0:1}"
}
function mbfl_string_is_identifier () {
    # Accept $1  even if  it is  empty; for  this reason  we do  not use
    # MBFL_MANDATORY_PARAMETER.
    local STRING=$1
    test -n "$STRING" && \
	mbfl_p_string_is identifier "${STRING}"		\
	&& ! mbfl_string_is_digit "${STRING:0:1}"	\
	&& ! test "${STRING:0:1}" = '-'
}
function mbfl_string_is_extended_identifier () {
    # Accept $1  even if  it is  empty; for  this reason  we do  not use
    # MBFL_MANDATORY_PARAMETER.
    local STRING=$1
    test -n "$STRING" && \
	mbfl_p_string_is extended_identifier "${STRING}"	\
	&& ! mbfl_string_is_digit "${STRING:0:1}"		\
	&& ! test "${STRING:0:1}" = '-'
}
function mbfl_string_is_username () {
    # Accept $1  even if  it is  empty; for  this reason  we do  not use
    # MBFL_MANDATORY_PARAMETER.
    local STRING=$1
    test -n "$STRING" && \
	mbfl_string_is_identifier "${STRING}"
}
#page
function mbfl_string_replace () {
    mbfl_mandatory_parameter(STRING, 1, string)
    mbfl_mandatory_parameter(PATTERN, 2, pattern)
    mbfl_optional_parameter(SUBST, 3)
    printf "${STRING//$PATTERN/$SUBST}\n"
}
function mbfl_string_skip () {
    mbfl_mandatory_parameter(STRING, 1, string)
    mbfl_mandatory_parameter(POSNAME, 2, position)
    mbfl_mandatory_parameter(CHAR, 3, char)
    local position=${!POSNAME}
    while test "${STRING:$position:1}" = "$CHAR" ; do let ++position ; done
    eval $POSNAME=$position
}
#page
function mbfl_string_toupper () {
    mbfl_p_string_uplo toupper "${1}"
}
function mbfl_string_tolower () {
    mbfl_p_string_uplo tolower "${1}"
}
function mbfl_p_string_uplo () {
    mbfl_mandatory_parameter(MODE, 1, mode)
    mbfl_optional_parameter(STRING, 2)
    local ch lower upper flag=0
    test ${#STRING} = 0 && return 0
    for ch in \
        a A b B c C d D e E f F g G h H i I j J k K l L m M \
        n N o O p P q Q r R s S t T u U v V w W x X y Y z Z
    do
      if test $flag = 0
      then
          lower=$ch
          flag=1
      else
          upper=$ch
          if test "${MODE}" = toupper
          then STRING="${STRING//$lower/$upper}"
          else STRING="${STRING//$upper/$lower}"
          fi
          flag=0
      fi
    done
    printf "${STRING}\n"
    return 0
}
#page
function mbfl_sprintf () {
    local VARNAME="${1:?missing variable name parameter in ${FUNCNAME}}"
    local FORMAT="${2:?missing format parameter in ${FUNCNAME}}"
    local OUTPUT=
    shift 2
    OUTPUT=$(printf "${FORMAT}" "$@")
    eval "${VARNAME}"=\'"${OUTPUT}"\'
}

### end of file
# Local Variables:
# mode: sh
# End:
