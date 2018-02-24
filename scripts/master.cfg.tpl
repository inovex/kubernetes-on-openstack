#cloud-config
# vim /var/lib/cloud/instance/cloud-config.txt
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

         mQENBFUd6rIBCAD6mhKRHDn3UrCeLDp7U5IE7AhhrOCPpqGF7mfTemZYHf/5Jdjx
         cOxoSFlK7zwmFr3lVqJ+tJ9L1wd1K6P7RrtaNwCiZyeNPf/Y86AJ5NJwBe0VD0xH
         TXzPNTqRSByVYtdN94NoltXUYFAAPZYQls0x0nUD1hLMlOlC2HdTPrD1PMCnYq/N
         uL/Vk8sWrcUt4DIS+0RDQ8tKKe5PSV0+PnmaJvdF5CKawhh0qGTklS2MXTyKFoqj
         XgYDfY2EodI9ogT/LGr9Lm/+u4OFPvmN9VN6UG+s0DgJjWvpbmuHL/ZIRwMEn/tp
         uneaLTO7h1dCrXC849PiJ8wSkGzBnuJQUbXnABEBAAG0QEdvb2dsZSBDbG91ZCBQ
         YWNrYWdlcyBBdXRvbWF0aWMgU2lnbmluZyBLZXkgPGdjLXRlYW1AZ29vZ2xlLmNv
         bT6JAT4EEwECACgFAlUd6rICGy8FCQWjmoAGCwkIBwMCBhUIAgkKCwQWAgMBAh4B
         AheAAAoJEDdGwginMXsPcLcIAKi2yNhJMbu4zWQ2tM/rJFovazcY28MF2rDWGOnc
         9giHXOH0/BoMBcd8rw0lgjmOosBdM2JT0HWZIxC/Gdt7NSRA0WOlJe04u82/o3OH
         WDgTdm9MS42noSP0mvNzNALBbQnlZHU0kvt3sV1YsnrxljoIuvxKWLLwren/GVsh
         FLPwONjw3f9Fan6GWxJyn/dkX3OSUGaduzcygw51vksBQiUZLCD2Tlxyr9NvkZYT
         qiaWW78L6regvATsLc9L/dQUiSMQZIK6NglmHE+cuSaoK0H4ruNKeTiQUw/EGFaL
         ecay6Qy/s3Hk7K0QLd+gl0hZ1w1VzIeXLo2BRlqnjOYFX4A=
         =HVTm
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
          "bip": "172.26.0.1/16"
        }
    path: /etc/docker/daemon.json
    owner: root:root
    permissions: '0644'
-   content: |
        [Service]
        Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --cloud-provider=openstack --cloud-config=/etc/kubernetes/cloud-config"
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
    path: /etc/kubernetes/cloud-config
    owner: root:root
    permissions: '0600'
-   content: |
        apiVersion: kubeadm.k8s.io/v1alpha1
        kind: MasterConfiguration
        kubernetesVersion: ${kubernetes_version}
        cloudProvider: openstack
        api:
          advertiseAddress: ${external_ip}

        apiServerCertSANs:
          - ${external_ip}

        networking:
          serviceSubnet: "10.96.0.0/16"
          dnsDomain: "cluster.local"
          podSubnet: "${pod_subnet}"

        kubeProxy:
          config:
            mode: ipvs
            featureGates: SupportIPVSProxyMode=true

        featureGates:
          CoreDNS: true

        token: ${bootstrap_token}

        apiServerExtraArgs:
          cloud-config: /etc/kubernetes/cloud-config
          authentication-token-webhook-config-file: "/etc/kubernetes/pki/webhook.kubeconfig"
          external-hostname: "${external_ip}"
        controllerManagerExtraArgs:
          cloud-config: /etc/kubernetes/cloud-config
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
    path: /etc/kubernetes/storageclass.yaml
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
    path: /etc/kubernetes/rbac-default.yaml
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
                  image: johscheuer/k8s-keystone-auth:6d1ddef7-dirty
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
    path: /etc/kubernetes/keystone-webhook-ds.yaml
    owner: root:root
    permissions: '0600'
packages:
  - kubelet
  - kubeadm
  - kubectl
  - jq
  - ipvsadm
  - [docker-ce, 17.03.2~ce-0~ubuntu-xenial]

# integrate: https://github.com/dims/openstack-cloud-controller-manager
# --experimental-keystone-url= auth_url --> didn't work # test v3
# --> https://github.com/coreos/dex/blob/master/Documentation/connectors/gitlab.md
# TODO create extra dir with kubernetes addons
# The addon deployment can be moved out once we have a stable endpoint
runcmd:
  - [ kubeadm, init, --config, /etc/kubernetes/kubeadm.yaml, --skip-token-print ]
  - [ mkdir, -p, /root/.kube ]
  - [ cp, -i, /etc/kubernetes/admin.conf, /root/.kube/config ]
  - [ mkdir, -p, /home/ubuntu/.kube ]
  - [ cp, -i, /etc/kubernetes/admin.conf, /home/ubuntu/.kube/config ]
  - [ chown, ubuntu, /home/ubuntu/.kube/config ]
  - [ kubectl, apply, --kubeconfig=/etc/kubernetes/admin.conf, -f, "https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml" ]
  - [ kubectl, apply, --kubeconfig=/etc/kubernetes/admin.conf, -f, "https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml" ]
  - [ kubectl, apply, --kubeconfig=/etc/kubernetes/admin.conf, -f, "https://raw.githubusercontent.com/kubernetes/dashboard/v1.8.2/src/deploy/recommended/kubernetes-dashboard.yaml" ]
  - [ kubectl, apply, --kubeconfig=/etc/kubernetes/admin.conf, -f, "/etc/kubernetes/storageclass.yaml" ]
  - [ kubectl, apply, --kubeconfig=/etc/kubernetes/admin.conf, -f, "https://raw.githubusercontent.com/kubernetes/heapster/v1.5.1/deploy/kube-config/rbac/heapster-rbac.yaml" ]
  - [ kubectl, apply, --kubeconfig=/etc/kubernetes/admin.conf, -f, "https://raw.githubusercontent.com/kubernetes/heapster/v1.5.1/deploy/kube-config/standalone/heapster-controller.yaml" ]
  - [ kubectl, apply, --kubeconfig=/etc/kubernetes/admin.conf, -f, "/etc/kubernetes/rbac-default.yaml" ]
  - [ kubectl, apply, --kubeconfig=/etc/kubernetes/admin.conf, -f, "/etc/kubernetes/keystone-webhook-ds.yaml" ]
