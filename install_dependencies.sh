# Install Dependencies
sudo apt update --quiet

# Install Java
sudo apt install default-jre -y
sudo apt install default-jdk -y

sudo apt update -y

# Install Maven
sudo apt install maven -y

# Install Docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update -y
sudo apt install docker-ce -y
sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Python2
sudo apt -y install python2
sudo ln -s /usr/bin/python2 /usr/bin/python

# Download and unpack YCSB
sudo curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.17.0/ycsb-0.17.0.tar.gz
tar xfvz ycsb-0.17.0.tar.gz

#Login stuff
sudo usermod -aG docker ${USER}
sudo su - ${USER}