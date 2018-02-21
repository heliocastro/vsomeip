#.rst:
# FindMBEDTLS
# --------
#
# Find the native MBEDTLS includes and library.
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
#
# This module defines :prop_tgt:`IMPORTED` target ``mbedtls::mbedtls``,
# ``mbedtls::mbedx509``, ``mbedtls::mbedcrypto``,
# if MBEDTLS has been found.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module defines the following variables:
#
# ::
#
#   MBEDTLS_INCLUDE_DIRS   - Where to find the headers.
#   MBEDTLS_LIBRARIES      - List of libraries.
#   MBEDTLS_LIBRARY_CRYPTO - Crypto library
#   MBEDTLS_LIBRARY_TLS    - TLS library
#   MBEDTLS_LIBRARY_X509   - X509 library
#   MBEDTLS_FOUND          - True if mbedtls found.
#
# ::
#
#   MBEDTLS_VERSION_STRING - The version
#   MBEDTLS_VERSION_MAJOR  - The major version
#   MBEDTLS_VERSION_MINOR  - The minor version
#   MBEDTLS_VERSION_PATCH  - The patch version

set(_MBEDTLS_SEARCHES)

# Try each search configuration.
find_path(MBEDTLS_INCLUDE_DIR NAMES platform.h ssl.h PATH_SUFFIXES include/mbedtls)

# Allow MBEDTLS_LIBRARY to be set manually, as the location of the zlib library
if(NOT MBEDTLS_LIBRARY)
    find_library(MBEDTLS_LIBRARY_CRYPTO NAMES mbedcrypto)
    find_library(MBEDTLS_LIBRARY_TLS NAMES mbedtls)
    find_library(MBEDTLS_LIBRARY_X509 NAMES mbedx509)
    include(SelectLibraryConfigurations)
    select_library_configurations(MBEDTLS)
endif()

mark_as_advanced(MBEDTLS_INCLUDE_DIR)

if(MBEDTLS_INCLUDE_DIR AND EXISTS "${MBEDTLS_INCLUDE_DIR}/version.h")
    file(STRINGS "${MBEDTLS_INCLUDE_DIR}/version.h" MBEDTLS_H
        REGEX "^#define MBEDTLS_VERSION_STRING.*\"[^\"]*\"$")

    string(REGEX REPLACE "^.*MBEDTLS_VERSION_STRING.*\"([0-9]+).*$" "\\1" MBEDTLS_VERSION_MAJOR "${MBEDTLS_H}")
    string(REGEX REPLACE "^.*MBEDTLS_VERSION_STRING.*\"[0-9]+\\.([0-9]+).*$" "\\1" MBEDTLS_VERSION_MINOR "${MBEDTLS_H}")
    string(REGEX REPLACE "^.*MBEDTLS_VERSION_STRING.*\"[0-9]+\\.[0-9]+\\.([0-9]+).*$" "\\1"
        MBEDTLS_VERSION_PATCH "${MBEDTLS_H}")
    set(MBEDTLS_VERSION_STRING "${MBEDTLS_VERSION_MAJOR}.${MBEDTLS_VERSION_MINOR}.${MBEDTLS_VERSION_PATCH}")

    set(MBEDTLS_MAJOR_VERSION "${MBEDTLS_VERSION_MAJOR}")
    set(MBEDTLS_MINOR_VERSION "${MBEDTLS_VERSION_MINOR}")
    set(MBEDTLS_PATCH_VERSION "${MBEDTLS_VERSION_PATCH}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MBEDTLS REQUIRED_VARS
    MBEDTLS_LIBRARY_CRYPTO
    MBEDTLS_LIBRARY_TLS
    MBEDTLS_LIBRARY_X509
    MBEDTLS_INCLUDE_DIR
    VERSION_VAR
    MBEDTLS_VERSION_STRING
    )

if(MBEDTLS_FOUND)
    set(MBEDTLS_INCLUDE_DIRS ${MBEDTLS_INCLUDE_DIR})

    if(NOT MBEDTLS_LIBRARIES)
        set(MBEDTLS_LIBRARIES ${MBEDTLS_LIBRARY_CRYPTO} ${MBEDTLS_LIBRARY_TLS} ${MBEDTLS_LIBRARY_X509})
    endif()

    if(NOT TARGET mbedtls::mbedtls)
        add_library(mbedtls::mbedtls UNKNOWN IMPORTED)
        set_target_properties(mbedtls::mbedtls PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MBEDTLS_INCLUDE_DIRS}")
        set_property(TARGET mbedtls::mbedtls APPEND PROPERTY
            IMPORTED_LOCATION "${MBEDTLS_LIBRARY_TLS}")
    endif()

    if(NOT TARGET mbedtls::mbedcrypto)
        add_library(mbedtls::mbedcrypto UNKNOWN IMPORTED)
        set_target_properties(mbedtls::mbedcrypto PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MBEDTLS_INCLUDE_DIRS}")
        set_property(TARGET mbedtls::mbedcrypto APPEND PROPERTY
            IMPORTED_LOCATION "${MBEDTLS_LIBRARY_CRYPTO}")
    endif()

    if(NOT TARGET mbedtls::mbedx590)
        add_library(mbedtls::mbedx590 UNKNOWN IMPORTED)
        set_target_properties(mbedtls::mbedx590 PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MBEDTLS_INCLUDE_DIRS}")
        set_property(TARGET mbedtls::mbedx590 APPEND PROPERTY
            IMPORTED_LOCATION "${MBEDTLS_LIBRARY_X509}")
    endif()
endif()
