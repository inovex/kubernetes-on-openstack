#cloud-config
datasource:
 OpenStack:
  metadata_urls: ["http://169.254.169.254"]
  max_wait: -1
  timeout: 10
  retries: 5

repo_update: true
repo_upgrade: all
package_upgrade: true

apt:
  preserve_sources_list: true
  sources:
    kubernetes.list:
      source: "deb http://apt.kubernetes.io/ kubernetes-xenial main"
      key: |
        -----BEGIN PGP PUBLIC KEY BLOCK-----
        Version: GnuPG v1

        mQENBFrBaNsBCADrF18KCbsZlo4NjAvVecTBCnp6WcBQJ5oSh7+E98jX9YznUCrN
        rgmeCcCMUvTDRDxfTaDJybaHugfba43nqhkbNpJ47YXsIa+YL6eEE9emSmQtjrSW
        IiY+2YJYwsDgsgckF3duqkb02OdBQlh6IbHPoXB6H//b1PgZYsomB+841XW1LSJP
        YlYbIrWfwDfQvtkFQI90r6NknVTQlpqQh5GLNWNYqRNrGQPmsB+NrUYrkl1nUt1L
        RGu+rCe4bSaSmNbwKMQKkROE4kTiB72DPk7zH4Lm0uo0YFFWG4qsMIuqEihJ/9KN
        X8GYBr+tWgyLooLlsdK3l+4dVqd8cjkJM1ExABEBAAG0QEdvb2dsZSBDbG91ZCBQ
        YWNrYWdlcyBBdXRvbWF0aWMgU2lnbmluZyBLZXkgPGdjLXRlYW1AZ29vZ2xlLmNv
        bT6JAT4EEwECACgFAlrBaNsCGy8FCQWjmoAGCwkIBwMCBhUIAgkKCwQWAgMBAh4B
        AheAAAoJEGoDCyG6B/T78e8H/1WH2LN/nVNhm5TS1VYJG8B+IW8zS4BqyozxC9iJ
        AJqZIVHXl8g8a/Hus8RfXR7cnYHcg8sjSaJfQhqO9RbKnffiuQgGrqwQxuC2jBa6
        M/QKzejTeP0Mgi67pyrLJNWrFI71RhritQZmzTZ2PoWxfv6b+Tv5v0rPaG+ut1J4
        7pn+kYgtUaKdsJz1umi6HzK6AacDf0C0CksJdKG7MOWsZcB4xeOxJYuy6NuO6Kcd
        Ez8/XyEUjIuIOlhYTd0hH8E/SEBbXXft7/VBQC5wNq40izPi+6WFK/e1O42DIpzQ
        749ogYQ1eodexPNhLzekKR3XhGrNXJ95r5KO10VrsLFNd8I=
        =TKuP
        -----END PGP PUBLIC KEY BLOCK-----
write_files:
-   content: |
        apiVersion: v1
        clusters:
        - cluster:
            insecure-skip-tls-verify: true
            server: https://localhost:8443/webhook
          name: webhook
        contexts:
        - context:
            cluster: webhook
            user: webhook
          name: webhook
        current-context: webhook
        kind: Config
        preferences: {}
        users:
        - name: webhook
    path: /etc/kubernetes/pki/webhook.kubeconfig
    owner: root:root
    permissions: '0644'
-   content: |
        [Global]
        username="${username}"
        password="${password}"
        auth-url="${auth_url}"
        tenant-id="${project_id}"
        domain-name="${domain_name}"

        [LoadBalancer]
        subnet-id="${subnet_id}"
        floating-network-id="${public_network_id}"
        create-monitor="true"
        monitor-delay="10s"
        monitor-timeout="2000s"
        monitor-max-retries="3"
    path: /etc/kubernetes/pki/cloud-config
    owner: root:root
    permissions: '0600'
