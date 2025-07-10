# LastWar 프로젝트 개발 워크플로우 규칙

Task Master 규칙을 Claude Code에 통합하여 자동으로 적용되는 개발 가이드라인입니다.

## 🚨 필수 작업 시작 전 자동 실행 규칙

**⚠️ 모든 개발 작업은 반드시 아래 Git 워크플로우를 자동으로 시작해야 합니다:**

### 📋 자동 실행 체크리스트 (사용자 요청 없이도 필수)

#### **1단계: 상황 파악 (자동)**
- [ ] `git status` - 현재 로컬 상태 확인
- [ ] `git branch -a` - 모든 브랜치 확인  
- [ ] `mcp__github__list_commits` - 최신 원격 커밋 확인
- [ ] `mcp__github__list_pull_requests` - 기존 PR 상태 확인

#### **2단계: 브랜치 전략 (자동)**
- [ ] 작업 유형 판단: 새 기능(`feature/`) vs 버그 수정(`fix/`)
- [ ] `mcp__github__create_branch` - 원격 브랜치 생성
- [ ] `git checkout -b 브랜치명` - 로컬 브랜치 전환
- [ ] `git pull origin 브랜치명` - 원격과 동기화

#### **3단계: 개발 및 커밋 (자동)**
- [ ] 멀티테넌트 격리 적용 확인
- [ ] 테스트 자동 실행
- [ ] 한글 커밋 메시지로 커밋
- [ ] `git push origin 브랜치명` - 원격 푸시

#### **4단계: PR 생성 (자동)**
- [ ] `mcp__github__create_pull_request` - PR 자동 생성
- [ ] PR 테스트 워크플로우 자동 실행
- [ ] 테스트 통과 확인

### 🔥 **긴급 수정 시나리오**
사용자가 "프론트서버 유저관리 페이지에서 멀티테넌트가 적용되지 않는 버그 수정"이라고 하면:
1. **즉시 `fix/frontend-multitenant-user-management` 브랜치 자동 생성**
2. **프론트엔드 디렉토리로 자동 이동**
3. **멀티테넌트 격리 코드 자동 수정**
4. **테스트 자동 실행**
5. **PR 자동 생성**

⚠️ **이 모든 과정은 사용자가 Git 워크플로우를 명시적으로 요청하지 않아도 자동 실행됩니다.**

## 프로젝트 구조 및 작업 방식

### 디렉토리 구조
```
/lastwar/                        # 프로젝트 루트 (Claude 실행 위치)
├── CLAUDE.md                   # 이 파일 - 통합 개발 규칙
├── .taskmaster/                # Task Master 설정
├── lastwar-api/                # 백엔드 프로젝트 (Spring Boot)
└── lastwar-www/                # 프론트엔드 프로젝트 (Next.js)
```

### 작업 위치 규칙
- **루트 레벨 (`/lastwar/`)**: 
  - Claude Code 실행 위치
  - Task Master 관련 작업
  - Claude 설정 및 워크플로우 관리
  - **Git 관리 안함** (taskmaster, claude 관련 파일 제외)
  
- **백엔드 작업 (`/lastwar-api/`)**:
  - 모든 Spring Boot 관련 개발
  - Java/Kotlin 코드 작성
  - 데이터베이스 마이그레이션
  - **Git 관리**: 백엔드 코드 변경사항

- **프론트엔드 작업 (`/lastwar-www/`)**:
  - 모든 Next.js 관련 개발  
  - TypeScript/React 코드 작성
  - UI/UX 구현
  - **Git 관리**: 프론트엔드 코드 변경사항

### 🔄 자동 작업 플로우 (GitHub MCP 우선)

#### **모든 개발 작업 시 자동 실행 단계**
1. **자동 Git 워크플로우 시작**:
   - GitHub MCP로 원격 상태 확인
   - 적절한 브랜치 자동 생성
   - 로컬 브랜치 전환 및 동기화

2. **계획 단계**: `/lastwar/`에서 Task Master로 작업 계획

3. **백엔드 구현**: `/lastwar-api/`로 이동하여 개발
   - 멀티테넌트 격리 자동 적용
   - 테스트 자동 실행
   - GitHub MCP로 자동 커밋 및 푸시

4. **프론트엔드 구현**: `/lastwar-www/`로 이동하여 개발
   - JWT 토큰 자동 포함 확인
   - E2E 테스트 자동 실행
   - GitHub MCP로 자동 커밋 및 푸시

