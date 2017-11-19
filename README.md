# mastino

Configuration for local DataCite development. Uses [Minikube](https://github.com/kubernetes/minikube) to run a local [Kubernetes](https://kubernetes.io/) cluster to manage containerized applications, and [Terraform](https://www.terraform.io/) for configuration.

## Installation

Install Minikube and Terraform:

Use Homebrew on a Mac, and install the [xhyve](https://github.com/mist64/xhyve) hypervisor:

```
brew install docker-machine-driver-xhyve
brew cask install minikube
brew install terraform
```

Start Kubernetes cluster and check the IP address

```
minikube start
minikube ip
```

Go to the kubernetes dashboard with

```
minikube dashboard
```

Which is opens up a browser window at http://IP_ADDRESS:30000.

Initialize Terraform with

```
terraform init
```

## Configuration

Use Terraform to configure your Kubernetes cluster, using the terraform configuration files (*.tf) in this repo.

```
terraform plan
terraform apply
```
