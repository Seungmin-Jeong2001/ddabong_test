# Bucheong Cat Monitor Setup

이 프로젝트는 GCP 서버 구축, Cloudflare DNS 설정, 그리고 서버 상태 모니터링을 자동화합니다.

## 구성 요소
- **Terraform**: GCP 인스턴스 (Ubuntu 22.04) 및 Cloudflare DNS (bucheongoyangijanggun.com) 설정.
- **Ansible**: Nginx 설치 및 CCTV/장비 상태 플레이스홀더 웹페이지 배포.
- **Monitoring**: 10분마다 사이트 상태를 체크하여 다운 시 디스코드로 알림 전송.
- **GitHub Actions**: 모든 과정의 자동화 (CI/CD).

## 필요한 GitHub Secrets
GitHub 레포지토리 설정에서 다음 시크릿들을 등록해야 합니다:

1. `GCP_SA_KEY`: GCP 서비스 계정 키 (JSON 형식).
2. `GCP_PROJECT_ID`: GCP 프로젝트 ID.
3. `CLOUDFLARE_API_TOKEN`: Cloudflare API 토큰.
4. `CLOUDFLARE_ZONE_ID`: Cloudflare Zone ID (bucheongoyangijanggun.com).
5. `SSH_PUB_KEY`: 서버에 등록할 SSH 공개키 (`id_rsa.pub` 내용).
6. `SSH_PRIVATE_KEY`: Ansible 접속용 SSH 개인키 (`id_rsa` 내용).

## 인프라 상태 관리 (GCS Backend)
테라폼 상태 파일(`.tfstate`)은 안전한 관리를 위해 GCP 버킷에 저장되도록 설정되어 있습니다.
- **버킷 이름**: `terraform-state-bucheong-cat` (수동으로 생성해 주세요.)

## 인프라 삭제 (Destroy)
인프라를 완전히 삭제하려면 GitHub Actions의 **Actions > Infrastructure Destruction** 워크플로우를 수동으로 실행(`Run workflow`)하세요. 실수 방지를 위해 수동 실행으로만 작동합니다.

## 파일 구조
- `.github/workflows/`: GitHub Actions 워크플로우 (Infra, Deploy, Monitor).
- `terraform/`: 테라폼 설정 파일.
- `ansible/`: 앤서블 플레이북 및 웹 템플릿.
- `monitoring/`: 헬스 체크 스크립트.