5. **자동 PR 생성 및 완료**:
   - GitHub MCP로 PR 자동 생성
   - 테스트 워크플로우 자동 실행
   - 코드 리뷰 후 자동 머지

## 프로젝트 아키텍처

### 백엔드: lastwar-api (Spring Boot)
- **데이터베이스**: PostgreSQL with 멀티테넌트 격리
- **아키텍처**: JPA/QueryDSL, REST API, JWT 인증
- **보안**: 모든 쿼리에 `server_alliance_id` 필터링 필수

### 프론트엔드: lastwar-www (Next.js)
- **기술 스택**: Next.js 14+ App Router, TypeScript, Tailwind CSS, ShadCN UI
- **테스트**: MCP Puppeteer for E2E 테스트
- **아키텍처**: React Server Components, 반응형 디자인

## 백엔드 개발 워크플로우 (lastwar-api)

### 1. 멀티테넌트 데이터 격리 (필수)
모든 백엔드 작업 시 다음을 반드시 확인하세요:
- [ ] 모든 쿼리에 `server_alliance_id` 필터링 확인
- [ ] 교차 테넌트 데이터 접근 방지 테스트 작성
- [ ] 데이터 격리 검증 테스트 실행
- [ ] JWT에서 추출한 `getCurrentServerAllianceId()` 사용

### 2. 데이터베이스 설계
- [ ] JPA 어노테이션으로 엔터티 관계 설계
- [ ] 감사 필드 포함 (created_at, updated_at, created_by)
- [ ] PostgreSQL 인덱스 최적화 고려
- [ ] 모든 테이블에 `server_alliance_id` 컬럼 포함

### 3. 레포지토리 계층
- [ ] 복잡한 연산을 위한 QueryDSL 쿼리 구현
- [ ] `findByIdAndServerAllianceId()` 패턴 사용
- [ ] 모든 쿼리에 멀티테넌트 필터링 보장
- [ ] 페시미스틱 락 메서드에도 테넌트 격리 적용

### 4. 서비스 계층 구현
- [ ] 적절한 검증을 포함한 비즈니스 로직 구현
- [ ] 트랜잭션 관리 추가 (@Transactional)
- [ ] `JwtAuthUtils.getCurrentServerAllianceId()` 사용
- [ ] 에러 처리 및 커스텀 예외 포함

### 5. 컨트롤러 계층
- [ ] 프로젝트 규칙을 따르는 REST 엔드포인트 생성
- [ ] 적절한 요청/응답 DTO 추가
- [ ] API 문서화를 위한 Swagger 어노테이션 포함

### 6. 보안 및 검증
- [ ] JWT 토큰 및 사용자 권한 검증
- [ ] Bean Validation을 사용한 입력 검증 추가
- [ ] 권한 체크 구현

### 7. 테스트 요구사항
- [ ] 서비스 계층 단위 테스트 (최소 80% 커버리지)
- [ ] API 엔드포인트 통합 테스트
- [ ] 멀티테넌트 격리 테스트 (필수)
- [ ] 복잡한 쿼리에 대한 성능 테스트

## 프론트엔드 개발 워크플로우 (lastwar-www)

### 1. TypeScript 타입 안전성 (필수)
- [ ] types/ 디렉토리에 적절한 TypeScript 인터페이스 정의
- [ ] 모든 API 응답에 대한 엄격한 타입 체킹
- [ ] 적절한 에러 타입 정의 추가
- [ ] props 및 state 타입 검증

### 2. 컴포넌트 아키텍처
- [ ] 적절한 Next.js App Router 패턴 사용
- [ ] 클라이언트/서버 컴포넌트 분리 구현
- [ ] ShadCN UI 컴포넌트 패턴 준수
- [ ] 반응형 디자인 보장 (모바일 우선)

### 3. API 통합
- [ ] 기존 api-service.ts 패턴을 사용한 API 호출 구현
- [ ] 적절한 에러 처리 및 로딩 상태 추가
- [ ] 적절한 인증 토큰 처리 보장
- [ ] 응답 데이터 타입 검증

### 4. 상태 관리
- [ ] React 훅 (useState, useContext) 적절히 사용
- [ ] 적절한 데이터 페칭 패턴 구현
- [ ] 적절한 곳에 낙관적 업데이트 추가
- [ ] 인증 상태 적절히 처리

### 5. MCP Puppeteer 테스트
- [ ] 주요 사용자 플로우에 대한 E2E 테스트 시나리오 생성
- [ ] 다양한 뷰포트에서 반응형 디자인 테스트
- [ ] 폼 제출 및 데이터 표시 검증
- [ ] 인증 플로우 테스트

