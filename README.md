# 🧠 문제메이트 (Moonje Mate)

> 생성형 AI와 OCR을 활용해 원하는 학습 문제를 생성하고 관리하는 Flutter 모바일 애플리케이션

문제메이트는 사용자가 공부하고 싶은 **키워드 또는 이미지 속 텍스트**를 입력하면 AI가 관련 문제를 생성하고, 생성된 문제와 해설을 저장·관리할 수 있도록 만든 모바일 앱입니다.

산업공학 캡스톤 프로젝트로 진행했으며, 반복적인 문제 제작 과정을 줄이고 사용자가 필요한 학습 문제를 직접 만들어 활용할 수 있도록 하는 것을 목표로 개발했습니다.

---

## 📌 Project Overview

| 항목 | 내용 |
| --- | --- |
| 프로젝트명 | 문제메이트 (Moonje Mate) |
| 프로젝트 유형 | 산업공학 캡스톤 프로젝트 |
| 개발 형태 | 2인 팀 프로젝트 |
| Platform | Mobile |
| Framework | Flutter / Dart |
| Backend / DB | Supabase |
| AI | OpenAI Chat Completions API |
| 주요 기능 | AI 문제 생성, AI 해설, 이미지 OCR, 문제 저장 및 태그 관리 |

---

## 💡 Background

학습 과정에서 특정 개념에 맞는 새로운 문제를 직접 찾거나 제작하려면 많은 시간이 필요합니다.

이 문제를 해결하기 위해

> "원하는 학습 내용을 입력하면 AI가 바로 문제를 만들어주면 어떨까?"

라는 아이디어에서 프로젝트를 시작했습니다.

단순히 AI가 문제를 생성하는 것에서 끝나지 않고,

- AI 문제 생성
- 이미지 속 학습자료 인식
- 문제 저장
- AI 해설
- 태그 기반 문제 관리

까지 하나의 모바일 학습 흐름으로 연결했습니다.

---

## ✨ Main Features

### 1. AI 문제 생성

사용자가 학습하고 싶은 키워드를 입력하면 OpenAI API를 통해 관련 문제를 생성합니다.

```text
사용자 키워드 입력
        ↓
문제 생성 선택
        ↓
OpenAI API
        ↓
AI 문제 생성
        ↓
채팅 UI 출력
```

문제 생성과 해설 요청에 서로 다른 system prompt를 사용해 AI의 역할을 구분했습니다.

---

### 2. AI 해설

생성된 문제를 기반으로 AI에게 해설을 요청할 수 있습니다.

기존에 생성된 문제 내용을 유지한 뒤, 해설 요청 시 다시 AI 프롬프트에 포함해 설명을 생성하도록 구성했습니다.

---

### 3. 이미지 → OCR → 문제 생성

텍스트를 직접 입력하는 것뿐 아니라 사용자가 갤러리에서 이미지를 선택해 문제를 생성할 수도 있습니다.

```text
이미지 선택
    ↓
Base64 변환
    ↓
OCR API
    ↓
텍스트 추출
    ↓
OpenAI API
    ↓
AI 문제 생성
```

교재나 학습자료 이미지를 활용해 새로운 문제를 만들 수 있도록 구현했습니다.

---

### 4. 생성 문제 저장

AI가 생성한 문제를 바로 저장할 수 있습니다.

저장 시 사용자는

- 문제 유형
- 문제 태그

를 입력할 수 있습니다.

저장 과정에서는 문제뿐 아니라 AI가 생성한 해설도 함께 저장됩니다.

---

### 5. 문제 보관함

저장된 문제를 다시 학습할 수 있도록 보관함 기능을 구현했습니다.

지원 기능은 다음과 같습니다.

- 사용자별 문제 조회
- 최신순 문제 정렬
- 태그별 필터링
- 문제 해설 조회
- 태그 변경
- 문제 삭제

사용자가 저장한 데이터에서 태그 목록을 동적으로 생성하도록 구성했습니다.

---

### 6. 사용자 인증

Supabase Authentication을 이용해 사용자 인증 기능을 구현했습니다.

- 이메일 회원가입
- 이메일/비밀번호 로그인
- 사용자 정보 조회
- 사용자별 문제 데이터 관리

---

## 🛠 Tech Stack

### Mobile

- Flutter
- Dart
- Material UI

### Backend / Database

- Supabase
- Supabase Authentication
- PostgreSQL

### AI