-   content: |
        apiVersion: kubeadm.k8s.io/v1alpha2
        kind: MasterConfiguration
        kubernetesVersion: v${kubernetes_version}
        cloudProvider: external
        api:
          advertiseAddress: ${external_ip}
          bindPort: 6443
          controlPlaneEndpoint: ""
        auditPolicy:
          logDir: /var/log/kubernetes/audit
          logMaxAge: 2
          path: ""
        apiServerCertSANs:
          - ${external_ip}
        bootstrapTokens:
          - groups:
            - system:bootstrappers:kubeadm:default-node-token
            token: ${bootstrap_token}
            ttl: 24h0m0s
            usages:
            - signing
            - authentication
            certificatesDir: /etc/kubernetes/pki
            clusterName: kubernetes
        etcd:
          local:
            dataDir: /var/lib/etcd
            image: ""
        imageRepository: k8s.gcr.io
        kubeProxy:
          config:
            bindAddress: 0.0.0.0
            clientConnection:
              acceptContentTypes: ""
              burst: 10
              contentType: application/vnd.kubernetes.protobuf
              kubeconfig: /var/lib/kube-proxy/kubeconfig.conf
              qps: 5
            clusterCIDR: ""
            configSyncPeriod: 15m0s
            conntrack:
              max: null
              maxPerCore: 32768
              min: 131072
              tcpCloseWaitTimeout: 1h0m0s
              tcpEstablishedTimeout: 24h0m0s
            enableProfiling: false
            healthzBindAddress: 0.0.0.0:10256
            hostnameOverride: ""
            iptables:
              masqueradeAll: false
              masqueradeBit: 14
              minSyncPeriod: 0s
              syncPeriod: 30s
            ipvs:
              ExcludeCIDRs: null
              minSyncPeriod: 0s
              scheduler: ""
              syncPeriod: 30s
            metricsBindAddress: 127.0.0.1:10249
            mode: "ipvs"
            nodePortAddresses: null
            oomScoreAdj: -999
            portRange: ""
            resourceContainer: /kube-proxy
            udpIdleTimeout: 250ms
        kubeletConfiguration:
          baseConfig:
            address: 0.0.0.0
            authentication:
              anonymous:
                enabled: false
              webhook:
                cacheTTL: 2m0s
                enabled: true
              x509:
                clientCAFile: /etc/kubernetes/pki/ca.crt
            authorization:
              mode: Webhook
              webhook:
                cacheAuthorizedTTL: 5m0s
                cacheUnauthorizedTTL: 30s
            cgroupDriver: systemd
            cgroupsPerQOS: true
            cgroupRoot: "/"
            clusterDNS:
            - 10.96.0.10
            clusterDomain: cluster.local
            containerLogMaxFiles: 5
            containerLogMaxSize: 10Mi
            contentType: application/vnd.kubernetes.protobuf
            cpuCFSQuota: true
            cpuManagerPolicy: none
            cpuManagerReconcilePeriod: 10s
            enableControllerAttachDetach: true
            enableDebuggingHandlers: true
            enforceNodeAllocatable:
            - pods
            eventBurst: 10
            eventRecordQPS: 5
            evictionHard:
              imagefs.available: 15%
              memory.available: 100Mi
              nodefs.available: 10%
              nodefs.inodesFree: 5%
            evictionPressureTransitionPeriod: 5m0s
            failSwapOn: true
            fileCheckFrequency: 20s
            hairpinMode: promiscuous-bridge
            healthzBindAddress: 127.0.0.1
            healthzPort: 10248
            httpCheckFrequency: 20s
            imageGCHighThresholdPercent: 85
            imageGCLowThresholdPercent: 80
            imageMinimumGCAge: 2m0s
            iptablesDropBit: 15
            iptablesMasqueradeBit: 14
            kubeAPIBurst: 10
            kubeAPIQPS: 5
            makeIPTablesUtilChains: true
            maxOpenFiles: 1000000
            maxPods: 110
            nodeStatusUpdateFrequency: 10s
            oomScoreAdj: -999
            podPidsLimit: -1
            port: 10250
            registryBurst: 10
            registryPullQPS: 5
            resolvConf: /etc/resolv.conf
            rotateCertificates: true
            runtimeRequestTimeout: 15m0s
            serializeImagePulls: false
            staticPodPath: /etc/kubernetes/manifests
            streamingConnectionIdleTimeout: 4h0m0s
            syncFrequency: 1m0s
            volumeStatsAggPeriod: 1m0s
        networking:
          serviceSubnet: "10.96.0.0/16"
          dnsDomain: "cluster.local"
          podSubnet: "${pod_subnet}"
        nodeRegistration:
          criSocket: /run/containerd/containerd.sock
          taints:
          - effect: NoSchedule
            key: node-role.kubernetes.io/master
          kubeletExtraArgs:
            cloud-provider: external
            cloud-config: /etc/kubernetes/pki/cloud-config
            container-runtime: remote
            container-runtime-endpoint: unix:///run/containerd/containerd.sock
        unifiedControlPlaneImage: ""
        featureGates:
          Auditing: true
        apiServerExtraArgs:
          cloud-config: /etc/kubernetes/pki/cloud-config
          authentication-token-webhook-config-file: "/etc/kubernetes/pki/webhook.kubeconfig"
          external-hostname: "${external_ip}"
        controllerManagerExtraArgs:
          cloud-config: /etc/kubernetes/pki/cloud-config
    path: /etc/kubernetes/kubeadm.yaml
    owner: root:root
    permissions: '0600'
