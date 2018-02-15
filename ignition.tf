provider "ignition" {
  version = "~> v1.0.0"
}

data "ignition_file" "kubeadm" {
    path = "/opt/bin/kubeadm"
    mode = 755
    source {
        source = "https://storage.googleapis.com/kubernetes-release/release/{var.kubernetes_version}/bin/linux/amd64/kubeadm"
        #verification = "sha512-0123456789abcdef0123456789...456789abcdef" <-- TODO add sha too?
    }
}

data "ignition_file" "kubelet" {
    path = "/opt/bin/kubelet"
    mode = 755
    source {
        source = "https://storage.googleapis.com/kubernetes-release/release/{var.kubernetes_version}/bin/linux/amd64/kubelet"
    }
}

data "ignition_file" "kubectl" {
    path = "/opt/bin/kubectl"
    mode = 755
    source {
        source = "https://storage.googleapis.com/kubernetes-release/release/{var.kubernetes_version}/bin/linux/amd64/kubectl"
    }
}


CNI_VERSION=""
mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${var.cni_version}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz





curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${var.kubernetes_version}/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${var.kubernetes_version}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf


systemctl enable kubelet && systemctl start kubelet
