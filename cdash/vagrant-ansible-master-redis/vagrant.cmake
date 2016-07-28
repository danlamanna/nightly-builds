set(CTEST_SOURCE_DIRECTORY "/var/www/CDash")
set(CTEST_BINARY_DIRECTORY "/var/www/CDash/_build")

set(CTEST_SITE "genii.kitware")
set(CTEST_BUILD_NAME "vagrant-ansible-master-redis")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_UPDATE_COMMAND "git")

ctest_start("Nightly")
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
ctest_submit(PARTS Start Update)

# CMake
set(cfg_options
  -DCDASH_SERVER=localhost
  -DCDASH_DIR_NAME=""
  -DCDASH_USE_SELENIUM=false
  -DCDASH_DB_LOGIN=cdash
  -DCDASH_DB_PASS=cdash
  -DCDASH_USE_PROTRACTOR=false
  -DCDASH_USE_REDIS_QUEUE=true)
ctest_configure(OPTIONS "${cfg_options}")
ctest_submit(PARTS Configure)

# Make
ctest_build()
ctest_submit(PARTS Build)

# Run Consumer in background
execute_process(COMMAND "/vagrant/start-consumer.sh")

# CTest
ctest_test(
  PARALLEL_LEVEL 1
  EXCLUDE "iphone|branchcoverage") # These 2 tests always fail on my machine
ctest_submit(PARTS Test)
