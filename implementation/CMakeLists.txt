# Avoid polute regular directories with generated files
configure_file(
    configuration/include/internal.hpp.in
    ${CMAKE_CURRENT_BINARY_DIR}/configuration/include/internal.hpp
)

# Base library
file(GLOB vsomeip_SRC
    "endpoints/src/*.cpp"
    "logging/src/*.cpp"
    "tracing/src/*.cpp"
    "message/src/*.cpp"
    "routing/src/*.cpp"
    "runtime/src/*.cpp"
    "utility/src/*.cpp"
)
list(APPEND vsomeip_SRC ${CMAKE_CURRENT_BINARY_DIR}/configuration/include/internal.hpp)
list(SORT vsomeip_SRC)

add_library(vsomeip SHARED ${vsomeip_SRC})
target_link_libraries(vsomeip
    PUBLIC
        mbedtls::mbedtls
        mbedtls::mbedcrypto
        ${DLT_LIBRARIES}
        Boost::system
        Boost::log
        Boost::regex
        Threads::Threads
    PRIVATE
        ${CMAKE_DL_LIBS}
        ${SystemD_LIBRARIES}
        ${ARA_SECOC_LIBRARY}
    )
target_compile_definitions(vsomeip PUBLIC ${OS_COMPILER_DEFINITIONS})
target_compile_options(vsomeip PUBLIC ${OS_COMPILER_FLAGS})
target_include_directories(vsomeip
    PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/interface>
        $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/implementation>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/helper>
    PRIVATE
        ${PROJECT_SOURCE_DIR}/include
        ${DLT_INCLUDE_DIRS}
    )

set_target_properties(vsomeip PROPERTIES
    SOVERSION ${PROJECT_VERSION_MAJOR}
    VERSION ${PROJECT_VERSION}
    LINK_FLAGS "-Wl,--as-needed -Wl,--no-undefined"
    CXX_STANDARD 14
    EXPORT_NAME vsomeip
    )

add_library(vsomeip::vsomeip ALIAS vsomeip)

if(MSVC)
    set_target_properties(vsomeip PROPERTIES COMPILE_DEFINITIONS "VSOMEIP_DLL_COMPILATION")
endif()

install(
    TARGETS vsomeip
    EXPORT vsomeipTargets
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    COMPONENT dev
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/vsomeipConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
    )

export(EXPORT vsomeipTargets
    FILE ${PROJECT_BINARY_DIR}/vsomeipTargets.cmake
    TARGETS vsomeip
    NAMESPACE vsomeip::
    EXPORT_LINK_INTERFACE_LIBRARIES
    )

# Export the aliases
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/vsomeipConfig.cmake
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/vsomeipTargets.cmake\")"
    "\n\nset(VSOMEIP_LIBRARIES vsomeip::vsomeip)"
    )

install(EXPORT vsomeipTargets
    FILE vsomeipTargets.cmake
    NAMESPACE vsomeip::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/vsomeip
    COMPONENT dev
    )

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/vsomeipConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/vsomeipConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/vsomeip
    COMPONENT dev
    )

# create pkg-config file
if(NOT WIN32)
    configure_file(${PROJECT_SOURCE_DIR}/vsomeip.pc.in
        ${PROJECT_BINARY_DIR}/vsomeip.pc @ONLY)
    install(FILES ${PROJECT_BINARY_DIR}/vsomeip.pc DESTINATION lib/pkgconfig)
endif()

add_subdirectory(configuration)
add_subdirectory(service_discovery)