## 풀스택 개발 워크플로우

### Phase 1: 백엔드 우선 개발
1. **데이터베이스 설계**: 멀티테넌트 격리를 고려한 스키마 설계
2. **엔터티 및 레포지토리**: QueryDSL과 테넌트 필터링
3. **서비스 계층**: 비즈니스 로직과 보안 검증
4. **REST API**: 표준화된 엔드포인트와 문서화
5. **백엔드 테스트**: 단위 테스트와 통합 테스트

### Phase 2: 프론트엔드 통합
1. **타입 정의**: API 응답에 대한 TypeScript 인터페이스
2. **API 서비스**: 백엔드와의 통신 계층
3. **컴포넌트 개발**: ShadCN UI 패턴 준수
4. **상태 관리**: React 훅과 데이터 플로우
5. **E2E 테스트**: MCP Puppeteer로 사용자 플로우 검증

### Phase 3: 통합 및 품질 보증
1. **풀스택 통합 테스트**: 엔드투엔드 데이터 플로우
2. **성능 최적화**: 백엔드 쿼리와 프론트엔드 번들 최적화
3. **보안 검증**: 멀티테넌트 격리 엔드투엔드 검증
4. **문서화**: API 문서와 사용자 가이드

## Git 워크플로우 규칙 (GitHub MCP 우선)

### 브랜치 전략
- **main**: 운영 브랜치 (프로덕션 배포)
- **feature/기능명**: 새로운 기능 개발
- **fix/수정명**: 기존 기능 수정 및 버그 수정

### 🔄 자동 작업 시작 전 필수 단계 (GitHub MCP 우선)

#### **1단계: GitHub MCP로 원격 상태 확인**
```bash
# 현재 브랜치와 원격 상태 확인 (GitHub MCP 우선)
mcp__github__list_commits     # 최신 커밋 확인
mcp__github__list_pull_requests # 기존 PR 상태 확인
git status                    # 로컬 변경사항 확인
git branch -a                # 모든 브랜치 상태 확인
```

#### **2단계: GitHub MCP로 브랜치 생성**
```bash
# 새 기능 개발 시
mcp__github__create_branch --branch="feature/기능명" --from_branch="main"

# 버그 수정 시  
mcp__github__create_branch --branch="fix/수정명" --from_branch="main"

# 로컬에서 새 브랜치로 전환
git checkout -b feature/기능명  # 또는 fix/수정명
git pull origin feature/기능명  # 원격 브랜치와 동기화
```

### 🔄 개발 진행 중 커밋 규칙 (GitHub MCP 우선)

#### **로컬 커밋 후 GitHub MCP 푸시**
```bash
# 1. 로컬 커밋 (한글 메시지)
git add -A
git commit -m "사용자 목록 API 엔드포인트 구현

- User 엔터티에 server_alliance_id 필터링 추가
- 페이징 및 정렬 기능 포함
- 멀티테넌트 데이터 격리 검증 완료"

# 2. GitHub MCP로 파일 업데이트 (선택사항 - 특정 파일만)
mcp__github__create_or_update_file --path="파일경로" --content="내용" --message="커밋메시지"

# 3. 일반 푸시
git push origin 브랜치명
```

### 🔄 작업 완료 후 필수 단계 (GitHub MCP 우선)

#### **자동 PR 생성 워크플로우**
```bash
# 1. 최종 테스트 실행 및 통과 확인
npm run test  # 또는 ./gradlew test

# 2. 최종 커밋 및 푸시
git add -A
git commit -m "최종 구현 완료"
git push origin 브랜치명

# 3. GitHub MCP로 자동 PR 생성
mcp__github__create_pull_request --title="기능명" --head="브랜치명" --base="main" --body="PR설명"

# 4. PR 상태 확인
mcp__github__get_pull_request --pull_number="PR번호"
```

### 🚨 **중요: GitHub MCP vs Git 명령어 우선순위**

#### **GitHub MCP 우선 사용 (권장)**
- `mcp__github__create_branch` ✅
- `mcp__github__create_pull_request` ✅  
- `mcp__github__list_commits` ✅
- `mcp__github__get_file_contents` ✅
- `mcp__github__push_files` ✅

#### **Git 명령어 사용 (필요시에만)**
- `git status` (로컬 상태 확인용)
- `git add`, `git commit` (로컬 커밋용)
- `git checkout -b` (로컬 브랜치 전환용)

⚠️ **모든 원격 Git 작업은 GitHub MCP를 우선적으로 사용하세요!**

## 품질 게이트

