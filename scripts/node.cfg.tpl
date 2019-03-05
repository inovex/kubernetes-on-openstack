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
        caCertPath: /etc/kubernetes/pki/ca.crt
        discovery:
          bootstrapToken:
            apiServerEndpoint: ${api_server}:6443
            token: ${bootstrap_token}
            unsafeSkipCAVerification: true
          timeout: 5m0s
          tlsBootstrapToken: ${bootstrap_token}
        kind: JoinConfiguration
        nodeRegistration:
          criSocket: /run/containerd/containerd.sock
          kubeletExtraArgs:
            node-labels: "node-role.kubernetes.io/node=\"\""
            cloud-config: /etc/kubernetes/pki/cloud-config
            cloud-provider: external
            container-runtime: remote
            container-runtime-endpoint: unix:///run/containerd/containerd.sock
    path: /etc/kubernetes/kubeadm.yaml
    owner: root:root
    permissions: '0600'
packages:
  - unzip
  - tar
  - apt-transport-https
  - btrfs-tools
  - util-linux
  - nfs-common
  - [kubelet, "${kubernetes_version}-00"]
  - [kubeadm, "${kubernetes_version}-00"]
  - ipvsadm
  - socat
  - conntrack
  - ipset
  - libseccomp2

bootcmd:
  - sh -c 'while [ ! -b /dev/sdb ]; do sleep 1; done'

disk_setup:
  /dev/sdb:
    table_type: 'mbr'
    layout:
      - [100, 83]
    overwrite: true

fs_setup:
  - label: None
    filesystem: 'ext4'
    device: '/dev/sdb1'
    partition: 'auto'

# https://cloudinit.readthedocs.io/en/latest/topics/examples.html#adjust-mount-points-mounted
mounts:
 - [ /dev/sdb1, /var/lib/containerd, auto ]

runcmd:
  - [ curl, -sLo, /tmp/containerd.tar.gz, "https://storage.googleapis.com/cri-containerd-release/cri-containerd-${containerd_version}.linux-amd64.tar.gz" ]
  - [ tar, -C, /, -xzf, /tmp/containerd.tar.gz ]
  - [ systemctl, start, containerd ]
  - [ systemctl, enable, containerd ]
  - [ modprobe, ip_vs_rr ]
  - [ modprobe, ip_vs_wrr ]
  - [ modprobe, ip_vs_sh ]
  - [ modprobe, ip_vs ]
  - [ modprobe, br_netfilter ]
  - [ modprobe, nf_conntrack_ipv4 ]
  - "echo '1' > /proc/sys/net/ipv4/ip_forward"
  - "echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables"
  - "until kubeadm join  --config=/etc/kubernetes/kubeadm.yaml; do sleep 5; done"
