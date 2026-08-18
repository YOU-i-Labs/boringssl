# Copyright 2022 The BoringSSL Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# CMake script to be installed so other programs or libraries can find BoringSSL
# the same way as OpenSSL would normally be found. Mimics
# exporters/cmake/OpenSSLConfig.cmake.in in OpenSSL.

# youi: on platforms where BoringSSL links against pthreads (i.e. not
# Generic/Android - see the "find_package(Threads REQUIRED)" guard in the
# top-level CMakeLists.txt), the "crypto" target is linked with
# Threads::Threads using the old, no-keyword target_link_libraries()
# signature, which CMake treats as PUBLIC. That bakes a literal
# "Threads::Threads" reference into OpenSSLTargets.cmake's exported
# INTERFACE_LINK_LIBRARIES for OpenSSL::Crypto below, and CMake validates
# target-shaped (::-containing) names in that property eagerly, at
# set_target_properties() time - so Threads::Threads must already exist as
# a target *before* we include(OpenSSLTargets.cmake), or that include
# itself fails with "the target was not found". Resolve it here exactly the
# way our curl fork's own generated CURLConfig.cmake does for the same
# BoringSSL/AWS-LC threading requirement.
include(CMakeFindDependencyMacro)
find_dependency(Threads)

include(${CMAKE_CURRENT_LIST_DIR}/OpenSSLTargets.cmake)

# Recursively collect dependency locations for the imported targets.
macro(_openssl_config_libraries libraries target)
  get_property(_DEPS TARGET ${target} PROPERTY INTERFACE_LINK_LIBRARIES)
  foreach(_DEP ${_DEPS})
    if(TARGET ${_DEP})
      _openssl_config_libraries(${libraries} ${_DEP})
    else()
      list(APPEND ${libraries} ${_DEP})
    endif()
  endforeach()
  get_property(_LOC TARGET ${target} PROPERTY LOCATION)
  list(APPEND ${libraries} ${_LOC})
endmacro()

set(OPENSSL_FOUND YES)
get_property(OPENSSL_INCLUDE_DIR TARGET OpenSSL::SSL PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
get_property(OPENSSL_CRYPTO_LIBRARY TARGET OpenSSL::Crypto PROPERTY LOCATION)
_openssl_config_libraries(OPENSSL_CRYPTO_LIBRARIES OpenSSL::Crypto)
list(REMOVE_DUPLICATES OPENSSL_CRYPTO_LIBRARIES)

get_property(OPENSSL_SSL_LIBRARY TARGET OpenSSL::Crypto PROPERTY LOCATION)
_openssl_config_libraries(OPENSSL_SSL_LIBRARIES OpenSSL::SSL)
list(REMOVE_DUPLICATES OPENSSL_SSL_LIBRARIES)

set(OPENSSL_LIBRARIES ${OPENSSL_CRYPTO_LIBRARIES} ${OPENSSL_SSL_LIBRARIES})
list(REMOVE_DUPLICATES OPENSSL_LIBRARIES)

set(_DEP)
set(_DEPS)
set(_LOC)
