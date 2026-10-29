# iOS Physical Device Deployment & Code Signing

Documented the physical iOS hardware deployment process over Lightning/USB-C cable. Identified four requisite security gates enforced by Apple: Device Pairing ("Trust This Computer"), iOS 16+ Developer Mode activation, Xcode Personal Team provisioning, and developer profile certificate trust on device.

## Implications
- Unlike the iOS Simulator which runs unsigned x86_64/arm64 binaries, physical devices strictly require cryptographic code signing certificates provisioned by an Apple ID.
- Setting up a free Personal Team in Xcode signs the binary for 7-day development runs without requiring a paid \$99/year Apple Developer account.
