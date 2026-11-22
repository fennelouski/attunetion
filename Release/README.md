# Attunetion App Store release audit

**November 22, 2026 · Version 1.0.1 (10) · Hold submission.** The signed release candidate covers all six requested devices. The outstanding release gates are production iCloud round-trip testing, the production AI credential and model rollout, and completion of the authenticated App Store listing.

Use `Attunetion.xcodeproj`, scheme `Attunetion`, team `EJLR2RPSV2`, bundle `com.nathanfennel.Attunetion`, and Apple ID `6757886472`. The similarly named Daily Intentions project is legacy. Final native source revision is `f0e49c0ba2d0763e79a65f5dc2c98c93c124bcba`. The remote tag `attunetion-1.0.1-build10-candidate` identifies those sources. Later commits cover the website and release evidence. The release was built locally using Xcode 27.1. Archives, exports and test summaries are under `~/Documents/Attunetion Release/1.0.1-10/Reviewed/`.

## Platform coverage

| Device | Package | Observed flow |
| --- | --- | --- |
| iPhone 17 Pro | iOS IPA | Completed onboarding, deferred notifications, skipped first entry, reopened home, and verified manual save/relaunch. |
| iPhone Duo | Same iOS IPA | Dedicated Duo simulator completed onboarding, reopened home, and retained a manually entered intention after relaunch. Fold/unfold transitions remain untested. |
| iPad mini | Same iOS IPA | Completed onboarding, reopened home, created a manual intention and found it after relaunch. |
| Apple Watch Series 11 | Companion inside iOS IPA | Installed the packaged Watch app, completed compact onboarding by picking an intention, and found it after relaunch. |
| Mac | Native Mac App Store PKG | Launched to the intended direct-entry home, opened the editor, typed a draft, verified Save enabled and canceled. A separately identified sandbox copy of the archived executable saved a synthetic intention and displayed it after quit/relaunch. CloudKit was disabled for that isolated persistence check. |
| Apple Vision Pro | Native visionOS IPA | Completed onboarding, deferred notifications, created a manual intention and found it after relaunch. Physical headset interaction remains unverified. |

The iPhone and iPad tests used iOS/iPadOS 26.4.1, Duo used iOS 27.1, Watch used watchOS 26.4, and Vision used visionOS 27.0. These are simulator checks except for Mac. All seven repository check suites passed for consent, deletion, flows, migration, preferences, reminders and widget dates. All fifteen backend tests passed.

## Signed exports

| Relative file in Reviewed | SHA-256 |
| --- | --- |
| iOS/AppStore/Attunetion.ipa | f447b6ed3a72ecb967de1dafbbf612648b6f3f694ff2feccb26f3e292ff1ce17 |
| macOS/AppStore/Attunetion.pkg | ca9fe80f599be0552420e7318f3948e1bfcdd451728a057eb3bd33169a879be0 |
| visionOS/AppStore/Attunetion.ipa | ab6a2a26be7f2fee31d7c95e333e9b572786eadbde2b1a1cb2cc0094e23309b5 |

Apple server-side validation succeeded for all three archives using Xcode’s validation method. No build was submitted for review. Each platform directory also contains its signed archive. The iOS export includes the iOS widget and companion Watch app. All participating app binaries have the production CloudKit entitlement and the same container. The Mac App Sandbox permits outgoing connections.

## Changes affecting review

- Repaired the Watch bundle identity, installability and host packaging. Added a compact first-run choice using existing intentions. Fixed visionOS compilation and native layered app icon.
- Made onboarding scroll at compact sizes. Manual writing is available without an account or third-party AI permission. Retained the existing direct-to-home experience on Mac.
- Connected private CloudKit to the existing SwiftData store. Views observe record changes. AI sharing requires affirmative consent on the device making the request. Revocation blocks later requests and suppresses results from an in-flight request. The deletion confirmation and published policies explain propagation.
- Removed the externally supplied photo unlock key and automatic public curation. Production photo catalog routes returned 404. Empty catalog options are suppressed and bundled themes remain usable. Keep remote photo curation out of listing claims unless the service, content rights and required moderation are verified.
- Added device identifier disclosure to the privacy manifest and published updated terms, EULA, privacy/AI disclosures and support on the developer's subdomain. Check the App Store privacy questionnaire independently from the manifest. Verify the organization's OpenAI retention settings before making a more specific retention claim.
- The website repository now owns the subdomain deployment through `npm run deploy:attunetion`. Verified website revision `8ae6c88e4808271f51db7e134d1a119ca6ff2617`. The responsive marketing site selects the current Apple device family and defaults unknown visitors to iPhone. Store downloads are hidden while Apple's US lookup has no public record. Repeat the marketing deployment once that storefront is live (set STORE_COUNTRY for a different launch storefront).

