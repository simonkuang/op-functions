# starting network
service network start
chkconfig network on

rpm -ivh "http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"

yum update -y
yum install -y gcc gcc-c++ gcc-objc gcc-objc++ libgcc glibc.* glibc-devel.* \
  glibc-headers glibc-utils glibc-static bintuils-devel db4 db4-c++ db4-devel \
  db4-utils tmux vim-enhanced vim-common ncurses ncurses-devel make cmake \
  imake autoconf automake bind-utils libxml2 libxml2-devel libxslt \
  libxslt-devel unzip m4 sysstat iotop git subversion redis memcached wget \
  curl curl-devel patch telnet
yum install -y python-pip supervisor python-celery

echo '"\e[A": history-search-backward' > ~/.inputrc
echo '"\e[B": history-search-forward' >> ~/.inputrc
echo '"\e[C": forward-char' >> ~/.inputrc
echo '"\e[D": backward-char' >> ~/.inputrc

sed -i "s/alias rm='rm -i'/# alias rm='rm -i'/g" ~/.bashrc
sed -i "s/alias cp='cp -i'/# alias cp='cp -i'/g" ~/.bashrc
sed -i "s/alias mv='mv -i'/# alias mv='mv -i'/g" ~/.bashrc

echo '' >> ~/.bashrc
echo 'alias grep="grep --color=auto"' >> ~/.bashrc
echo 'alias ls="ls --color=auto"' >> ~/.bashrc
echo 'alias l="ls -la"' >> ~/.bashrc
echo 'alias ..="cd .."' >> ~/.bashrc
echo 'alias ...="cd ../.."' >> ~/.bashrc
echo '' >> ~/.bashrc
echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
echo 'export PATH=$PATH:~/bin' >> ~/.bashrc

echo "[easy_install]" > ~/.pydistutils.cfg
echo "index_url = http://pypi.douban.com/simple" >> ~/.pydistutils.cfg
[ -d ~/.pip ] || mkdir ~/.pip
echo "[global]" > ~/.pip/pip.conf
echo "index-url = http://pypi.douban.com/simple" >> ~/.pip/pip.conf

git config --global user.name "simonkuang"
git config --global user.email "me@simonkuang.com"

[ -d ~/.ssh ] || mkdir ~/.ssh
touch ~/.ssh/authorized_keys

sed -i "s/^#UseDNS yes/UseDNS no/g" /etc/ssh/sshd_config
sed -i "s/^#PubkeyAuthentication/PubkeyAuthentication/g" /etc/ssh/sshd_config
sed -i "s/^#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config