### 백엔드 품질 게이트
- [ ] 멀티테넌트 데이터 격리 검증 완료
- [ ] 모든 쿼리가 server_alliance_id 필터링 사용
- [ ] 테스트 커버리지 80% 이상
- [ ] API 문서 업데이트 완료
- [ ] 성능 벤치마크 통과
- [ ] 보안 검증 완료

### 프론트엔드 품질 게이트
- [ ] TypeScript strict 모드 준수
- [ ] 모든 API 응답 적절히 타입화
- [ ] 반응형 디자인 테스트 완료 (모바일/태블릿/데스크톱)
- [ ] 접근성 표준 충족 (WCAG 2.1 AA)
- [ ] MCP Puppeteer E2E 테스트 통과
- [ ] 성능 벤치마크 유지

### 풀스택 품질 게이트
- [ ] 멀티테넌트 데이터 격리 엔드투엔드 검증
- [ ] 완전한 데이터 플로우 테스트 통과
- [ ] 보안 검증 완료 (인증, 권한, 데이터 격리)
- [ ] 성능 최적화 완료
- [ ] 문서화 업데이트 완료

## 중요 참고사항

### 🚨 **자동 워크플로우 실행 (필수)**
- **모든 개발 작업 시 GitHub MCP 기반 Git 워크플로우 자동 실행**
- **사용자가 명시하지 않아도 브랜치 생성과 PR 자동 처리**
- **GitHub MCP 우선 사용으로 원격 저장소와 자동 동기화**

### 작업 위치 준수 (필수)
- **루트 레벨 (`/lastwar/`)**: Task Master, Claude 설정만. 코드 변경 시 Git 관리 안함
- **백엔드 코드**: 반드시 `/lastwar-api/` 디렉토리로 이동하여 작업
- **프론트엔드 코드**: 반드시 `/lastwar-www/` 디렉토리로 이동하여 작업
- **Git 커밋**: GitHub MCP 우선, 필요시 각 프로젝트 디렉토리에서 수행

### GitHub MCP 우선 사용 (필수)
- **브랜치 생성**: `mcp__github__create_branch` 우선 사용
- **PR 생성**: `mcp__github__create_pull_request` 자동 실행
- **파일 업로드**: `mcp__github__push_files` 또는 `mcp__github__create_or_update_file`
- **상태 확인**: `mcp__github__list_commits`, `mcp__github__get_pull_request`

### 멀티테넌트 보안 (자동 적용)
- **필수**: 모든 데이터베이스 쿼리에 `server_alliance_id` 필터링
- **필수**: JWT에서 추출한 테넌트 ID만 사용
- **필수**: 교차 테넌트 접근 방지 테스트
- **자동**: 개발 시 멀티테넌트 격리 검증 자동 실행

### 개발 우선순위
1. **보안**: 멀티테넌트 격리 최우선
2. **안정성**: 테스트 커버리지와 에러 처리
3. **성능**: 쿼리 최적화와 번들 크기
4. **사용자 경험**: 반응형 디자인과 접근성

### Claude Code 사용 팁
- **GitHub MCP 자동 사용**: 모든 Git 작업에서 MCP 우선
- **자동 브랜치 관리**: 작업 시작 시 적절한 브랜치 자동 생성
- **작업 위치 엄수**: 백엔드는 `/lastwar-api/`, 프론트엔드는 `/lastwar-www/`에서만 코딩
- **루트 레벨 용도**: Task Master 계획 수립과 전체 프로젝트 관리만
- **자동 품질 확인**: 멀티테넌트 격리, 테스트, 커밋 메시지 자동 검증
- **자동 PR 생성**: 작업 완료 시 GitHub MCP로 PR 자동 생성

## GitHub MCP 통합 워크플로우

### GitHub 저장소 관리
GitHub MCP를 통해 원격 저장소와 통합된 개발 워크플로우를 제공합니다.

#### 주요 GitHub 저장소
- **ljy9303/lastwar-www**: 프론트엔드 프로젝트 (읽기/쓰기 권한)
- **ljy9303/lastwar-api**: 백엔드 프로젝트 (향후 연동 예정)
- **ljy9303/cm-tm**: 공통 Task Master 설정

#### GitHub MCP 주요 기능

##### 1. 저장소 조회 및 탐색
```bash
# 본인 저장소 목록 조회
mcp__github__search_repositories: user:ljy9303

# 특정 파일 내용 조회
mcp__github__get_file_contents: owner/repo/path

# 커밋 히스토리 조회
mcp__github__list_commits: owner/repo
```

