# Copyright 2023 The BoringSSL Authors
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

# Go is an optional dependency. It's a necessary dependency if running tests or
# the FIPS build, which will check these.
find_program(GO_EXECUTABLE go)

function(require_go)
  if(NOT GO_EXECUTABLE)
    message(FATAL_ERROR "Could not find Go")
  endif()
endfunction()

function(go_executable dest package)
  require_go()
  set(godeps "${PROJECT_SOURCE_DIR}/util/godeps.go")
  # Ninja expects the target in the depfile to match the output. This is a
  # relative path from the build directory.
  set(target "${CMAKE_CURRENT_BINARY_DIR}/${dest}")
  # youi: cmake_path() requires CMake 3.20. file(RELATIVE_PATH) is equivalent
  # here and available in 3.18.
  file(RELATIVE_PATH target "${CMAKE_BINARY_DIR}" "${target}")

  set(depfile "${CMAKE_CURRENT_BINARY_DIR}/${dest}.d")
  # youi: before CMake 3.20, DEPFILE is accepted only by the Ninja generators
  # (Makefile support landed in 3.20, Visual Studio in 3.21). Omit it on older
  # CMake with other generators; Go sources are then not re-scanned for
  # dependency changes, but the build is otherwise correct.
  set(depfile_arg DEPFILE ${depfile})
  if(CMAKE_VERSION VERSION_LESS "3.20" AND NOT CMAKE_GENERATOR MATCHES "Ninja")
    set(depfile_arg "")
  endif()
  add_custom_command(OUTPUT ${dest}
                      COMMAND ${GO_EXECUTABLE} build
                              -o ${CMAKE_CURRENT_BINARY_DIR}/${dest} ${package}
                      COMMAND ${GO_EXECUTABLE} run ${godeps} -format depfile
                              -target ${target} -pkg ${package} -out ${depfile}
                      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                      DEPENDS ${godeps} ${PROJECT_SOURCE_DIR}/go.mod
                      ${depfile_arg})
endfunction()

