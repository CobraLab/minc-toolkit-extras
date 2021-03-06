#!/bin/bash
# ARG_HELP([The general script's help msg])
# ARG_POSITIONAL_SINGLE([movingfile],[The moving image])
# ARG_POSITIONAL_SINGLE([fixedfile],[The fixed image])
# ARG_POSITIONAL_SINGLE([outputfile],[The output transform])
# ARG_OPTIONAL_SINGLE([moving-mask],[],[Mask for moving image],[NOMASK])
# ARG_OPTIONAL_SINGLE([fixed-mask],[],[Mask for fixed image],[NOMASK])
# ARG_OPTIONAL_SINGLE([resampled-output],[],[Output resampled file])
# ARG_OPTIONAL_BOOLEAN([clobber],[],[Overwrite files that already exist])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.8.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info


die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}


begins_with_short_option()
{
	local first_option all_short_options='h'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_moving_mask="NOMASK"
_arg_fixed_mask="NOMASK"
_arg_resampled_output=
_arg_clobber="off"


print_help()
{
	printf '%s\n' "The general script's help msg"
	printf 'Usage: %s [-h|--help] [--moving-mask <arg>] [--fixed-mask <arg>] [--resampled-output <arg>] [--(no-)clobber] <movingfile> <fixedfile> <outputfile>\n' "$0"
	printf '\t%s\n' "<movingfile>: The moving image"
	printf '\t%s\n' "<fixedfile>: The fixed image"
	printf '\t%s\n' "<outputfile>: The output transform"
	printf '\t%s\n' "-h, --help: Prints help"
	printf '\t%s\n' "--moving-mask: Mask for moving image (default: 'NOMASK')"
	printf '\t%s\n' "--fixed-mask: Mask for fixed image (default: 'NOMASK')"
	printf '\t%s\n' "--resampled-output: Output resampled file (no default)"
	printf '\t%s\n' "--clobber, --no-clobber: Overwrite files that already exist (off by default)"
}


parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			--moving-mask)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_moving_mask="$2"
				shift
				;;
			--moving-mask=*)
				_arg_moving_mask="${_key##--moving-mask=}"
				;;
			--fixed-mask)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_fixed_mask="$2"
				shift
				;;
			--fixed-mask=*)
				_arg_fixed_mask="${_key##--fixed-mask=}"
				;;
			--resampled-output)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_resampled_output="$2"
				shift
				;;
			--resampled-output=*)
				_arg_resampled_output="${_key##--resampled-output=}"
				;;
			--no-clobber|--clobber)
				_arg_clobber="on"
				test "${1:0:5}" = "--no-" && _arg_clobber="off"
				;;
			*)
				_last_positional="$1"
				_positionals+=("$_last_positional")
				_positionals_count=$((_positionals_count + 1))
				;;
		esac
		shift
	done
}


handle_passed_args_count()
{
	local _required_args_string="'movingfile', 'fixedfile' and 'outputfile'"
	test "${_positionals_count}" -ge 3 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 3 (namely: $_required_args_string), but got only ${_positionals_count}." 1
	test "${_positionals_count}" -le 3 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 3 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names="_arg_movingfile _arg_fixedfile _arg_outputfile "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

set -euo pipefail

tmpdir=$(mktemp -d)

if [[ -s ${_arg_outputfile} && ! ${_arg_clobber} == "on" ]]; then
  echo "File ${_arg_outputfile} already exists!"
  exit 1
fi

if [[ -s ${_arg_resampled_output} && ! ${_arg_clobber} == "on" ]]; then
  echo "File ${_arg_resampled_output} already exists!"
  exit 1
fi

movingfile=${_arg_movingfile}
fixedfile=${_arg_fixedfile}

movingmask=${_arg_moving_mask}
fixedmask=${_arg_fixed_mask}

fixed_minimum_resolution=$(python -c "print(min([abs(x) for x in [float(x) for x in \"$(PrintHeader ${fixedfile} 1)\".split(\"x\")]]))")
fixed_maximum_resolution=$(python -c "print(max([ a*b for a,b in zip([abs(x) for x in [float(x) for x in \"$(PrintHeader ${fixedfile} 1)\".split(\"x\")]],[abs(x) for x in [float(x) for x in \"$(PrintHeader ${fixedfile} 2)\".split(\"x\")]])]))")

steps=$(ants_generate_iterations.py --min ${fixed_minimum_resolution} --max ${fixed_maximum_resolution} --output multilevel-halving)



antsRegistration --dimensionality 3 --verbose --minc \
  --output [ ${tmpdir}/reg ] \
  --use-histogram-matching 1 \
  --initial-moving-transform [ ${fixedfile},${movingfile},1 ] \
  $(eval echo ${steps})

cp ${tmpdir}/reg0_GenericAffine.xfm ${_arg_outputfile}

if [[ ${_arg_resampled_output} ]]; then
  antsApplyTransforms -d 3 -i ${movingfile} -r ${fixedfile} -t ${tmpdir}/reg0_GenericAffine.xfm -o ${tmpdir}/resample.mnc -n BSpline[5] --verbose
  mincmath -clobber -clamp -const2 0 $(mincstats -quiet -max ${tmpdir}/resample.mnc) ${tmpdir}/resample.mnc ${_arg_resampled_output}
fi


rm -rf ${tmpdir}

# ] <-- needed because of Argbash
