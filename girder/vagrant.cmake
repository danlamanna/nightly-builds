set(CTEST_SOURCE_DIRECTORY "$ENV{SOURCE_DIR}")
set(CTEST_BINARY_DIRECTORY "$ENV{SOURCE_DIR}/build")

# Print debug information
find_program(VAGRANT vagrant)
find_program(ANSIBLE ansible-playbook)
execute_process(COMMAND ${VAGRANT} --version OUTPUT_VARIABLE VAGRANT_VERSION)
execute_process(COMMAND ${ANSIBLE} --version OUTPUT_VARIABLE ANSIBLE_VERSION)
message(STATUS "VAGRANT VERSION: " ${VAGRANT_VERSION})
message(STATUS "ANSIBLE VERSION: " ${ANSIBLE_VERSION})


execute_process(COMMAND git describe --all --contains HEAD OUTPUT_VARIABLE GIT_REVISION)

set(CTEST_SITE "genii.kitware")
set(CTEST_BUILD_NAME "ansible-tests-${GIT_REVISION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_UPDATE_COMMAND "git")

ctest_start("$ENV{TEST_GROUP}")
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
ctest_submit(PARTS Start Update)

# CMake
set(cfg_options
  -D ANSIBLE_TESTS=ON
  -D ANSIBLE_CLIENT_TESTS=ON
  -D BUILD_JAVASCRIPT_TESTS=OFF)
ctest_configure(OPTIONS "${cfg_options}")
ctest_submit(PARTS Configure)

# Make
ctest_build()
ctest_submit(PARTS Build)

# CTest
ctest_test(INCLUDE_LABEL "^girder_ansible")
ctest_submit(PARTS Test)

# Submit logs as a note
file(STRINGS "${CTEST_BINARY_DIRECTORY}/Testing/TAG" tag_info)
list(GET tag_info 0 tag_info)
list(APPEND CTEST_NOTES_FILES
  "${CTEST_BINARY_DIRECTORY}/Testing/Temporary/LastTest_${tag_info}.log")
ctest_submit(PARTS Notes)
