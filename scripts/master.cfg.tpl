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
            server: https://10.96.0.11:8443/webhook
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
        use-octavia=true

        [BlockStorage]
        bs-version=v2

        [Networking]
        public-network-name=public
        ipv6-support-disabled=false
    path: /etc/kubernetes/pki/cloud-config
    owner: root:root
    permissions: '0600'
-   content: |
        apiVersion: kubeadm.k8s.io/v1beta1
        kind: InitConfiguration
        bootstrapTokens:
        - groups:
          - system:bootstrappers:kubeadm:default-node-token
          token: ${bootstrap_token}
          ttl: 24h0m0s
          usages:
          - signing
          - authentication
        localAPIEndpoint:
          # This will be replaced by sed
          advertiseAddress: ${external_ip}
          bindPort: 6443
        nodeRegistration:
          criSocket: /run/containerd/containerd.sock
          kubeletExtraArgs:
            cloud-config: /etc/kubernetes/pki/cloud-config
            cloud-provider: external
            container-runtime: remote
            container-runtime-endpoint: unix:///run/containerd/containerd.sock
          taints:
          - effect: NoSchedule
            key: node-role.kubernetes.io/master
        ---
        apiVersion: kubeadm.k8s.io/v1beta1
        kind: ClusterConfiguration
        apiServer:
          certSANs:
          - ${external_ip}
          - REPLACE_LOCAL_IP
          extraArgs:
            authentication-token-webhook-config-file: /etc/kubernetes/pki/webhook.kubeconfig
            cloud-config: /etc/kubernetes/pki/cloud-config
            external-hostname: ${external_ip}
          timeoutForControlPlane: 4m0s
        certificatesDir: /etc/kubernetes/pki
        clusterName: kubernetes
        controlPlaneEndpoint: ""
        controllerManager:
          extraArgs:
            cloud-config: /etc/kubernetes/pki/cloud-config
        dns:
          type: CoreDNS
        etcd:
          local:
            dataDir: /var/lib/etcd
        imageRepository: k8s.gcr.io
        kubernetesVersion: v${kubernetes_version}
        networking:
          dnsDomain: cluster.local
          podSubnet: "${pod_subnet}"
          serviceSubnet: 10.96.0.0/16
        scheduler: {}
        ---
        apiVersion: kubeproxy.config.k8s.io/v1alpha1
        kind: KubeProxyConfiguration
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
          excludeCIDRs: null
          minSyncPeriod: 0s
          scheduler: ""
          syncPeriod: 30s
        metricsBindAddress: 127.0.0.1:10249
        mode: ipvs
        nodePortAddresses: null
        oomScoreAdj: -999
        portRange: ""
        resourceContainer: /kube-proxy
        udpIdleTimeout: 250ms
        ---
        kind: KubeletConfiguration
        apiVersion: kubelet.config.k8s.io/v1beta1
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
        cgroupRoot: /
        cgroupsPerQOS: true
        clusterDNS:
        - 10.96.0.10
        clusterDomain: cluster.local
        configMapAndSecretChangeDetectionStrategy: Watch
        containerLogMaxFiles: 5
        containerLogMaxSize: 10Mi
        contentType: application/vnd.kubernetes.protobuf
        cpuCFSQuota: true
        cpuCFSQuotaPeriod: 100ms
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
        nodeLeaseDurationSeconds: 40
        nodeStatusReportFrequency: 10s
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
        kind: Deployment
        metadata:
          name: k8s-keystone-auth
          namespace: kube-system
          labels:
            k8s-app: k8s-keystone-auth
        spec:
          selector:
            matchLabels:
              k8s-app: k8s-keystone-auth
          template:
            metadata:
              labels:
                k8s-app: k8s-keystone-auth
            spec:
              containers:
                - name: k8s-keystone-auth
                  image: k8scloudprovider/k8s-keystone-auth:1.13.1
                  args:
                    - ./bin/k8s-keystone-auth
                    - --v=10
                    - --tls-cert-file
                    - /etc/kubernetes/pki/apiserver.crt
                    - --tls-private-key-file
                    - /etc/kubernetes/pki/apiserver.key
                    - --keystone-url
                    - ${auth_url}
                  volumeMounts:
                    - mountPath: /etc/kubernetes/pki
                      name: k8s-certs
                      readOnly: true
                  resources:
                    requests:
                      cpu: 200m
                  ports:
                    - containerPort: 8443
                      name: https
                      protocol: TCP
              volumes:
              - name: k8s-certs
                secret:
                  secretName: keystone-auth-certs
        ---
        kind: Service
        apiVersion: v1
        metadata:
          name: k8s-keystone-auth-service
          namespace: kube-system
        spec:
          clusterIP: 10.96.0.11
          selector:
            k8s-app: k8s-keystone-auth
          ports:
            - protocol: TCP
              port: 8443
              targetPort: 8443
    path: /etc/kubernetes/addons/keystone-auth-webhook.yaml
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
        apiVersion: v1
        kind: ServiceAccount
        metadata:
          name: cloud-node-controller
          namespace: kube-system
        ---
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: openstack-cloud-controller-manager
          namespace: kube-system
          labels:
            k8s-app: openstack-cloud-controller-manager
        spec:
          selector:
            matchLabels:
              k8s-app: openstack-cloud-controller-manager
          template:
            metadata:
              labels:
                k8s-app: openstack-cloud-controller-manager
            spec:
              securityContext:
                runAsUser: 1001
              tolerations:
              - key: node.cloudprovider.kubernetes.io/uninitialized
                value: "true"
                effect: NoSchedule
              - key: node-role.kubernetes.io/master
                effect: NoSchedule
              serviceAccountName: cloud-controller-manager
              # ToDo Add health checks
              containers:
                - name: openstack-cloud-controller-manager
                  image: k8scloudprovider/openstack-cloud-controller-manager:1.13.1
                  args:
                    - ./bin/openstack-cloud-controller-manager
                    - --v=2
                    - --cloud-config=/etc/cloud/cloud.conf
                    - --cloud-provider=openstack
                    - --use-service-account-credentials=true
                    - --bind-address=127.0.0.1
                  volumeMounts:
                    - mountPath: /etc/ssl/certs
                      name: ca-certs
                      readOnly: true
                    - mountPath: /etc/cloud
                      name: cloud-config-volume
                      readOnly: true
                  resources:
                    requests:
                      cpu: 200m
              volumes:
              - hostPath:
                  path: /etc/ssl/certs
                  type: DirectoryOrCreate
                name: ca-certs
              - name: cloud-config-volume
                secret:
                  secretName: cloud-config
    path: /etc/kubernetes/addons/openstack-ccm.yaml
    owner: root:root
    permissions: '0600'