##### 2. 파일 관리
```bash
# 파일 생성/수정
mcp__github__create_or_update_file: 
  - path: 파일 경로
  - content: 파일 내용
  - message: 커밋 메시지
  - branch: 대상 브랜치

# 여러 파일 한번에 푸시
mcp__github__push_files:
  - files: [파일 배열]
  - message: 커밋 메시지
```

##### 3. 브랜치 및 PR 관리
```bash
# 새 브랜치 생성
mcp__github__create_branch:
  - branch: 브랜치명
  - from_branch: 기준 브랜치

# Pull Request 생성
mcp__github__create_pull_request:
  - title: PR 제목
  - body: PR 설명
  - head: 소스 브랜치
  - base: 타겟 브랜치
```

##### 4. 이슈 관리
```bash
# 이슈 생성
mcp__github__create_issue:
  - title: 이슈 제목
  - body: 이슈 내용
  - labels: 라벨 배열

# 이슈 목록 조회
mcp__github__list_issues:
  - state: open/closed/all
  - labels: 필터링할 라벨
```

### GitHub MCP 활용 시나리오

#### 1. 로컬-리모트 동기화 워크플로우
```bash
# 1. 로컬에서 개발 완료
cd /lastwar/lastwar-www
git add .
git commit -m "기능 구현 완료"

# 2. GitHub MCP로 리모트 확인
mcp__github__get_file_contents: 최신 파일 상태 확인

# 3. 충돌 없으면 푸시
git push origin feature/새기능

# 4. GitHub MCP로 PR 생성
mcp__github__create_pull_request: 자동 PR 생성
```

#### 2. 코드 리뷰 및 배포 워크플로우
```bash
# 1. PR 상태 확인
mcp__github__get_pull_request: PR 상세 정보

# 2. 변경사항 검토
mcp__github__get_pull_request_files: 변경된 파일 목록

# 3. 리뷰 추가
mcp__github__create_pull_request_review: 
  - event: APPROVE/REQUEST_CHANGES/COMMENT
  - body: 리뷰 내용

# 4. 머지 실행
mcp__github__merge_pull_request: 
  - merge_method: merge/squash/rebase
```

#### 3. 이슈 트래킹 워크플로우
```bash
# 1. 버그 발견 시 이슈 생성
mcp__github__create_issue:
  - title: "버그: 사용자 로그인 실패"
  - body: 상세 버그 리포트
  - labels: ["bug", "high-priority"]

# 2. 개발 중 이슈 업데이트
mcp__github__add_issue_comment:
  - body: 진행 상황 업데이트

# 3. 해결 완료 시 이슈 종료
mcp__github__update_issue:
  - state: closed
```

### GitHub MCP 모범 사례

#### 1. 프론트엔드 개발 (lastwar-www)
- **로컬 우선 개발**: 로컬에서 기능 구현 후 MCP로 동기화
- **자동 PR 생성**: 기능 완료 시 MCP로 즉시 PR 생성
- **코드 리뷰 강화**: MCP를 통한 체계적 리뷰 프로세스

#### 2. 백엔드 개발 (lastwar-api)
- **API 문서 동기화**: Swagger 문서를 GitHub에 자동 커밋
- **테스트 결과 공유**: 테스트 리포트를 이슈로 자동 생성
- **배포 히스토리 관리**: 배포 태그 및 릴리즈 노트 자동화

#### 3. 프로젝트 관리
- **태스크-이슈 연동**: Task Master 태스크를 GitHub 이슈로 변환
- **마일스톤 관리**: 주요 기능별 마일스톤 설정 및 추적
- **자동화된 워크플로우**: GitHub Actions와 연동 고려

### GitHub MCP 보안 고려사항
- **권한 최소화**: 필요한 권한만 부여
- **토큰 관리**: GitHub Personal Access Token 안전한 보관
- **브랜치 보호**: main 브랜치에 대한 직접 푸시 방지
- **리뷰 필수화**: 중요 변경사항은 반드시 코드 리뷰 거치기

### GitHub MCP 설정 확인
현재 MCP 설정 상태:
- ✅ ljy9303/lastwar-www: 읽기/쓰기 권한 확인됨
- ✅ ljy9303/cm-tm: 공통 설정 저장소 접근 가능
- ✅ 파일 생성/수정/삭제 테스트 완료
- ✅ 커밋 및 푸시 기능 정상 작동

---

_이 가이드는 Claude Code가 LastWar 프로젝트의 개발 워크플로우를 자동으로 적용하기 위한 통합 규칙입니다._