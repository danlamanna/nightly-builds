set(CTEST_SOURCE_DIRECTORY "/opt/girder")
set(CTEST_BINARY_DIRECTORY "/opt/girder/build")

set(CTEST_SITE "genii.kitware")
set(CTEST_BUILD_NAME "vagrant-ansible-master")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_UPDATE_COMMAND "git")

ctest_start("Nightly")
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
ctest_submit(PARTS Start Update)

# CMake
set(cfg_options
  -DRUN_CORE_TESTS:BOOL=OFF
  -DTEST_PLUGINS:STRING=flow
  -DPYTHON_COVERAGE:BOOL=OFF
  -DJS_COVERAGE_MINIMUM_PASS:STRING=30)
ctest_configure(OPTIONS "${cfg_options}")
ctest_submit(PARTS Configure)

# Make
ctest_build()
ctest_submit(PARTS Build)

# CTest
ctest_test(PARALLEL_LEVEL 1)
ctest_submit(PARTS Test)
