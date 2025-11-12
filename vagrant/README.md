# Vagrant
현재 디렉토리는 `VMware fusion`과 `VMware workstation` 기준으로 작성된 `Vagrantfile` 입니다.
현재 controlplanes과 workers의 구성요소는 완벽히 동일하지만 추후의 차별화된 변경사항이 필요할수도 있어 분리해 구성되었습니다.

## 디렉토리 구조
현재 디렉토리 구조는 다음과 같은 구성요소를 가집니다.
```text
vagrant
├── config.yml # 각 VM의 자원을 yaml로 관리하기 위한 설정파일
├── README.md   # 현재 디렉토리의 사용방법과 설명 
└── Vagrantfile # VMware에 VM을 배포하기 위한 Vagrantfile
```

## config.yml
`config.yml`파일을 통해 각 VM들의 `vcpu`, `mem`, `storage`, `mac주소`, `box`를 커스텀할 수 있습니다.

## Vagrantfile
`Vagrantfile`은 `config.yml`의 `vcpu`, `mem`, `storage`, `mac주소`, `box`을 설정함과 동시에 다음과 같은 설정을 순차적으로 진행합니다.
1. 디스크 확장 및 파일시스템 리사이징
2. SSH 패스워드 인증 허용
3. Chrony를 활용한 타임존 동기화

## Vagrant 설정법
이 디렉토리 Vagrantfile 기반의 환경 구축을 위한 설정 방법은 OS 별로 다음과 같습니다.
#### macOS
```shell
brew tap hashicorp/tap
brew install hashicorp/tap/hashicorp-vagrant

brew install --cask vagrant-vmware-utility
vagrant plugin install vagrant-vmware-desktop
```
#### Windows
[Install Vagrant Hashcorp](https://developer.hashicorp.com/vagrant/install/vmware)

## Vagrant 실행법
Vagrant 명령어를 이용하여 VM을 조작하기 위해 다음과 같은 대표적인 명령어들을 활용합니다.
#### 설치
```shell
vagrant up --provider=vmware_desktop
```
#### 제거
```shell
vagrant destroy -f
```
#### 중지
```shell
vagrant halt
```
#### 배포 상태 확인
```shell
vagrant status
```
#### 비밀번호 없이 ssh로 VM으로 접근
```shell
vagrant ssh vm-name
```

