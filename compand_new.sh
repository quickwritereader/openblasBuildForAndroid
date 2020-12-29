#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
BASE_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

function message {
    echo ":: ${@}"
}

function rename_top_folder {
    for dir in ${1}/*
    do
        if [ -d "$dir" ]
        then
            mv "${dir}" "${1}/folder/"
            message "${dir} => ${1}/folder/"
            break
        fi
    done
}

function check_requirements {
    for i in "${@}"
    do
      if [ ! -e "$i" ]; then
         message "missing: ${i}"
         exit -2
      fi
    done
}

function git_check {
    #$1 is url #$2 is dir #$3 is tag or branch if optional
    command=
    if [ -n "$3" ]; then
        command="git clone --quiet --depth 1 --branch ${3} ${1} ${2}"    
    else 
    command="git clone --quiet ${1} ${2}"
    fi
    message "$command"
    $command 
    check_requirements "${2}"
}

function download_extract_base {
	#$1 is url #2 is dir $3 is extract argument
	if [ ! -f ${3}_file ]; then
		message "download"
		wget --quiet --show-progress -O ${3}_file ${2}
	fi
 
	message "extract $@"
    #extract
	mkdir -p ${3} 
	if [ ${1} = "-unzip" ]; then
		command="unzip -qq ${3}_file -d ${3} "
	else
		command="tar ${1}  ${3}_file --directory=${3} "
	fi
	message $command
	$command
	check_requirements "${3}"
}

function download_extract {
	download_extract_base -xzf $@
}

function download_extract_xz {
	download_extract_base -xf $@
}

function download_extract_unzip {
	download_extract_base -unzip $@
}

ANDROID_API=21
TARGET_ARRS=( "armv7a" "arm64-v8a" "x86" "x86_64" )
OPENBLAS_TARGETS=( "ARMV7" "ARMV8" "ATOM" "ATOM" )
COMPILER_PREFIXES=( "armv7a-linux-androideabi" "aarch64-linux-android" "i686-linux-android" "x86_64-linux-android" )
TOOLCHAIN_PREFIXES=( "arm-linux-androideabi" "aarch64-linux-android" "i686-linux-android" "x86_64-linux-android" )
XTRA_FLAGS=( "ARM_SOFTFP_ABI=1" " BINARY=64" "" " BINARY=64" )
NDK_URL="https://dl.google.com/android/repository/android-ndk-r21d-linux-x86_64.zip"
NDK_DIR="${BASE_DIR}/compile_tools/"
OPENBLAS_GIT_URL="https://github.com/xianyi/OpenBLAS.git"
OPENBLAS_DIR=${BASE_DIR}/OpenBLAS
mkdir -p ${NDK_DIR}
mkdir -p ${BASE_DIR}
mkdir -p ${BASE_DIR}/output_new
#change directory to base
cd $BASE_DIR

if [ ! -d ${NDK_DIR}/folder ]; then
    #out file
    message "download NDK"
    download_extract_unzip ${NDK_URL} ${NDK_DIR}
    message "rename top folder"
    rename_top_folder ${NDK_DIR}
fi

NDK_DIR="${NDK_DIR}/folder"
ANDROID_TOOLCHAIN=${NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64

#lets build OpenBlas 
if [ ! -d "${OPENBLAS_DIR}" ]; then
    message "download OpenBLAS"
    git_check "${OPENBLAS_GIT_URL}" "${OPENBLAS_DIR}" "v0.3.10"
fi
cd ${OPENBLAS_DIR}

for i in "${!TARGET_ARRS[@]}"; do

TARGET=${OPENBLAS_TARGETS[$i]}
DEST_DIR="${BASE_DIR}/output_new/${TARGET_ARRS[${i}]}"
COMPILER_PREFIX="${ANDROID_TOOLCHAIN}/bin/${COMPILER_PREFIXES[$i]}${ANDROID_API}"
TOOLCHAIN_PREFIX="${ANDROID_TOOLCHAIN}/bin/${TOOLCHAIN_PREFIXES[$i]}"
XTRA="CC=${COMPILER_PREFIX}-clang AR=${TOOLCHAIN_PREFIX}-ar RANLIB=${TOOLCHAIN_PREFIX}-ranlib ${XTRA_FLAGS[$i]} "
check_requirements ${COMPILER_PREFIX}-clang
make clean
message "build and install OpenBLAS" 
command="make TARGET=${TARGET} HOSTCC=gcc NOFORTRAN=1 ${XTRA} "
message $command
eval $command  &>/dev/null
message "install it"
mkdir -p ${DEST_DIR}
command="make TARGET=${TARGET} PREFIX=${DEST_DIR} install  &>dev/null"
message $command
$command
check_requirements ${DEST_DIR}/lib/libopenblas.so

done