-   content: |
        kind: StorageClass
        apiVersion: storage.k8s.io/v1
        metadata:
          name: cinder-storage
          annotations:
            storageclass.kubernetes.io/is-default-class: "true"
        provisioner: kubernetes.io/cinder
        parameters:
          fsType: ext4
    path: /etc/kubernetes/addons/storageclass.yaml
    owner: root:root
    permissions: '0600'
-   content: |
        kind: ClusterRoleBinding
        apiVersion: rbac.authorization.k8s.io/v1
        metadata:
          name: cluster-admin-os-admin
        subjects:
        - kind: Group
          name: ${project_id}
          apiGroup: rbac.authorization.k8s.io
        roleRef:
          kind: ClusterRole
          name: cluster-admin
          apiGroup: rbac.authorization.k8s.io
    path: /etc/kubernetes/addons/rbac-default.yaml
    owner: root:root
    permissions: '0600'
-   content: |
        apiVersion: apps/v1
        kind: DaemonSet
        metadata:
          name: k8s-keystone-auth
          namespace: kube-system
          labels:
            k8s-app: k8s-keystone-auth
        spec:
          selector:
            matchLabels:
              k8s-app: k8s-keystone-auth
          updateStrategy:
            type: RollingUpdate
          template:
            metadata:
              labels:
                k8s-app: k8s-keystone-auth
            spec:
              hostNetwork: true
              nodeSelector:
                node-role.kubernetes.io/master: ""
              tolerations:
              - key: node.cloudprovider.kubernetes.io/uninitialized
                value: "true"
                effect: NoSchedule
              - key: node-role.kubernetes.io/master
                effect: NoSchedule
              containers:
                - name: k8s-keystone-auth
                  image: docker.io/k8scloudprovider/k8s-keystone-auth:v0.1.0
                  args:
                    - /bin/k8s-keystone-auth
                    - --v=10
                    - --tls-cert-file
                    - /etc/kubernetes/pki/apiserver.crt
                    - --tls-private-key-file
                    - /etc/kubernetes/pki/apiserver.key
                    - --keystone-policy-file
                    - /etc/kubernetes/webhook/policy.json
                    - --keystone-url=${auth_url}
                  volumeMounts:
                    - mountPath: /etc/kubernetes/pki
                      name: k8s-certs
                      readOnly: true
                    - mountPath: /etc/kubernetes/webhook
                      name: k8s-webhook
                      readOnly: true
                    - mountPath: /etc/ssl/certs
                      name: ca-certs
                      readOnly: true
                  resources:
                    requests:
                      cpu: 200m
                  ports:
                    - containerPort: 8443
                      hostPort: 8443
                      name: https
                      protocol: TCP
              hostNetwork: true
              volumes:
              - hostPath:
                  path: /etc/kubernetes/pki
                  type: DirectoryOrCreate
                name: k8s-certs
              - hostPath:
                  path: /etc/kubernetes/webhook
                  type: DirectoryOrCreate
                name: k8s-webhook
              - hostPath:
                  path: /etc/ssl/certs
                  type: DirectoryOrCreate
                name: ca-certs
    path: /etc/kubernetes/addons/keystone-webhook-ds.yaml
    owner: root:root
    permissions: '0600'
