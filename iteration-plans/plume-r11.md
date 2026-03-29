# Plume R11 — AI Writing Prompts, Style Analysis & Productivity Insights

## Overview
R11 adds AI-powered features to Plume: intelligent prompt suggestions, writing style analysis, and productivity insights that help writers improve.

---

## Features

### 1. AI Writing Prompts
- **Smart Prompt Generation**: Use local AI to generate personalized prompts based on user's past writing themes, favorite genres, and time of day
- **Context-Aware Suggestions**: Analyze recent writing to suggest prompts that continue themes or explore new angles
- **Seasonal/Holiday Prompts**: Time-appropriate prompts for holidays, seasons, and events

### 2. Writing Style Analysis
- **Readability Score**: Show readability metrics (Flesch-Kincaid, sentence length variance, vocabulary diversity)
- **Session Insights**: Analyze each writing session for tone, sentiment, and complexity
- **Writing Pattern Detection**: Identify when user writes best (time of day, session length preferences)
- **Progress Over Time**: Track how writing style evolves across sessions

### 3. Productivity Insights
- **Flow State Detection**: Identify when user enters "flow" and suggest optimal session lengths
- **Distraction Alerts**: If writing pace drops significantly, suggest a break
- **Streak Motivation**: Smart streak reminders based on user patterns (not generic nudges)
- **Weekly Digest**: AI-generated summary of the week's writing accomplishments and patterns

---

## Technical Approach

### On-Device AI
- Use Apple's NaturalLanguage framework for sentiment analysis and language processing
- CoreML models for style classification (no cloud dependency)
- Local processing only — privacy-first

### Data Model Additions
```swift
struct WritingStyleMetrics {
    let readabilityScore: Double
    let avgSentenceLength: Double
    let vocabularyDiversity: Double
    let sentiment: Double // -1 to 1
    let complexity: Double
}

struct WeeklyDigest {
    let totalWords: Int
    let totalSessions: Int
    let streakDays: Int
    let topSentiments: [String]
    let improvementAreas: [String]
    let highlight: String
}
```

### Privacy
- All AI analysis runs on-device
- No user data sent to external servers
- Optional: let user delete style profiles

---

## UI Changes

### New "Insights" Tab
- Today's writing stats with AI commentary
- Weekly digest card
- Style radar chart

### Writing Editor Enhancement
- Real-time readability indicator (subtle, non-intrusive)
- Flow state indicator (small flame icon when detected)

---

## Milestones

- [ ] Integrate NaturalLanguage framework
- [ ] Build readability analysis engine
- [ ] Create style metrics storage
- [ ] Design insights dashboard
- [ ] Implement flow state detection
- [ ] Build weekly digest generator
- [ ] Add seasonal prompt system
