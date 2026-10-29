# Empty States & iOS Share Intake Architecture

Addressed the complete cleanup of initial sample mock data and implemented an instructional Empty State Banner across the Feed and Collections screens. Solved the iOS Instagram share sheet limitation by implementing an automatic clipboard listener and manual intake modal.

## Key Insights
- **Apple ID App Group Constraints:** Sideloading via free personal Apple IDs prohibits `com.apple.security.application-groups` entitlements required for native iOS Share Extensions (`.appex`). 
- **The Clipboard Pattern:** Industry-standard Instagram saver apps on iOS use the `Copy Link` + Clipboard lifecycle detection pattern (`WidgetsBindingObserver` on `AppLifecycleState.resumed`).
- **First-Run UX:** Zero-data empty states must provide clear instructional guidance on how to populate the vault rather than blank screens.
