# created by koko  
#个人使用的k8s二进制安装    
#Binary installation of kubernetes    
#通过NTP服务同步各节点时间，DNS完成域名解析，测试环境可用hosts文件代替进行。    
#Use the NTP service to precisely synchronize the time of each node,DNS completes the node   domain name resolution, and the host can be used for the test in the hosts file    
#关闭各节点iptables,firewall服务，确保不被系统引导启动。  
#Close the iptables firewalld service to ensure that it is not booted by the system。  
#关闭各节点SElinux,禁用swap设备，如果要使用ipvs模块，各节点需要载入ipvs(v1.11版本之后)  
#Each node disables SElinux,All nodes are forbidden from swap devices,If the proxy of ipvs module is used, each node needs to load ipvs related module.  

1:  "systemctl start chronyd.service && systemctl enable chronyd.service" 同步时间  

2:   Make a hosts file.做一个hosts文件  
        vi /etc/hosts   
         ipaddress  nodename  
3:   systemctl disable firewalld.service/iptables  

4:   vi /etc/selinux/config   
     SELINUX=disabled             (Use the command "getenforce" to see if the selinux service is down)  

5:   vi /etc/fstab,Unregister the row with swap  

6： #安装docker，添加镜像加速url，有需要可以设置cgroup驱动。docker默认不允许http方式推送镜像，在docker配置文件中配置insecure-registries支持http方式推送镜像   
     wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-repo  
     yum install docker-ce  
      vi /etc/docker/daemon.json  
      {  
       "registry-mirrors": ["https://1yzbll7d.mirror.aliyuncs.com"],  
       #"insecure-registries": ["xxx.xxx.xxx.xxx"],  
       #"exec-opts": ["native.cgroupdriver=systemd"]  
      }  

7: #docker自1.13版本起会自动设置iptables的FORWORD策略为DROP,可能影响k8s集群以来的报文转发功能,因此需在docker启动后重新将策略设置为ACCEPT  
    vi /usr/lib/systemd/system/docker.service  
      execStartPost=/usr/sbin/iptables -P FORWORD ACCEPT  

8:  systemctl daemon-reload  
    systemctl start docker.service  
    
9:  #找到iptables的bridge,复制到/etc/sysctl.conf或创建/etc/sysctl.d/f_name,把那几个bridge行复制过来,并且将0改为1  
    sysctl -a | grep bridge  
    sysctl -p /etc/sysctl.d/f_name  
    systemctl enable docker.service  
    
10: # 到yum.repos.d,建k8s本地kubernetes.repo文件  
       vi /etc/yum.repos.d/kubernetes.repo  
         [kubernetes]  
         name=Kubernetes Repository  
         baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/  
         gpgcheck=1  
         gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg  
         https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg  
         
11:  yum repolist  
     yum install kubeadm kubelet kubectl  

12: #查看所需要的docker镜像，及版本，格式，到k8s官网下载，或者到docker官方仓库下载相应版本的镜像并改名  
     kubeadm config images list  
     kubeadm config images pull  
    #如果涉及到批量更改可以编写脚本操作  
   ##########################################################################    
     #!/bin/sh  
     #a=`docker image ls | grep "k8s.gcr.io*" | awk -F' ' '{print $1}'`  
     #b=`docker image ls | grep "k8s.gcr.io*" | awk -F' ' '{print $2}'`  
     ip=$1  
     rgi=$2  
     k_word=$3  
     ver=$4  

     image=`docker image ls | grep $k_word | awk -F' ' '{print $1":"$2}'`  

     for ig in $image  
     do  
         a=`echo $ig | awk -F':' '{print $1}'`  
         b=`echo $ig | awk -F':' '{print $2}'`  
         c=`echo $ip"/"$rgi"/"$a":"${ver:-$b}`  

        docker tag $ig $c  
        docker push $c  
     done  
   ##########################################################################  

13: #初始化集群并记录kubeadm init执行后的最后的一句命令kubeadm join xxx.xxx.xxx.xxx:6443 --token 2plice.8jgyy3ux2mwxajzv --discovery-token-ca-cert-hash sha256:12f13e7b76df511bfa6c828340e75c1afca75195ea73b27b53c5528e9766a82c  
     
     vi /etc/sysconfig/kubelet  
     KUBELET_EXYRA_ARGS="--fail-swap-on=false"  
     kubeadm init --kubernetes-version=1.16.3 --pod-network-cidr=10.244.1.1/16 --service-cudr=10.96.0.0/12 --ignore-preflight-errors=swap --ignore-preflight-errors=NumCPU  
     --dry-run可以测试运行不用上述镜像下载包  
     --kubernetes-version指定部署的版本  
     --service-cidr指定service分配的网络地址,由k8s管理,默认10.96.0.0/12  
     --pod-network-cidr指定pod分配的网络地址,要与部署的网络插件一致｡(flannel-calico),10.244.0.0/16是flannel默认使用  
     --ignore-preflight-errors=NumCPU有的会对CPU核心有要求，加上这个可以无视  


14: #在家目录下创建 ".kube"目录  
       cp /etc/kubernetes/admin.conf .kube/config  
       chown 用户:用户组 .kube/config  

15: #此时kubectl get nodes是NotReady状态，上述kubeadm init 用的flannel网络插件的IP（10.244.0.0/16)，所以要获取flannel清单，部署flannel网络插件，在https:/github.com/coreos可以找到  
      kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml  

16：#最后查看  
      kubectl get pods -n kube-system  
      
      
 注：
   1: matser节点做上述安装步骤，node节点做到上述"#12"即可  
   2: kubeadm token list查看token令牌，若没有可通过kubeadm token create --print-join-command创建  
   3: 获取master上ca证书的hash值:  
       openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -pubkey | openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d' ' -f1     
   4: 启用ipvs   
      载入相关脚本文件  
       vi /etc/sysconfig/modules/ipvs.modules  
      ###########################################################################  
        #/bin/sh  
        ipvs_mods_dir="/usr/lib/modules/$(uname -r)/kernel/net/netfilter/ipvs"  
        for i in $(ls $ipvs_mods_dir | grep -o "^[^.]*");do  
          /sbin/modinfo -F filename $i  &> /dev/null  
          if  [ $? -eq 0 ];then  
           /sbin/modprobe $i  
          fi      
        done  
       ##########################################################################  
        修改权限并运行,   
