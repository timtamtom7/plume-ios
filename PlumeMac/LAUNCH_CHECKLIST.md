# PlumeMac — Pre-Launch Checklist

## App Store Setup

- [ ] Apple Developer account active (paid membership)
- [ ] App name "PlumeMac" confirmed and available
- [ ] Bundle ID: `com.plumemac.app`
- [ ] Create App Store Connect listing
- [ ] Fill in tagline: **"Write without boundaries."**
- [ ] Write and upload app description
- [ ] Add 6–10 screenshots (iPhone + iPad, light + dark)
- [ ] Upload app icon (1024×1024 for App Store)
- [ ] Fill in keywords
- [ ] Set category: Productivity > Writing & Notes
- [ ] Set content rating (no age restriction)
- [ ] Add privacy policy URL
- [ ] Configure pricing (Free / Paid)
- [ ] Set availability (territories)

## Build & Submission

- [ ] `xcodegen generate` succeeds
- [ ] Build succeeds: `xcodebuild -scheme PlumeMac -configuration Release -destination 'platform=macOS,arch=arm64' build CODE_SIGN_IDENTITY="-"`
- [ ] Archive build in Xcode (Product → Archive)
- [ ] Validate and upload via Organizer
- [ ] Select correct App Store Connect app
- [ ] Upload Build
- [ ] Add export compliance info
- [ ] Submit for review

## Review Readiness

- [ ] App launches without crashes
- [ ] Dark mode fully themed (no hardcoded light colors)
- [ ] All interactive elements have tap targets (44×44 pt minimum)
- [ ] No placeholder or debug text visible
- [ ] Privacy policy accessible and accurate
- [ ] Terms of service accessible (if applicable)
- [ ] Test with sandbox account if IAP included
- [ ] Review checklist reviewed at: https://developer.apple.com/app-store/review/

## Marketing

- [ ] App Store listing reviewed by human
- [ ] Screenshots reflect actual UI
- [ ] Copy reviewed — no typos
- [ ] Website / landing page ready (optional)
- [ ] Social announcement plan in place

## Post-Launch

- [ ] Monitor App Store Connect for review status
- [ ] Address any rejection issues promptly
- [ ] Announce launch (social, etc.)
- [ ] Monitor crash reports in Xcode Organizer
- [ ] Collect and act on first reviews

---

*Check items as you go. Last updated: R13 (Polishing)*
