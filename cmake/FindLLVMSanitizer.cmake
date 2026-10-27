# FindLLVMSanitizer.cmake
# Dynamically locate LLVM installation, compilers, and sanitizer runtime libraries
# Supports Windows LLVM on PATH, an explicit LLVM_ROOT, and Linux.

function(find_llvm_root OUTPUT_VAR ARCH)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        # On Linux, clang is on PATH; no separate LLVM root needed
        set(${OUTPUT_VAR} "" PARENT_SCOPE)
        return()
    endif()
    if(NOT ARCH STREQUAL "x86" AND NOT ARCH STREQUAL "x64")
        message(FATAL_ERROR "Unsupported architecture: ${ARCH}")
    endif()

    # An explicit selection must never silently fall back to a different compiler.
    set(_llvm_root "${LLVM_ROOT}")
    if(NOT _llvm_root AND DEFINED ENV{LLVM_ROOT})
        set(_llvm_root "$ENV{LLVM_ROOT}")
    endif()
    if(_llvm_root)
        file(TO_CMAKE_PATH "${_llvm_root}" _llvm_root)
        if(NOT EXISTS "${_llvm_root}/bin/clang-cl.exe")
            message(FATAL_ERROR "LLVM_ROOT does not contain bin/clang-cl.exe: ${_llvm_root}")
        endif()
    else()
        find_program(_llvm_clang_cl NAMES clang-cl
            HINTS "$ENV{ProgramFiles}/LLVM/bin" "$ENV{ProgramFiles\(x86\)}/LLVM/bin"
            NO_CACHE)
        if(NOT _llvm_clang_cl)
            message(FATAL_ERROR "LLVM not found. Put clang-cl on PATH or set LLVM_ROOT. On Windows use scripts/windows-build.ps1.")
        endif()
        get_filename_component(_llvm_bin "${_llvm_clang_cl}" DIRECTORY)
        get_filename_component(_llvm_root "${_llvm_bin}" DIRECTORY)
    endif()
    set(${OUTPUT_VAR} "${_llvm_root}" PARENT_SCOPE)
endfunction()

function(find_llvm_compilers ARCH)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        find_program(CLANG_C   NAMES clang   REQUIRED)
        find_program(CLANG_CXX NAMES clang++ REQUIRED)
        set(CMAKE_C_COMPILER   "${CLANG_C}"   CACHE FILEPATH "C compiler"   FORCE)
        set(CMAKE_CXX_COMPILER "${CLANG_CXX}" CACHE FILEPATH "C++ compiler" FORCE)
        message(STATUS "Found LLVM compilers (Linux): ${CLANG_C}")
        return()
    endif()
    find_llvm_root(LLVM_ROOT ${ARCH})
    
    set(CLANG_CL "${LLVM_ROOT}/bin/clang-cl.exe")
    set(LLVM_RC "${LLVM_ROOT}/bin/llvm-rc.exe")
    
    if(EXISTS "${CLANG_CL}")
        set(CMAKE_C_COMPILER "${CLANG_CL}" CACHE FILEPATH "C compiler" FORCE)
        set(CMAKE_CXX_COMPILER "${CLANG_CL}" CACHE FILEPATH "C++ compiler" FORCE)
        set(CMAKE_RC_COMPILER "${LLVM_RC}" CACHE FILEPATH "Resource compiler" FORCE)
        message(STATUS "Found LLVM compilers (${ARCH}): ${CLANG_CL}")
    else()
        message(FATAL_ERROR "clang-cl.exe not found at ${CLANG_CL}")
    endif()
endfunction()

function(find_asan_runtime OUTPUT_VAR ARCH)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(${OUTPUT_VAR} "" PARENT_SCOPE)
        return()
    endif()
    find_llvm_root(LLVM_DIR ${ARCH})
    
    if(ARCH STREQUAL "x86")
        set(RT_NAME "clang_rt.asan_dynamic-i386.dll")
    else()
        set(RT_NAME "clang_rt.asan_dynamic-x86_64.dll")
    endif()
    
    # Search for the runtime in LLVM lib directory (any version)
    file(GLOB_RECURSE ASAN_DLL 
        "${LLVM_DIR}/lib/clang/*/lib/windows/${RT_NAME}"
    )
    
    if(ASAN_DLL)
        list(GET ASAN_DLL 0 ASAN_DLL_PATH)  # Take first match (latest version)
        set(${OUTPUT_VAR} "${ASAN_DLL_PATH}" PARENT_SCOPE)
        message(STATUS "Found ASan runtime (${ARCH}): ${ASAN_DLL_PATH}")
    else()
        message(WARNING "ASan runtime ${RT_NAME} not found in ${LLVM_DIR}")
        set(${OUTPUT_VAR} "" PARENT_SCOPE)
    endif()
endfunction()

function(find_asan_import_lib OUTPUT_VAR ARCH)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(${OUTPUT_VAR} "" PARENT_SCOPE)
        return()
    endif()
    find_llvm_root(LLVM_DIR ${ARCH})
    
    if(ARCH STREQUAL "x86")
        set(RT_THUNK "clang_rt.asan_dynamic_runtime_thunk-i386.lib")
        set(RT_IMPLIB "clang_rt.asan_dynamic-i386.lib")
    else()
        set(RT_THUNK "clang_rt.asan_dynamic_runtime_thunk-x86_64.lib")
        set(RT_IMPLIB "clang_rt.asan_dynamic-x86_64.lib")
    endif()
    
    # Search for LLVM lib directory
    file(GLOB LLVM_LIB_DIRS "${LLVM_DIR}/lib/clang/*/lib/windows")
    
    if(LLVM_LIB_DIRS)
        list(GET LLVM_LIB_DIRS 0 LLVM_LIB_DIR)  # Take first match
        set(${OUTPUT_VAR} "${LLVM_LIB_DIR}" PARENT_SCOPE)
        message(STATUS "Found LLVM lib directory (${ARCH}): ${LLVM_LIB_DIR}")
    else()
        message(WARNING "LLVM lib directory not found in ${LLVM_DIR}")
        set(${OUTPUT_VAR} "" PARENT_SCOPE)
    endif()
endfunction()
