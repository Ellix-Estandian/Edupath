# edupath

A new Flutter project.

## AI backend

The FastAPI entry point is in `ai_backend/main.py`. From the repository root, create and install the backend environment once:

```powershell
python -m venv venv
.\venv\Scripts\python.exe -m pip install -r ai_backend\requirements.txt
```

Start the backend from its directory so Python can resolve `main` and its `services` package, and so backend-relative model and upload paths work:

```powershell
Set-Location ai_backend
..\venv\Scripts\python.exe -m uvicorn main:app --reload
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