-   content: |
        ---
        apiVersion: v1
        kind: ServiceAccount
        metadata:
          name: cloud-controller-manager
          namespace: kube-system
        ---
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: cloud-controller-manager
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: system:kube-controller-manager
        subjects:
        - kind: ServiceAccount
          name: cloud-controller-manager
          namespace: kube-system
        ---
        apiVersion: v1
        kind: ServiceAccount
        metadata:
          name: cloud-node-controller
          namespace: kube-system
        ---
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: cloud-node-controller
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: system:controller:node-controller
        subjects:
        - kind: ServiceAccount
          name: cloud-node-controller
          namespace: kube-system
        ---
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRole
        metadata:
          name: system:pvl-controller
        rules:
        - apiGroups:
          - ""
          resources:
          - persistentvolumes
          verbs:
          - get
          - list
          - watch
        - apiGroups:
          - ""
          resources:
          - events
          verbs:
          - create
          - patch
          - update
        ---
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: system:pvl-controller
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: system:pvl-controller
        subjects:
        - kind: ServiceAccount
          name: pvl-controller
          namespace: kube-system
        ---
        apiVersion: apps/v1
        kind: DaemonSet
        metadata:
          name: openstack-cloud-controller-manager
          namespace: kube-system
          labels:
            k8s-app: openstack-cloud-controller-manager
        spec:
          selector:
            matchLabels:
              k8s-app: openstack-cloud-controller-manager
          updateStrategy:
            type: RollingUpdate
          template:
            metadata:
              labels:
                k8s-app: openstack-cloud-controller-manager
            spec:
              nodeSelector:
                node-role.kubernetes.io/master: ""
              securityContext:
                runAsUser: 1001
              tolerations:
              - key: node.cloudprovider.kubernetes.io/uninitialized
                value: "true"
                effect: NoSchedule
              - key: node-role.kubernetes.io/master
                effect: NoSchedule
              serviceAccountName: cloud-controller-manager
              containers:
                - name: openstack-cloud-controller-manager
                  image: docker.io/k8scloudprovider/openstack-cloud-controller-manager:v0.1.0
                  args:
                    - /bin/openstack-cloud-controller-manager
                    - --v=2
                    - --cloud-config=/etc/cloud/cloud-config
                    - --cloud-provider=openstack
                    - --use-service-account-credentials=true
                    - --address=127.0.0.1
                  volumeMounts:
                    - mountPath: /etc/kubernetes/pki
                      name: k8s-certs
                      readOnly: true
                    - mountPath: /etc/ssl/certs
                      name: ca-certs
                      readOnly: true
                    - mountPath: /etc/cloud
                      name: cloud-config-volume
                      readOnly: true
                    - mountPath: /usr/libexec/kubernetes/kubelet-plugins/volume/exec
                      name: flexvolume-dir
                  resources:
                    requests:
                      cpu: 200m
              hostNetwork: true
              volumes:
              - hostPath:
                  path: /usr/libexec/kubernetes/kubelet-plugins/volume/exec
                  type: DirectoryOrCreate
                name: flexvolume-dir
              - hostPath:
                  path: /etc/kubernetes/pki
                  type: DirectoryOrCreate
                name: k8s-certs
              - hostPath:
                  path: /etc/ssl/certs
                  type: DirectoryOrCreate
                name: ca-certs
              - name: cloud-config-volume
                configMap:
                  name: cloud-config
    path: /etc/kubernetes/addons/openstack-ccm.yaml
    owner: root:root
    permissions: '0600'
-   content: |
        #!/bin/bash
        set -eu

        curl -sLo /tmp/containerd.tar.gz "https://storage.googleapis.com/cri-containerd-release/cri-containerd-${containerd_version}.linux-amd64.tar.gz"
        tar -C / -xzf /tmp/containerd.tar.gz
        systemctl start containerd
        systemctl enable containerd
        modprobe ip_vs_rr
        modprobe ip_vs_wrr
        modprobe ip_vs_sh
        modprobe ip_vs
        modprobe br_netfilter
        modprobe nf_conntrack_ipv4
        echo '1' > /proc/sys/net/ipv4/ip_forward
        echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
        kubeadm init --config /etc/kubernetes/kubeadm.yaml --skip-token-print
        mkdir -p /root/.kube
        cp -i /etc/kubernetes/admin.conf /root/.kube/config
        mkdir -p /home/ubuntu/.kube
        cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
        chown ubuntu /home/ubuntu/.kube/config
        kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f "https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml"
        kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f "https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml"
        kubectl --kubeconfig=/etc/kubernetes/admin.conf --namespace=kube-system patch daemonset kube-proxy --type=json -p='[{"op": "add", "path": "/spec/template/spec/tolerations/0", "value": {"effect": "NoSchedule", "key": "node.cloudprovider.kubernetes.io/uninitialized", "value": "true"} }]'
        kubectl --kubeconfig=/etc/kubernetes/admin.conf --namespace=kube-system create configmap cloud-config --from-file=/etc/kubernetes/pki/cloud-config
        kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f "/etc/kubernetes/addons"
    path: /usr/local/bin/init.sh
    owner: root:root
    permissions: '0700'

packages:
  - unzip
  - tar
  - apt-transport-https
  - btrfs-tools
  - util-linux
  - nfs-common
  - [kubelet, "${kubernetes_version}-00"]
  - [kubeadm, "${kubernetes_version}-00"]
  - [kubectl, "${kubernetes_version}-00"]
  - jq
  - ipvsadm
  - socat
  - conntrack
  - ipset
  - libseccomp2

# Integrate: https://github.com/dims/openstack-cloud-controller-manager
# https://github.com/kubernetes/cloud-provider-openstack/tree/master/manifests/controller-manager
# https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-controller-manager-with-kubeadm.md
# TODO: create extra dir with kubernetes addons --> remove everythin except OpenStack integration
# The addon deployment can be moved out once we have a stable endpoint
runcmd:
  - [ /usr/local/bin/init.sh ]
