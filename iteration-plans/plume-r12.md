# Plume R12 — Publishing, Sharing & Community

## Overview
R12 transforms Plume from a personal writing tool into a community platform: share prompts, publish excerpts, participate in challenges, and connect with other writers.

---

## Features

### 1. Prompt Sharing
- **Community Prompts**: Browse and use prompts created by other writers
- **Share Your Prompts**: Publish your favorite prompts to the community
- **Prompt Collections**: Curated bundles by theme (e.g., "30 Days of Gratitude", "Sci-Fi Starters")
- **Prompt Ratings**: Upvote and save community prompts

### 2. Publishing & Sharing
- **Export Options**: Export writing as beautifully formatted PDF, markdown, or plain text
- **Share Excerpts**: Share a paragraph or page to social media (with attribution)
- **Writing Portfolio**: Public profile showcasing selected pieces
- **Reading Views**: Beautiful reader-mode for sharing completed works

### 3. Writing Challenges
- **Daily/Weekly Challenges**: Timed prompts with word count goals
- **Group Challenges**: Join challenges with other writers
- **Challenge Calendar**: Month-view showing upcoming challenges
- **Leaderboards**: Optional anonymous participation tracking

### 4. Social Features
- **Follow Writers**: Follow other Plume users and get notified of new work
- **Reading List**: Save pieces from other writers to read later
- **Claps/Responses**: Lightweight appreciation system (like Medium)
- **Private Circles**: Small groups for sharing feedback (beta)

---

## Technical Approach

### Backend Requirements
- User authentication (Apple Sign-In)
- Database for users, prompts, writings, follows
- Content moderation pipeline
- File storage for exported writings

### Suggested Stack
- **Database**: Supabase or Firebase
- **Auth**: Apple Sign-In (privacy-focused)
- **Storage**: Supabase Storage / S3 for exports
- **Moderation**: Mix of automated + community reporting

### API Design
```
POST /api/prompts          — Share a prompt
GET  /api/prompts           — Browse community prompts
POST /api/writings          — Publish a piece
GET  /api/writings/:id      — Get a piece
POST /api/challenges/join   — Join a challenge
GET  /api/users/:id/profile — Get user profile
```

---

## Moderation & Safety

- Community guidelines required before publishing
- Automated profanity/spam detection
- Report mechanism for abuse
- Age-appropriate content filters
- Block/ignore other users

---

## UI Changes

### New "Community" Tab
- Feed of popular/new prompts
- Challenge spotlight
- Featured writers

### Share Sheet
- Custom Plume share format for excerpts
- Export to PDF with cover page option

### Profile Page
- Writing portfolio grid
- Stats (pieces published, total claps, followers)
- Edit bio and reading preferences

---

## Milestones

- [ ] Design data model for social features
- [ ] Implement Apple Sign-In
- [ ] Build prompt sharing CRUD
- [ ] Create challenge system
- [ ] Build social feed UI
- [ ] Add export/print functionality
- [ ] Implement moderation pipeline
- [ ] Launch private beta with test users
