# final_project

1) sudo apt-add-repository ppa:ansible/ansible
   apt update
   apt install -y ansible
2) ansible-galaxy collection install community.docker

3) install terraform
   - apt install -y gnupg software-properties-common curl
   - curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   - apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   - apt update
   - apt install terraform

4) Copy file main.tf to terraform folder
   - export credential variables for work terraform with AWS
   - terraform init (in some folder for terraform)

5) Terraform plan (for check main.tf)

6) Terraform apply (for create infrastructure)

7) Apply ansible playbook docker.yml to server for jenkins (insert correct IP to insventory)

8) Connect to jenkins server via port 8080 with browser for first configuration

9) Create job in jenkins for pipeline from github

10) Change settings github repository for correctly work webhook
    (change IPs in pipeline)

11) Make change in some file in repository for run job
