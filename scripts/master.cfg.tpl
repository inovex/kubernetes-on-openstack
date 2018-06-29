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
    docker.list:
      source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
      key: |
         -----BEGIN PGP PUBLIC KEY BLOCK-----
         Version: GnuPG v1

         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
         YT90qFF93M3v01BbxP+EIY2/9tiIPbrd
         =0YYh
         -----END PGP PUBLIC KEY BLOCK-----
write_files:
-   content: |
        {
          "exec-opts": ["native.cgroupdriver=systemd"],
          "bip": "172.26.0.1/16",
          "storage-driver": "overlay2"
        }
    path: /etc/docker/daemon.json
    owner: root:root
    permissions: '0644'
-   content: |
        [Service]
        Environment="KUBELET_EXTRA_ARGS=---cloud-provider=external --cloud-config=/etc/kubernetes/pki/cloud-config"
    path: /etc/systemd/system/kubelet.service.d/20-kubeadm.conf
    owner: root:root
    permissions: '0644'
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
        kubernetesVersion: ${kubernetes_version}
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
            runtimeRequestTimeout: 2m0s
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
          criSocket: /var/run/dockershim.sock
          taints:
          - effect: NoSchedule
            key: node-role.kubernetes.io/master
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
packages:
  - nfs-common
  - kubelet
  - kubeadm
  - kubectl
  - jq
  - ipvsadm
  - [docker-ce, 17.03.2~ce-0~ubuntu-xenial]

# Integrate: https://github.com/dims/openstack-cloud-controller-manager
# https://github.com/kubernetes/cloud-provider-openstack/tree/master/manifests/controller-manager
# https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-controller-manager-with-kubeadm.md
# TODO: create extra dir with kubernetes addons --> remove everythin except OpenStack integration
# The addon deployment can be moved out once we have a stable endpoint
runcmd:
  - [ modprobe, ip_vs_rr ]
  - [ modprobe, ip_vs_wrr ]
  - [ modprobe, ip_vs_sh ]
  - [ modprobe, ip_vs ]
  - [ kubeadm, init, --config, /etc/kubernetes/kubeadm.yaml, --skip-token-print ]
  - [ mkdir, -p, /root/.kube ]
  - [ cp, -i, /etc/kubernetes/admin.conf, /root/.kube/config ]
  - [ mkdir, -p, /home/ubuntu/.kube ]
  - [ cp, -i, /etc/kubernetes/admin.conf, /home/ubuntu/.kube/config ]
  - [ chown, ubuntu, /home/ubuntu/.kube/config ]
  - [ kubectl, --kubeconfig=/etc/kubernetes/admin.conf, apply, -f, "https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml" ]
  - [ kubectl, --kubeconfig=/etc/kubernetes/admin.conf, apply, -f, "https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml" ]
  - [ kubectl, --kubeconfig=/etc/kubernetes/admin.conf, apply, -f, "https://raw.githubusercontent.com/kubernetes/dashboard/v1.8.3/src/deploy/recommended/kubernetes-dashboard.yaml" ]
  - [ kubectl, --kubeconfig=/etc/kubernetes/admin.conf, apply, -f, "https://raw.githubusercontent.com/kubernetes/heapster/v1.5.3/deploy/kube-config/rbac/heapster-rbac.yaml" ]
  - [ kubectl, --kubeconfig=/etc/kubernetes/admin.conf, apply, -f, "https://raw.githubusercontent.com/kubernetes/heapster/v1.5.3/deploy/kube-config/standalone/heapster-controller.yaml" ]
  - [ kubectl, --kubeconfig=/etc/kubernetes/admin.conf, create, configmap, cloud-config, "--from-file=/etc/kubernetes/pki/cloud-config", "--namespace=kube-system" ]
  - [ kubectl, --kubeconfig=/etc/kubernetes/admin.conf, apply, -f, "/etc/kubernetes/addons" ]
