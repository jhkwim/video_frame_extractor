# 씬스틸러 (Scene Stealer)

[![Deploy Web to GitHub Pages](https://github.com/jhkwim/video_frame_extractor/actions/workflows/deploy_web.yml/badge.svg)](https://github.com/jhkwim/video_frame_extractor/actions/workflows/deploy_web.yml)

**동영상에서 최고의 순간을 프레임 단위로 정밀하게 추출하세요.**
Web, macOS, Android, iOS 모든 플랫폼을 지원하는 강력한 프레임 추출 도구입니다.

## ✨ 주요 기능 (Features)

*   **🎬 프레임 추출 (Frame Extraction)**: 동영상을 재생하고 원하는 시점의 이미지를 고화질로 추출합니다.
*   **🖼️ 다양한 포맷 지원**: JPEG, PNG, WEBP 등 원하는 포맷과 품질(Compression)을 설정할 수 있습니다.
*   **📂 스마트 파일 저장**: `[원본파일명]_[시간].jpg` 형식으로 자동 저장되며, 플랫폼별 최적화된 저장 방식을 사용합니다.
    *   **macOS**: Finder 대화상자로 저장 위치 선택
    *   **Web**: 브라우저 다운로드
    *   **Mobile**: 갤러리/사진 앱에 즉시 저장
*   **📱 멀티 플랫폼 지원**: Flutter 기반으로 제작되어 Web, macOS, Android, iOS 어디서나 동일한 경험을 제공합니다.

## 🚀 시작하기 (Getting Started)

### 사전 요구사항
*   Flutter SDK (3.10.0 이상)

### 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# macOS 실행
flutter run -d macos

# Web 실행
flutter run -d chrome
```

## 🛠️ 기술 스택 (Tech Stack)

*   **Framework**: Flutter
*   **Architecture**: Clean Architecture (MVVM)
*   **State Management**: Riverpod
*   **Navigation**: GoRouter
*   **Platform Channels**: MethodChannel (macOS AVFoundation), dart:html (Web Canvas)

## 📄 라이선스 (License)

이 프로젝트는 MIT 라이선스를 따릅니다.