- OpenAI Chat Completions API
- Prompt Engineering

### Image Processing

- Image Picker
- Base64 Encoding
- OCR API

### Libraries

- supabase_flutter
- http
- image_picker
- multiple_images_picker
- intl

---

## 🏗 Project Structure

```text
lib/
├── common/
│
├── model/
│   ├── problem.dart
│   └── user.dart
│
├── screen/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_screen.dart
│   ├── chat_screen.dart
│   ├── storage_date_screen.dart
│   ├── clientinfo_screen.dart
│   └── setting_screen.dart
│
├── widget/
│
└── main.dart
```

화면, 데이터 모델, 공통 UI 컴포넌트를 디렉터리별로 분리해 관리했습니다.

---

## 🔄 Service Flow

```text
                     User
                       │
              Keyword / Image
                       │
                       ▼
                  Flutter App
                  /          \
              Image          Text
                │              │
                ▼              │
              OCR              │
                │              │
                └──────┬───────┘
                       ▼
                   OpenAI API
                       │
                       ▼
                 Problem 생성
                       │
                ┌──────┴──────┐
                │             │
              화면 출력       저장
                              │
                              ▼
                           Supabase
                              │
                         문제 / 해설
                              │
                              ▼
                          문제 보관함
```

---

## 👨‍💻 Implementation

프로젝트에서 다음 기능을 구현했습니다.

- Flutter 기반 모바일 UI
- 앱 화면 간 Route 구성
- Supabase 사용자 인증
- 사용자 정보 조회
- OpenAI API 기반 문제 생성
- AI 해설 생성
- 이미지 선택 및 Base64 변환
- OCR API 연동
- OCR 결과를 AI 입력으로 전달
- 생성 문제 DB 저장
- 문제 유형 및 태그 관리
- 사용자별 문제 조회
- 태그 기반 필터링
- 문제 수정 및 삭제
- 로그인·채팅·프로필 UI 개선

---

## 🔧 Key Implementation

### OCR과 생성형 AI 연결

OCR 결과를 단순히 출력하는 것이 아니라 추출된 문자열을 다시 OpenAI API의 입력으로 사용했습니다.

```text
Image
  ↓
OCR
  ↓
Text
  ↓
OpenAI
  ↓
Problem
```

서로 다른 외부 API를 하나의 사용자 기능으로 연결했습니다.

---

### AI 결과의 데이터화

AI가 생성한 결과를 일회성 채팅으로 끝내지 않고 Supabase에 저장할 수 있도록 구현했습니다.

```text
AI 문제 생성
    ↓
저장 선택
    ↓
유형 / 태그 입력
    ↓
AI 해설 생성
    ↓
Supabase 저장
```

이후 사용자가 문제를 다시 조회하고 분류할 수 있도록 구성했습니다.

---

### 사용자별 데이터 관리

로그인된 사용자 이메일을 문제 데이터와 연결하고, 조회 시 현재 사용자를 기준으로 필터링했습니다.

이를 통해 각 사용자가 자신의 문제만 관리할 수 있는 개인 문제 보관함을 구현했습니다.

---

## 📚 What I Learned

### 1. AI를 실제 서비스 기능으로 만드는 경험

AI API 호출 자체보다

```text
사용자 입력
→ API
→ 결과 처리
→ UI
→ DB 저장
→ 재사용
```

이라는 전체 서비스 흐름을 구현하는 것이 중요하다는 점을 배웠습니다.

### 2. 서로 다른 API 연결

OCR의 출력 결과를 OpenAI의 입력 데이터로 다시 사용하면서 외부 서비스 간 데이터를 연결하는 경험을 했습니다.

### 3. 모바일 데이터 관리

Supabase Auth와 DB를 이용하면서 사용자와 데이터를 연결하고 사용자별 정보를 관리하는 경험을 했습니다.

---

## 🚀 Future Improvements

현재 프로젝트를 다시 개선한다면 다음 부분을 보완하고 싶습니다.

- API Key와 환경 설정을 환경 변수로 분리
- OpenAI 호출을 모바일에서 직접 수행하지 않고 Backend API로 이동
- 객관식 / 주관식 생성 기능 구조화
- 문제 난이도 선택 기능
- AI 응답 JSON 구조화
- 정답 검증 기능 고도화
- 네트워크 예외 처리 개선
- Repository / Service Layer 분리
- 테스트 코드 확장

---

## 📎 Repository

https://github.com/leunchan/brain-app
