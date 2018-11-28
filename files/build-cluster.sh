CLUSTER_IP=192.168.122.100
NODES=(master-1 master-2)
IPS=(192.168.16.10 192.168.16.11)
POD_SUBNET="10.244.0.0/16"
for i in "${!NODES[@]}"; do
  HOST=${IPS[$i]}
  NAME=${NODES[$i]}
  INITIAL_CLUSTER=$(
    for j in "${!NODES[@]}"; do
      echo "${NODES[$j]}=https://${IPS[$j]}:2380"
    done | xargs | tr ' ' ,
  )
cat > kubeadm-config-${NODES[$i]}.yaml <<EOT
apiVersion: kubeadm.k8s.io/v1alpha3
kind: InitConfiguration
kubernetesVersion: v1.12.0
apiServerCertSANs:
- "${CLUSTER_IP}"
controlPlaneEndpoint: "${CLUSTER_IP}:6443"
etcd:
  local:
    extraArgs:
      initial-cluster: "${INITIAL_CLUSTER}"
      initial-cluster-state: new
      name: ${NODES[$i]}
      listen-peer-urls: "https://${IPS[$i]}:2380"
      listen-client-urls: "https://127.0.0.1:2379,https://${IPS[$i]}:2379"
      advertise-client-urls: "https://${IPS[$i]}:2379"
      initial-advertise-peer-urls: "https://${IPS[$i]}:2380"
    serverCertSANs:
      - "${NODES[$i]}"
      - "${IPS[$i]}"
    peerCertSANs:
      - "${NODES[$i]}"
      - "${IPS[$i]}"
networking:
    podSubnet: "${POD_SUBNET}"
EOT
done
