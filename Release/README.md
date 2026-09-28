# Attunetion 1.0 build 5

Use `Attunetion.xcodeproj`, scheme `Attunetion`, and source under `Attunetion/`. The separate `Daily Intentions.xcodeproj` is legacy source and is not this release. Registered app identity is `com.nathanfennel.Attunetion`, team `EJLR2RPSV2`, Apple ID `6757886472`.

The release repairs compilation, enforces consent around every AI request, connects the guide's generator to the real service, and allows revocation in Settings. It fixes local data deletion and wires the widget app group while retaining the existing app-private SwiftData store. Models have declaration defaults compatible with future CloudKit configuration. The current signed profile has no CloudKit container. Build 4 removed the onboarding page that falsely promised cross-device sync; build 5 replaces unattributed sample quotes in widget previews with original app copy.

Widget links open the existing intention, notification taps reach the new-intention form, and guided creation commits all entries together with visible errors. Codable-scope queries filter existing records without a storage migration; duplicate periods are rejected. Canceled guide animation tasks exit instead of spinning.

Run `Tools/ConsentChecks/run.sh`, `Tools/DeletionChecks/run.sh`, and `Tools/FlowChecks/run.sh`. Archive with `xcodebuild -project Attunetion.xcodeproj -scheme Attunetion -configuration Release -destination 'generic/platform=iOS' -archivePath <output>.xcarchive archive`. Build using this computer unless another owned computer is verified idle. See `daily-intentions-backend/DEPLOYMENT.md` for same-revision AWS/Vercel deployment; a native archive is not a backend deployment.

Before uploading, complete actual iPhone/iPad first launch, create/edit/delete, restart persistence, guide/manual/automatic AI consent and revocation, widget updates, notification actions, dark mode and accessibility checks. Verify the final archive revision and live theme/weekly service requests. Capture current screenshots in every required slot. Refresh distribution signing without removing existing capabilities. Finish App Store metadata, truthful privacy and age answers, review contacts, upload processing, build selection and final submission. Verify Waiting for Review or In Review separately from release. None of those steps is implied by a build or headless check.

The Mac and Apple sessions currently require user access. Preserve these blockers until native UI and authenticated App Store operations actually work.
