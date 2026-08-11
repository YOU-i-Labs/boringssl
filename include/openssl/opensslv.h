// Copyright 2014 The BoringSSL Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/* This header is provided in order to make compiling against code that expects
   OpenSSL easier. */

#include "crypto.h"

// youi: Some CMake `FindOpenSSL` modules (including the one bundled with this
// project's vendored Hunter package manager) detect the OpenSSL version by
// grepping this file's raw text for a literal "#define OPENSSL_VERSION_NUMBER"
// line, rather than following the #include chain into crypto.h -> base.h
// where BoringSSL actually defines it. Without this, such tooling fails with
// "Incorrect OPENSSL_VERSION_NUMBER define in header".
//
// That text-scanning requirement means the value below cannot be a reference
// to the canonical definition in base.h -- it must be a literal. To avoid the
// two silently drifting apart on a future rebase, this check compares the
// literal against whatever base.h (already included above) actually defines,
// and fails the build loudly if they disagree.
#if defined(OPENSSL_VERSION_NUMBER) && OPENSSL_VERSION_NUMBER != 0x1010107f
#error "OPENSSL_VERSION_NUMBER literal in opensslv.h is out of sync with base.h -- update both to match."
#endif
#define OPENSSL_VERSION_NUMBER 0x1010107f
