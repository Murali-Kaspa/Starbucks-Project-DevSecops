#!/bin/bash
read -rp "Do you want to install DevOps Tools (yes/no): " userinput
if [[ "$userinput" == "yes" ]]; then
    echo "Tools are starting to install..."
    for ((i=1; i<=5; i++)); do
        echo "Installation begins in ${i} seconds..."
        sleep 1
    done

    echo "---------------------------------------------"
    echo "🚀 Installing Jenkins and Dependencies..."
    echo "---------------------------------------------"

    sudo yum install java-17-amazon-corretto -y
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    sudo yum upgrade -y
    sudo yum install jenkins -y
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    sleep 5
    sudo usermod -aG jenkins $USER
    echo "✅ Jenkins Installed Successfully!"
    echo
    password=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
    echo "🔑 Jenkins initial admin password is: ${password}"
    echo
    echo "👉 You can now access Jenkins at: echo "http://$(curl -s ifconfig.me):8080""
    
    echo "---------------------------------------------"
    echo "🎉 Installing Docker!"
    echo "---------------------------------------------"
    sudo yum install docker -y
    sudo service docker start
    sleep 5
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sleep 5
    sudo usermod -aG docker jenkins
    sudo docker --version
    #Always restart the server to get the full permissions of docker.

    echo "---------------------------------------------"
    echo "🎉 Installing SonarQube!"
    echo "---------------------------------------------"
    
    docker run -itd --name sonarimage -p 9000:9000 sonarqube:lts-community

    echo "---------------------------------------------"
    echo "🎉 Installing AWSCLI!"
    echo "---------------------------------------------"
    sudo apt update
    sudo apt install unzip -y
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    aws --version


    echo "---------------------------------------------"
    echo "🎉 Installing EKSCTL"
    echo "---------------------------------------------"
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    eksctl version

    echo "---------------------------------------------"
    echo "🎉 Installing Kubectl!"
    echo "---------------------------------------------"

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    kubectl version --client

    echo "---------------------------------------------"
    echo "🎉 Installing Trivy!"
    echo "---------------------------------------------"
    
    wget https://github.com/aquasecurity/trivy/releases/download/v0.64.1/trivy_0.64.1_Linux-64bit.rpm
    sudo rpm -ivh trivy_0.64.1_Linux-64bit.rpm
    trivy --version
    sleep 20
    rm -rf trivy_*




else
    echo "Installation skipped."
fi