## Before submission

1. **Production CloudKit.** Inspect and deploy the additive schema for `iCloud.com.nathanfennel.Attunetion` in CloudKit Console. A signed entitlement alone cannot establish the deployment state. Using approved test devices on the same iCloud account and a distribution build, create on iPhone, observe and edit on a second platform, and check the edit and deletion on both. Include Watch and Mac, restart, offline edits, duplicates after reconnect and independent per-device AI consent. The local fallback preserves offline usability but can conceal cloud initialization failures. CloudKit management access and a designated pair of signed-in test devices were unavailable.
2. **Production AI.** Five live routes answered synthetic theme, weekly, monthly, rephrasing and quote requests. The public API serves revision `afa1a117f415aa1a7e6522748ce74764d9765a96`. The new backend selects `gpt-6-luna` without reasoning for lighter tasks and `gpt-6.2-sol` at low reasoning for weekly generation. Both accepted direct synthetic requests using the app project's available provider credential. The website's sensitive production credential could not be verified as the same key. Bind the backend to the website's designated managed secret, deploy the reviewed backend revision, then repeat all five checks against the production hostname. Confirm the server enforces durable quotas with synthetic traffic. Keep secrets server-side.
3. **Hosting exception.** The existing native API is reachable. The new branded host serves the website. The AWS API preview still requires IAM, and API cutover, repeatability, abuse controls and rollback are unverified. Preserve working production during completion of the migration. See the deployment records under daily-intentions-backend.
4. **App Store Connect.** The browser stopped at Apple sign-in. Confirm the platform versions, build-number availability, agreements, tax/trader information where applicable, availability, export compliance, age questionnaire, privacy labels and review contact. Set the marketing, support and privacy URLs below. Record the license selection. If selecting a custom EULA, review Apple's minimum terms and enter the approved text and applicable territories in App Store Connect. Publishing a web page alone does not configure this field. Supply appropriate screenshots for each required device slot and review notes describing the no-account manual path, optional AI choice and Watch first run. Upload for processing, inspect warnings, select builds and verify the review submission state separately.
5. **Final device QA.** Exercise notifications with Allow and a real delivery/tap, iOS widget refresh and deep link, VoiceOver, large Dynamic Type, light/dark appearances, Duo posture changes, and revoke/re-enable AI on the signed candidate. Record screenshots and results. No public age rating should be advertised until Apple assigns the storefront rating.

## Information for the App Store Connect review

The candidate's privacy manifest declares device ID, product interaction, other user content, other diagnostics and coarse location as linked. Check each category and purpose against the deployed providers and optional photo requests, especially hosting diagnostics and IP-derived location. Confirm the answers account for third-party retention. The account holder must confirm the final questionnaire. The app has no required signup and its core manual flow works without AI permission. Enter the storefront age questionnaire for the actual enabled content and optional generated output.

Suggested private reviewer instructions: On iPhone, iPad or Apple Vision Pro, finish or skip onboarding, defer notifications, select New Intention, enter text and tap Save. Relaunch to see the entry. On Apple Watch, choose an example at first launch. On Mac, choose Create Intention from the empty state. AI features separately ask permission to send relevant text through the app service to OpenAI. To revoke, open Settings, Suggested Intentions, Stop Sharing with AI.

The website release is live. The change that makes its command available on the website's default branch is in [website pull request 98](https://github.com/fennelouski/nathanfennel.com/pull/98).

## Store URLs and primary references

- Marketing https://attunetion.nathanfennel.com/
- Support https://attunetion.nathanfennel.com/support.html
- Privacy and AI https://attunetion.nathanfennel.com/legal/privacy-policy.html
- Terms https://attunetion.nathanfennel.com/legal/terms-of-service.html
- EULA https://attunetion.nathanfennel.com/legal/eula.html
- [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) cover completeness, metadata, privacy, explicit permission to share with third-party AI and review access.
- [Apple submission requirements](https://developer.apple.com/news/upcoming-requirements/) and [license agreement setup](https://developer.apple.com/help/app-store-connect/manage-app-information/provide-a-custom-license-agreement/) govern the submission.
- [OpenAI model catalog](https://developers.openai.com/api/docs/models) and [Vercel sensitive variables](https://vercel.com/docs/environment-variables/sensitive-environment-variables) inform model choice and credential verification.
