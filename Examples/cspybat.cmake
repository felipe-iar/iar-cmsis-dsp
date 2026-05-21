# CTest wrapper for CSpyBat

cmake_minimum_required(VERSION 3.20)

# Enable CTest
enable_testing()

cmake_path(GET CMAKE_C_COMPILER PARENT_PATH BIN_DIR)
cmake_path(GET BIN_DIR PARENT_PATH TOOLKIT_DIR)
cmake_path(GET TOOLKIT_DIR FILENAME TOOLKIT)
cmake_path(GET TOOLKIT_DIR PARENT_PATH IAR_ROOT_DIR)
set(COMMON_BIN_DIR "${IAR_ROOT_DIR}/common/bin")

function(iar_cspy_test TARGET RESULT)
  find_program(CSPY_BAT
    NAMES CSpyBat${CMAKE_HOST_EXECUTABLE_SUFFIX}
    PATHS ${COMMON_BIN_DIR}
    REQUIRED)
  find_library(CSPY_DRV_PROC
    NAMES ${CMAKE_SHARED_LIBRARY_PREFIX}${TOOLKIT}PROC${CMAKE_SHARED_LIBRARY_SUFFIX}
          ${CMAKE_SHARED_LIBRARY_PREFIX}${TOOLKIT}proc${CMAKE_SHARED_LIBRARY_SUFFIX}
    PATHS ${BIN_DIR}
    REQUIRED)
  find_library(CSPY_DRV_SIM
    NAMES ${CMAKE_SHARED_LIBRARY_PREFIX}${TOOLKIT}SIM2${CMAKE_SHARED_LIBRARY_SUFFIX}
          ${CMAKE_SHARED_LIBRARY_PREFIX}${TOOLKIT}sim2${CMAKE_SHARED_LIBRARY_SUFFIX}
    PATHS ${BIN_DIR}
    REQUIRED)
  find_library(CSPY_DRV_BAT
    NAMES ${CMAKE_SHARED_LIBRARY_PREFIX}${TOOLKIT}Bat${CMAKE_SHARED_LIBRARY_SUFFIX}
          ${CMAKE_SHARED_LIBRARY_PREFIX}${TOOLKIT}LibsupportUniversal${CMAKE_SHARED_LIBRARY_SUFFIX}
    PATHS ${BIN_DIR}
    REQUIRED)

  # Add a test for CTest
  add_test(NAME ${TARGET}
           COMMAND ${CSPY_BAT} --silent
             # C-SPY drivers
             ${CSPY_DRV_PROC}
             ${CSPY_DRV_SIM}
             --plugin=${CSPY_DRV_BAT}
             # Debuggable ELF
             --debug_file=$<TARGET_FILE:${TARGET}>
             # C-SPY backend setup
             --backend
               --semihosting
               $<IF:$<STREQUAL:$<TARGET_PROPERTY:${TARGET},CPU_$<CONFIG>>,Cortex-M55.no_se.no_mve>,--cpu=Cortex-M55.no_se,--cpu=$<TARGET_PROPERTY:${TARGET},CPU_$<CONFIG>>>
               --fpu=$<TARGET_PROPERTY:${TARGET},FPU_$<CONFIG>>
               --endian=$<TARGET_PROPERTY:${TARGET},END_$<CONFIG>>
               $<IF:$<STREQUAL:$<TARGET_PROPERTY:${TARGET},END_$<CONFIG>>,big>,--BE8,>)

  # Set the test to interpret a C-SPY's message containing `SUCCESS`
  set_tests_properties(${TARGET} PROPERTIES PASS_REGULAR_EXPRESSION "${RESULT}")

endfunction()
