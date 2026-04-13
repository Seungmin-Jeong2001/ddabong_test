# Bucheong Cat Monitor Setup

이 프로젝트는 GCP 서버 구축, Cloudflare DNS 설정, 그리고 서버 상태 모니터링을 자동화합니다.

## 구성 요소
- **Terraform**: GCP 인스턴스 (Ubuntu 22.04) 및 Cloudflare DNS (bucheongoyangijanggun.com) 설정.
- **Ansible**: 서버에 k3s (경량 쿠버네티스)를 설치하여 컨테이너 실행 환경을 구축합니다.
- **Docker**: `web_docker/`의 소스를 도커 이미지로 빌드하여 Docker Hub에 업로드합니다.
- **Kubernetes (k8s)**: 빌드된 이미지를 배포하고 로드밸런싱을 통해 웹 서비스를 노출합니다.
- **Monitoring**: 10분마다 사이트 상태를 체크하여 다운 시 디스코드로 알림 전송.
- **GitHub Actions**: 인프라 생성, Docker 빌드, K8s 배포, 모니터링의 전체 파이프라인 자동화.

## 아키텍처
- **GCP Compute Engine**: 단일 우분투 서버가 노드로 작동합니다.
- **k3s (Lightweight K8s)**: 앤서블을 통해 서버에 설치되어 컨테이너를 관리합니다.
- **Docker Hub**: `jeongseungmin/ddabong_jeong` 레포지토리에 웹 이미지가 저장됩니다.
- **GitHub Actions**: 
  - 코드가 푸시되면 도커 이미지를 빌드하고 푸시합니다.
  - 이후 서버에 접속하여 `kubectl apply`를 통해 K8s 배포를 수행합니다.

## 필요한 GitHub Secrets
GitHub 레포지토리 설정에서 다음 시크릿들을 등록해야 합니다:

1. `GCP_SA_KEY`: GCP 서비스 계정 키 (JSON 형식).
2. `GCP_PROJECT_ID`: GCP 프로젝트 ID.
3. `CLOUDFLARE_API_TOKEN`: Cloudflare API 토큰.
4. `CLOUDFLARE_ZONE_ID`: Cloudflare Zone ID (bucheongoyangijanggun.com).
5. `SSH_PUB_KEY`: 서버에 등록할 SSH 공개키 (`id_rsa.pub` 내용).
6. `SSH_PRIVATE_KEY`: Ansible 접속 및 K8s 제어용 SSH 개인키 (`id_rsa` 내용).
7. `DOCKER_USERNAME`: Docker Hub 사용자명 (`jeongseungmin`).
8. `DOCKER_PASSWORD`: Docker Hub 비밀번호 또는 Access Token.

## 인프라 상태 관리 (GCS Backend)
테라폼 상태 파일(`.tfstate`)은 안전한 관리를 위해 GCP 버킷에 저장되도록 설정되어 있습니다.
- **버킷 이름**: `terraform-state-bucheong-cat` (수동으로 생성해 주세요.)

## 인프라 삭제 (Destroy)
인프라를 완전히 삭제하려면 GitHub Actions의 **Actions > Infrastructure Destruction** 워크플로우를 수동으로 실행(`Run workflow`)하세요. 실수 방지를 위해 수동 실행으로만 작동합니다.

## 파일 구조
- `.github/workflows/`: GitHub Actions 워크플로우 (Infra, Docker-Build-Deploy, Monitor).
- `terraform/`: 테라폼 설정 파일 (GCP & Cloudflare).
- `ansible/`: k3s 설치를 위한 앤서블 플레이북.
- `web_docker/`: 웹페이지 소스 및 Dockerfile.
- `k8s/`: 쿠버네티스 배포 매니페스트 (Deployment, Service).
- `monitoring/`: 헬스 체크 스크립트.

- ㅇ
