# Attunetion project tasks

## TestFlight

- [ ] Sign in to App Store Connect and confirm that 1.0.1 (13) finished processing on iOS, macOS and visionOS. Xcode reported successful uploads on November 27. The iOS build covers iPhone, iPhone Duo, iPad and the Watch companion.
- [ ] Add build 13 testing notes for each platform and verify assignment to Daily Intentions Testers. Ask testers to check the rounded current-intention card, its slow gradient movement and Reduce Motion.
- [ ] Confirm Aubrey’s invitation email and group membership. For external testing, complete the beta review contact details, assign the builds to Attunetion Beta, submit for Beta App Review where required, and verify Aubrey can install the approved build.

## Release verification

- [ ] Approve and deploy the five SwiftData record types to production in CloudKit Console. With the same iCloud account on signed TestFlight devices, verify creation, edits and deletion across platforms, including Mac and Watch. Check updates while both apps are open, after relaunch and after offline edits and reconnection. Record propagation delays and duplicates.
- [ ] Exercise the shipping build on the supported device families. Record notification delivery and tap, widget refresh and deep linking, VoiceOver and large text, Duo posture changes, and physical Vision Pro interaction. Verify that AI consent, revocation and re-enabling work independently on each device.
- [ ] Check the existing App Review thread for Apple’s response to the nine answers about guidelines 4.3 and 4.2.6. Follow Apple’s instructions on resubmission. The last recorded App Store drafts selected build 11.
- [ ] When ready to submit, select the verified candidate on each platform. Confirm review contact, privacy and age disclosures, license, availability excluding mainland China, and final localized copy and rendered screenshots. Record Apple’s submission status for each platform.
- [ ] Once a storefront listing is public, publish the marketing page’s download links through the website deployment process and verify the links on mobile and desktop.

Release history and supporting evidence are in the [release audit](Release/README.md).
