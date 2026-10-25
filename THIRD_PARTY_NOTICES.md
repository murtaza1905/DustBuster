# Third-party notices

DustBuster embeds data derived from the following project. The project's license and copyright notice are reproduced here as required.

## Homebrew Cask (`Core/Sources/DustBusterCore/Resources/cask-zap.json`)

The leftover-path database is generated from the `zap` and `uninstall` stanzas of the cask definitions in [Homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask) by `tools/build-cask-db.py`. The generated file records the exact upstream commit it was built from.

```
BSD 2-Clause License

Copyright (c) 2009-present, Homebrew contributors
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

## Build tooling (not distributed with the app)

- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (MIT) — downloaded by `scripts/install.sh` at build time to generate the Xcode project.
