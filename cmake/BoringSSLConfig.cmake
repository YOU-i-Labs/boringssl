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

# youi: CMake script installed so consumers that expect a package literally
# named "BoringSSL" (as the older YOU-i-Labs fork's CMake project was named)
# can still use find_package(BoringSSL CONFIG). Mirrors
# cmake/OpenSSLConfig.cmake, but exposes BoringSSL::Crypto / BoringSSL::SSL
# imported targets instead of OpenSSL::Crypto / OpenSSL::SSL.

# youi: on platforms where BoringSSL links against pthreads (i.e. not
# Generic/Android - see the "find_package(Threads REQUIRED)" guard in the
# top-level CMakeLists.txt), the "crypto" target is linked with
# Threads::Threads using the old, no-keyword target_link_libraries()
# signature, which CMake treats as PUBLIC. That bakes a literal
# "Threads::Threads" reference into BoringSSLTargets.cmake's exported
# INTERFACE_LINK_LIBRARIES for BoringSSL::Crypto below, and CMake validates
# target-shaped (::-containing) names in that property eagerly, at
# set_target_properties() time - so Threads::Threads must already exist as
# a target *before* we include(BoringSSLTargets.cmake), or that include
# itself fails with "the target was not found". Resolve it here exactly the
# way our curl fork's own generated CURLConfig.cmake does for the same
# BoringSSL/AWS-LC threading requirement.
include(CMakeFindDependencyMacro)
find_dependency(Threads)

include(${CMAKE_CURRENT_LIST_DIR}/BoringSSLTargets.cmake)

# youi: the old YOU-i-Labs BoringSSL fork exposed lowercase
# BoringSSL::crypto / BoringSSL::ssl target names (matching its CMake
# project's raw "crypto"/"ssl" target names), and every current consumer in
# the wbd-beam-youi tree/subtrees (network, StyleExtractor, the castlabs
# common_libs_cross-platform-helpers subtree, etc.) still links against
# those lowercase names. Upstream BoringSSL sets EXPORT_NAME Crypto/SSL on
# these targets (to mirror real OpenSSL's OpenSSL::Crypto / OpenSSL::SSL),
# so BoringSSLTargets.cmake above always produces the capitalized names
# regardless of the NAMESPACE used at install(EXPORT) time. Add lowercase
# aliases here so both naming conventions resolve.
if(TARGET BoringSSL::Crypto AND NOT TARGET BoringSSL::crypto)
  add_library(BoringSSL::crypto ALIAS BoringSSL::Crypto)
endif()
if(TARGET BoringSSL::SSL AND NOT TARGET BoringSSL::ssl)
  add_library(BoringSSL::ssl ALIAS BoringSSL::SSL)
endif()

set(BoringSSL_FOUND YES)
