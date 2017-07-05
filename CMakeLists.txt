cmake_minimum_required (VERSION 2.8.11)
project (XRayLib)


include(CheckFunctionExists)
CHECK_FUNCTION_EXISTS(strdup  HAVE_STRDUP)
CHECK_FUNCTION_EXISTS(strndup  HAVE_STRNDUP)

include (CheckIncludeFiles)
CHECK_INCLUDE_FILES(search.h HAVE_SEARCH_H)

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/src/config.h.in.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/src/config.h"
)

include_directories (${CMAKE_CURRENT_BINARY_DIR}/src src include)

set (prdata_SRC_FILES
 "${CMAKE_CURRENT_BINARY_DIR}/src/config.h"
 "src/pr_data.c"
 "src/xrayvars.c"
 "src/xrayglob.c"
 "src/xrayfiles.c"
 "src/fluor_yield.c"
 "src/coskron.c"
 "src/crystal_diffraction.c"
 "src/scattering.c"
 "src/fi.c"
 "src/fii.c"
 "src/splint.c"
)

if (NOT CMAKE_CROSSCOMPILING)
  add_executable ( prdata ${prdata_SRC_FILES} )
  CHECK_FUNCTION_EXISTS(pow RESULT)
  if(NOT RESULT)
    target_link_libraries(prdata m)
  endif()

  export(
    TARGETS prdata
    FILE "${CMAKE_BINARY_DIR}/ImportExecutables.cmake"
  )
else()
  set (IMPORT_EXECUTABLES "IMPORTFILE-NOTFOUND" CACHE FILEPATH "Point it to the export file from a native build")
  include (${IMPORT_EXECUTABLES})
endif()


set (xraylib_SRC_FILES
  "${CMAKE_CURRENT_BINARY_DIR}/src/config.h"
  "xrayglob_inline.c"
  "src/xrayvars.c"
  "src/cross_sections.c"
  "src/scattering.c"
  "src/atomicweight.c"
  "src/edges.c"
  "src/fluor_lines.c"
  "src/fluor_yield.c"
  "src/jump.c"
  "src/coskron.c"
  "src/radrate.c"
  "src/cs_line.c"
  "src/polarized.c"
  "src/splint.c"
  "src/cs_barns.c"
  "src/fi.c"
  "src/fii.c"
  "src/kissel_pe.c"
  "src/xrayfiles_inline.c"
  "src/xraylib-aux.c"
  "src/xraylib-parser.c"
  "src/cs_cp.c"
  "src/refractive_indices.c"
  "src/comptonprofiles.c"
  "src/atomiclevelwidth.c"
  "src/auger_trans.c"
  "src/xrf_cross_sections_aux.c"
  "src/crystal_diffraction.c"
  "src/densities.c"
)

if( HAVE_SEARCH_H )
  set (xraylib_SRC_FILES "${xraylib_SRC_FILES}"
    "src/xraylib-nist-compounds.c"
    "src/xraylib-radionuclides.c"
  )
endif()

add_library ( XRayLib ${xraylib_SRC_FILES} )
add_custom_command(
  OUTPUT xrayglob_inline.c
  COMMAND ${CMAKE_COMMAND} -E env "XRAYLIB_DIR=${CMAKE_CURRENT_SOURCE_DIR}" $<TARGET_FILE:prdata>
  DEPENDS prdata
)



# Define headers for this library. PUBLIC headers are used for
# compiling the library, and will be added to consumers' build
# paths.
target_include_directories(XRayLib PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
    PRIVATE src)

install (
  TARGETS XRayLib EXPORT XRayLibConfig
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin # this is for Windows
)
install (DIRECTORY include/ DESTINATION include)


# This make the project importable from the install directory
# put the config file in per-project dir (name MUST match), can also
# just go into <prefix>/cmake
install (EXPORT XRayLibConfig DESTINATION cmake)

# This makes the project importable from the build directory
export (TARGETS XRayLib FILE XRayLibConfig.cmake)
export (PACKAGE XRayLib)
