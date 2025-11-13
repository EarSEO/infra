## 🧩 구현/변경 사항
- 로그인 기능 API 구현
- JWT 토큰 인증 필터 추가

---

## 사용자 시나리오(UML)
- ![img.png](attachment:bc6d13e8-682d-43c0-afc1-1e53345f9a18:img.png)

---

## 🧪 테스트 결과
- ![img.png](attachment:bc6d13e8-682d-43c0-afc1-1e53345f9a18:img.png)

---

## BREAKING CHANGE (옵션)
- <호환성 깨짐 / API 변경 / 클라이언트 수정 필요 사항>
- (예: `/user/{userId}/alert` → `/user/queue/alert` 변경, timestamp 포맷 KST 필수 등)

---

## 참고
- 기타 후속 작업이나 주의사항
- (예: JWT 인증은 추후 연동 예정, 로깅 레벨은 임시 상향 조정 등)

---

## 🪞 회고 및 개선 아이디어 (옵션)
- JWT 갱신 로직은 추후 Refresh Token 구조로 개선 예정

---

## 💬 리뷰 받고 싶은 부분 (옵션)
- 토큰 만료 시 처리 로직 괜찮은지 피드백 부탁드립니다.
- UI 로직 구조 개선 제안 환영합니다.