-   content: |
        #!/bin/bash
        set -eu

        # Setup disk, currently this is broken in cloud-init :(
        sgdisk -n 1:0:0 /dev/sdb
        udevadm settle
        blockdev --rereadpt /dev/sdb
        udevadm settle
        mkfs.ext4 /dev/sdb1
        # mount the newly created partion
        mount -a

        # Install Containerd and load all required modules
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
        # Set local IP address
        # https://cloudinit.readthedocs.io/en/latest/topics/instancedata.html#using-instance-data
        export LOCAL_IP=$(jq -r '.ds.ec2_metadata."local-ipv4"' /run/cloud-init/instance-data.json)
        sed -i "s/^  advertiseAddress: .*$/  advertiseAddress: $${LOCAL_IP}/" /etc/kubernetes/kubeadm.yaml
        sed -i "s/REPLACE_LOCAL_IP/$${LOCAL_IP}/" /etc/kubernetes/kubeadm.yaml

        unset REPLACE_LOCAL_IP
        unset LOCAL_IP
        kubeadm init --config /etc/kubernetes/kubeadm.yaml --skip-token-print
        mkdir -p /root/.kube
        cp -i /etc/kubernetes/admin.conf /root/.kube/config
        mkdir -p /home/ubuntu/.kube
        cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
        chown ubuntu /home/ubuntu/.kube/config

        export KUBECONFIG=/etc/kubernetes/admin.conf
        # a bug prevents downloading from quay.io -> open: could not fetch content descriptor -> https://github.com/containerd/containerd/issues/2840 so currently we limited and stuck with the old version
        kubectl apply -f "https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml"
        kubectl --namespace=kube-system patch daemonset kube-proxy --type=json -p='[{"op": "add", "path": "/spec/template/spec/tolerations/0", "value": {"effect": "NoSchedule", "key": "node.cloudprovider.kubernetes.io/uninitialized", "value": "true"} }]'
        kubectl --namespace=kube-system patch deployment coredns --type=json -p='[{"op": "add", "path": "/spec/template/spec/tolerations/0", "value": {"effect": "NoSchedule", "key": "node.cloudprovider.kubernetes.io/uninitialized", "value": "true"} }]'


        kubectl --namespace=kube-system apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/1.13.1/cluster/addons/rbac/cloud-controller-manager-roles.yaml
        kubectl --namespace=kube-system apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/1.13.1/cluster/addons/rbac/cloud-controller-manager-role-bindings.yaml
        kubectl --namespace=kube-system create secret generic cloud-config --from-file=cloud.conf=/etc/kubernetes/pki/cloud-config
        kubectl --namespace=kube-system create secret generic keystone-auth-certs --from-file=/etc/kubernetes/pki/apiserver.crt --from-file=/etc/kubernetes/pki/apiserver.key
        kubectl apply -f "/etc/kubernetes/addons"

        # Install Metrics Server
        #git clone -b v0.3.1 -- https://github.com/kubernetes-incubator/metrics-server.git
        #kubectl --namespace=kube-system apply -f metrics-server/deploy/1.8+/
        #rm -rf metrics-server

        unset KUBECONFIG
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

# The addon deployment can be moved out once we have a stable endpoint
runcmd:
  - [ /usr/local/bin/init.sh ]

# Does currently not work :( --> has a race condition
# Disk and FS setup
# disk_setup:
#    sdb:
#        table_type: 'mbr'
#        layout: True
#        overwrite: False

# fs_setup:
#    - label: None,
#      filesystem: ext4
#      device: sdb
#      partition: auto

# https://cloudinit.readthedocs.io/en/latest/topics/examples.html#adjust-mount-points-mounted
mounts:
 - [ sdb1, /var/lib/containerd, auto ]
#  - [ sdc, /var/lib/kubelet/ ]
#  - [ xvdh, /opt/data, "auto", "defaults,nofail", "0", "0" ]
#  - [ dd, /dev/zero ]
