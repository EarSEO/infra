# Ansible
Ansible은 여러 노드의 환경을 통합적으로 관리하기 위해 사용하는 프로비저닝 툴입니다.
## TailScale
Tailscale은 WireGuard 기반의 메시 VPN 서비스입니다.<br>
복잡한 설정 없이 여러 디바이스를 P2P로 직접 연결하여 안전한 사설 네트워크를 구축할 수 있습니다.
## Kubespray
Kubespray는 복잡한 k8s 클러스터 환경을 쉽게 구축하기 위해 사용하는 Ansible Playbook 기반 배포 툴입니다.

## 디렉토리 구조
현재 디렉토리 구조는 다음과 같은 구성요소를 가집니다.
```text
ansible
├── inventory/
│   ├── group_vars/
│   │   └── all/                # 모든 호스트에 적용되는 변수
│   │       └── all.yml         # Ansible 실행 사용자 및 권한 설정
│   ├── k8s_cluster/
│   │   ├── addons.yml          # k8s 애드온 설정
│   │   └── k8s-cluster.yml     # k8s 클러스터 관련 설정
│   └── inventory.yaml          # 클러스터 노드 목록 및 역할 정의
├── kubespray/                  # kubespray 서브모듈 디렉토리
├── tailscale/
│   ├── requirements.yaml       # Playbook 에서 사용할 Ansible Role 요구사항 파일
│   └── tailscale-playbook.yaml # tailscale 배포용 Ansible Playbook 파일
├── admin.conf                  # k8s kubeconfig 접근을 위한 파일
└── README.md                   # 현재 디렉토리의 사용방법과 설명 
```

### inventory/group_vars/all/all.yml
모든 호스트에 공통으로 적용되는 Ansible 설정을 정의합니다.
- `ansible_user`: Ansible이 SSH로 접속할 때 사용할 사용자 (vagrant)
- `ansible_become`: sudo 권한 사용 여부

### inventory/k8s_cluster/addons.yml
Kubernetes 클러스터에 설치할 애드온들을 활성화/비활성화하고 설정합니다.
현재 설정값은 `helm`, `metrics server`, `ingress nginx`, `ArgoCD`를 활성화 합니다.

### inventory/k8s_cluster/k8s-cluster.yml
Kubernetes 클러스터의 핵심 설정을 정의합니다.
현재 설정값은 `쿠버네티스 버전`, `컨테이너 런타임`, `CNI 플러그인`, `etcd 배포 방식`을 설정합니다.

### inventory/inventory.yml
Ansible inventory 파일로 클러스터를 구성하는 모든 노드의 정보와 역할을 정의합니다.
- `all.host`: 각 노드의 IP 주소와 SSH 접근 정보
- `kube_control_plane`: control plane 노드
- `kube_node`: worker node 노드
- `etcd`: etcd 클러스터를 구성할 노드 (홀수개여야 함)
- `k8s_cluster`: control plane과 worker node를 포함하는 논리적 그룹

### kubespray/
Kubespray 공식 저장소를 Git submodule로 관리하는 디렉토리입니다.

### admin.conf
배포가 된 Kubernetes 클러스터에 접근하기 위한 kubeconfig 파일입니다.
클러스터 배포 완료 후 control plane의 `/etc/kubernetes/admin.conf`에서 복사하고 server 주소를 수정하여 사용합니다.

## Kubespray 사용 방법
### 사전 설정
#### Python pip
venv로 가상환경을 세팅한다
```shell
cd kubespray
python3 -m venv venv
source venv/bin/activate
pip install ansible-core==2.17.4
pip install passlib==1.7.4
pip install bcrypt<4
pip install -r requirements.txt
```

### Kubespray 실행
`kubespray/` 디렉토리 내에서 가상환경 상에서 아래 명령어를 실행
#### cluster 배포
```shell
ansible-playbook -i ../inventory/inventory.yaml --become --become-user=root cluster.yml
```
#### cluster 제거
```shell
ansible-playbook -i ../inventory/inventory.yaml --become --become-user=root reset.yml
```
#### cluster 노드 추가
inventory.yaml에 새로운 노드 추가 후 아래 스크립트 실행
```shell
ansible-playbook -i ../inventory/inventory.yaml --become --become-user=root scale.yml
```
#### cluster 노드 제거
inventory.yaml에 새로운 노드 제거 후 아래 스크립트 실행
```shell
ansible-playbook -i ../inventory/inventory.yaml --become --become-user=root remove-node.yml
```

### 클러스터 kubeconfig 찾아오기
1. ssh 를 통해서 control plane node의 `/etc/kubernetes/admin.conf` 파일을 가져온다.
2. `admin.yaml`의 `clusters.cluster.server`의 ip와 port를 control plane의 값으로 수정한다.
3. `kubectl --kubeconfig admin.yaml get node`를 통해 정상 작동을 확인한다.

## Tailscale 사용 방법
### 사전 설정
#### Python pip
venv로 가상환경을 세팅한다
```shell
cd tailscale
python3 -m venv venv
source venv/bin/activate
pip install ansible-core==2.17.4
ansible-galaxy install -r requirements.yaml
```

### Ansible Playbook 사용
#### Tailscale 적용
```shell
ansible-playbook -i ../inventory/inventory.yaml tailscale-playbook.yaml \
  -e "tailscale_auth_key=$TAILSCALE_AUTH_KEY"
```
