include(ExternalProject)

set(LIBJPEG_TURBO_NAME libjpeg-turbo)
set(LIBJPEG_WORK_DIR ${PROJECT_SOURCE_DIR}/third_party)
set(LIBJPEG_TURBO_BUILD_DIR ${PROJECT_BINARY_DIR}/third_party/${LIBJPEG_TURBO_NAME})
set(LIBJPEG_TURBO_INSTALL_DIR ${LIBJPEG_TURBO_BUILD_DIR}/output)

set(LIBJPEG_CMAKE_ARGS)
list(APPEND LIBJPEG_CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${LIBJPEG_TURBO_INSTALL_DIR}
        -DCMAKE_TOOLCHAIN_FILE:PATH=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_BUILD_TYPE=Release
        -DENABLE_SHARED=OFF)

if(NOT APPLE)
    list(APPEND LIBJPEG_CMAKE_ARGS
        -DCMAKE_CXX_FLAGS:STRING="-fPIC"
        -DCMAKE_CXX_FLAGS:STRING="-w"
        -DCMAKE_C_FLAGS:STRING="-fPIC"
        -DCMAKE_C_FLAGS:STRING="-w")
    list(APPEND LIBJPEG_CMAKE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
endif()

if(ANDROID)
    list(APPEND LIBJPEG_CMAKE_ARGS
            -DCMAKE_SYSTEM_NAME=Android
            -DANDROID_ABI=${ANDROID_ABI}
            -DANDROID_PLATFORM=${ANDROID_PLATFORM}
            -DANDROID_ARM_NEON=${ANDROID_ARM_NEON})
elseif(APPLE)
    if(IOS)
        list(APPEND LIBJPEG_CMAKE_ARGS "-DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}"
                "-DCMAKE_TOOLCHAIN_FILE=././cmake/platform/ios/toolchain/iOS.cmake")
    else()
        list(APPEND LIBJPEG_CMAKE_ARGS "-DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}")
    endif()
elseif(UNIX)
    list(APPEND LIBJPEG_CMAKE_ARGS -DCMAKE_SYSTEM_PROCESSOR=${CMAKE_SYSTEM_PROCESSOR})
endif()

fcv_download_dependency(
    "https://github.com/libjpeg-turbo/libjpeg-turbo.git"
    2.1.4
    ${LIBJPEG_TURBO_NAME}
    ${LIBJPEG_WORK_DIR}
    )

if(WIN32)
    set(JPEG_LIB_NAME "turbojpeg-static.lib")
else()
    set(JPEG_LIB_NAME "libturbojpeg.a")
endif()

if(UNIX AND NOT ANDROID AND NOT APPLE)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(LIBJPEG_TURBO_LIB_PATH lib64)
        list(APPEND LIBJPEG_CMAKE_ARGS -DCMAKE_INSTALL_LIBDIR:PATH=${LIBJPEG_TURBO_INSTALL_DIR}/${LIBJPEG_TURBO_LIB_PATH})
    else(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(LIBJPEG_TURBO_LIB_PATH lib)
    endif(CMAKE_SIZEOF_VOID_P EQUAL 8)
else()
    set(LIBJPEG_TURBO_LIB_PATH lib)
endif()

ExternalProject_Add(
    ${LIBJPEG_TURBO_NAME}
    PREFIX ${LIBJPEG_WORK_DIR}/${LIBJPEG_TURBO_NAME}
    CMAKE_ARGS ${LIBJPEG_CMAKE_ARGS}
    SOURCE_DIR ${LIBJPEG_WORK_DIR}/${LIBJPEG_TURBO_NAME}
    TMP_DIR ${LIBJPEG_TURBO_BUILD_DIR}/tmp
    BINARY_DIR ${LIBJPEG_TURBO_BUILD_DIR}
    STAMP_DIR ${LIBJPEG_TURBO_BUILD_DIR}/stamp
    BUILD_BYPRODUCTS ${LIBJPEG_TURBO_INSTALL_DIR}/${LIBJPEG_TURBO_LIB_PATH}/${JPEG_LIB_NAME}
)

add_library(fcv_jpeg STATIC IMPORTED)

set_property(TARGET fcv_jpeg
        PROPERTY IMPORTED_LOCATION
        ${LIBJPEG_TURBO_INSTALL_DIR}/${LIBJPEG_TURBO_LIB_PATH}/${JPEG_LIB_NAME})

include_directories(${LIBJPEG_TURBO_INSTALL_DIR}/include)
list(APPEND FCV_LINK_DEPS fcv_jpeg)

if(NOT BUILD_SHARED_LIBS)
	list(APPEND FCV_EXPORT_LIBS ${LIBJPEG_TURBO_INSTALL_DIR}/${LIBJPEG_TURBO_LIB_PATH}/${JPEG_LIB_NAME})
endif()

list(APPEND FCV_EXTERNAL_DEPS ${LIBJPEG_TURBO_NAME})
