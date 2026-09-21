# QuizForge

QuizForge is a Flutter app that turns study notes into objective multiple-choice quizzes. The MVP does not require an account.

## What you can do

- Paste notes or upload a `.txt` / `.md` file
- Generate AI-backed objective questions from that content
- Create multiple question sets, with or without overlapping questions
- Answer every question, then submit
- Review your selected answers next to the correct answers

## How question generation works

By default, QuizForge uses an on-device generator that reads the uploaded passage, extracts facts, and builds multiple-choice items. No login is required.

If you add an OpenAI API key in **AI settings**, QuizForge tries cloud generation first and falls back to the on-device generator if the request fails.

## Run the app

```bash
flutter pub get
flutter test
flutter run -d chrome
```

Android, iOS, web, and Linux targets are included.

## Product flow

1. Home → **Upload study content**
2. Paste, upload, or load a sample lesson
3. Choose how many questions to generate and whether later sets may overlap
4. Attempt the quiz and press **Submit** after every question has an answer
5. Review selected vs correct answers, then retake or generate another set
