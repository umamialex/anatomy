#!/bin/sh

if [ "$1" != '-l' ] && [ "$1" != '-r' ]; then
    sh reproduce.sh -l | tee -a ./memory.log
    echo >> ./memory.log; echo '----------------------------------------------------------------' >> ./memory.log; echo >> ./memory.log
    exit 0
fi

readNewLine=`echo $'\n#'`

function title {
    echo
    echo -e '\e[95m █████╗ ███╗   ██╗ █████╗ ████████╗ ██████╗ ███╗   ███╗██╗   ██╗
██╔══██╗████╗  ██║██╔══██╗╚══██╔══╝██╔═══██╗████╗ ████║╚██╗ ██╔╝
███████║██╔██╗ ██║███████║   ██║   ██║   ██║██╔████╔██║ ╚████╔╝ 
██╔══██║██║╚██╗██║██╔══██║   ██║   ██║   ██║██║╚██╔╝██║  ╚██╔╝  
██║  ██║██║ ╚████║██║  ██║   ██║   ╚██████╔╝██║ ╚═╝ ██║   ██║   
╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝   ╚═╝\e[0m'
    echo
}

function state {
    now=`date +"%T"`
    color=
    case "$1" in
        info)
            color='\e[96m'
        ;;
        success)
            color='\e[92m'
        ;;
        error)
            color='\e[91m'
        ;;
        warn)
            color='\e[95m'
    esac

    echo -e "$color# $now - $2\e[0m"
    sleep 0.5
}

function check {
    if [ $1 -eq 0 ]; then
        state success "Successfully $3 $4."
        echo
    else
        state error "Error occurred. Unable to $2 $4."
        state error "Command exited with error code $1."

        if ask 'Continue?'; then
            echo
        else
            echo
            state info "Exiting."
            exit $1
        fi
    fi
}

function ask {
    while true; do
        now=`date +"%T"`
        echo -n -e '\e[93m'
        read -e -p "# $now - $1 [y/N] " reply
        echo -n -e '\e[0m'

        case "$reply" in
            y) return 0;;
            N) return 1;;
        esac
    done
}

function binaryWord {
    if [ $1 -eq 1 ]; then
        echo -e '\e[92mYES\e[0m'
    else
        echo -e '\e[91mNO\e[0m'
    fi
}

function serverHoxAppend {
    runuser $behalf -c "echo \"$1\" >> server.hox"
}

if [ "$1" == '-r' ]; then
    echo; echo '----------------------------------------------------------------'; echo
    state info "Restarting Anatomy server setup."
elif [ "$1" == '-v' ] || [ "$1" == '--version' ]; then
    state info 'Anatomy v1.0.0'
    exit 0
else
    clear
    title
    state info 'Starting Anatomy server setup.'
fi
echo

os="$(cat /etc/*-release)"
if [ "$(echo "$os" | grep -q CentOS || echo "$?")" != '1' ]; then
    if [ "$(echo "$os" | grep -q 7 || echo "$?")" != '1' ]; then
        rev='7'
    elif [ "$(echo "$os" | grep -q 6 || echo "$?")" != '1' ]; then
        rev='6'
    elif [ "$(echo "$os" | grep -q 5 || echo "$?")" != '1' ]; then
        rev='5'
    fi
    os='centos'
elif [ "$(echo "$os" | grep -q Fedora || echo "$?")" != '1' ]; then
    if [ "$(echo "$os" | grep -q 20 || echo "$?")" != '1' ]; then
        rev='20'
    elif [ "$(echo "$os" | grep -q 19 || echo "$?")" != '1' ]; then
        rev='19'
    elif [ "$(echo "$os" | grep -q 18 || echo "$?")" != '1' ]; then
        rev='18'
    fi
    os='fedora'
elif [ "$(echo "$os" | grep -q RHEL || echo "$?")" != '1' ]; then
    if [ "$(echo "$os" | grep -q 7 || echo "$?")" != '1' ]; then
        rev='7'
    elif [ "$(echo "$os" | grep -q 6 || echo "$?")" != '1' ]; then
        rev='6'
    elif [ "$(echo "$os" | grep -q 5 || echo "$?")" != '1' ]; then
        rev='5'
    fi
    os='rhel'
fi
state info "Current OS: $os revision $rev"

arch="$(arch)"
if [ "$(echo "$arch" | grep -q 64 || echo "$?" )" != '1' ]; then
    arch='64'
else
    arch='32'
fi
state info "Current Arch: $arch-bit"
echo

user=$(whoami)
state info "Current user: $user"
if [ "$user" != 'root' ]; then
    state error 'Must be running script as root.'
    if ask 'Run as root?'; then
        sudo -- 'sh' 'reproduce.sh' '-r' $user
        exit 0
    else
        state error 'Please rerun the script and login as root.'
        exit 126
    fi
else
    state success 'Logged in as root.'
fi
echo

if [ "$1" == '-r' ]; then
    state info "Installing on behalf of user $2."
    if ask "Continue on behalf of user $2?"; then
        behalf=$2
        state info "Continuing on behalf of user $2."
    else
        state error 'Please choose the user you wish to install the server for.'
        exit 126
    fi
fi
echo

origin=$(pwd)
state info "Current working directory: $origin"
if ask "Continue install in $origin?"; then
    state success "Installing Anatomy in $origin."
else
    state error 'Please clone Anatomy in the desired directory.'
    exit 1
fi
echo

state info 'Loading anatomy hox genes.'
. ./gonads/hox-genes/anatomy.hox
check $? 'load' 'loaded' 'anatomy hox genes'

cd ./gonads
if [ -d 'mitosis' ]; then
    state info 'Cleaning up previous mitosis.'
    rm -r -f mitosis
    check $? 'clean up' 'cleaned up' 'previous mitosis'
fi
state info 'Preparing for mitosis.'
mkdir mitosis
check $? 'prepare' 'prepared' 'for mitosis'
cd $origin

state warn 'If this is the first time running Anatomy, we suggest NOT performing the default automatic install.'
state warn 'A manual installation will allow you to configure your server step-by-step and learn about the setup.'
state warn 'Once finished, you can then choose to save this configuration for future automated installs.'
if ask 'Perform automatic installation as described in server.hox?'; then
    auto=1
else
    auto=0
fi
echo

if ( [ $auto -eq 1 ] && [ $AUTO_UPDATES -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Install updates?' ); then
    state info 'Updating yum to skip broken packages.'
    yum -y install yum-skip-broken
    check $? 'update' 'updated' 'yum'

    cd $origin/gonads
    state info 'Replicating REMI gamete.'
    cp ./gametes/remi-$os-${rev}.gamete ./mitosis/remi.rpm
    check $? 'replicate' 'replicated' 'REMI gamete'

    if [ $os != 'fedora' ]; then
        state info 'Installing EPEL.'
        yum -y install epel-release
        check $? 'install' 'installed' 'EPEL 6.8 RPM'
    fi

    state info 'Installing REMI gamete.'
    yum -y --skip-broken localinstall ./mitosis/remi.rpm --skip-broken
    check $? 'install' 'installed' 'REMI r6 RPM'

    state info 'Installing updates.'
    yum -y update
    check $? 'install' 'installed' 'updates'

    AUTO_UPDATES=1
    cd $origin
else
    AUTO_UPDATES=0
fi

if ( [ $auto -eq 1 ] && [ $AUTO_DEVELOPMENT_TOOLS -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Install Development Tools?' ); then
    state info 'Installing Development Tools.'
    yum -y groupinstall 'Development Tools'
    check $? 'install' 'installed' 'Development Tools'

    AUTO_DEVELOPMENT_TOOLS=1
else
    AUTO_DEVELOPMENT_TOOLS=0
fi

essentials_list="${ESSENTIALS[@]}"
if ( [ $auto -eq 1 ] && [ $AUTO_ESSENTIALS -eq 1 ] ) || ( [ $auto -eq 0 ] && ask "Install essentials? ($essentials_list)" ); then
    state info 'Installing essentials.'
    yum -y install ${ESSENTIALS[@]}
    check $? 'install' 'installed' 'essentials'

    AUTO_ESSENTIALS=1
else
    AUTO_ESSENTIALS=0
fi

if ( [ $auto -eq 1 ] && [ $AUTO_BASHRC -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Install .bashrc hox gene?' ); then
    state info 'Installing .bashrc hox gene.'
    runuser $behalf -c "cp $origin/gonads/hox-genes/bashrc.hox /home/$behalf/.bashrc"
    check $? 'install' 'installed' 'bashrc hox gene'

    state info 'Sourcing new .bashrc.'
    runuser $behalf -c ". /home/$behalf/.bashrc"
    check $? 'source' 'sourced' 'new .bashrc'

    AUTO_BASHRC=1
else
    AUTO_BASHRC=0
fi

vim_plugins_list="${VIM_PLUGINS[@]}"
if ( [ $auto -eq 1 ] && [ $AUTO_VIM -eq 1 ] ) || ( [ $auto -eq 0 ] && ask "Install vim-pathogen and other plugins? ($vim_plugins_list)" ); then
    state info 'Installing vim-pathogen.'
    cd $origin/gonads/chromosomes
    if [ -d 'vim-pathogen' ]; then
        state info 'Pathogen directory already exists.'
        state info 'Deleting to grab latest vim-pathogen.'
        rm -r -f vim-pathogen
        check $? 'delete' 'deleted' 'folder vim-pathogen'
    fi

    state info 'Creating folder gonads/chromosomes/vim-pathogen.'
    runuser $behalf -c "mkdir vim-pathogen"
    check $? 'create' 'created' 'folder gonads/chromosomes/vim-pathogen'

    cd vim-pathogen
    state info 'Cloning vim-pathogen repository.'
    runuser $behalf -c "git clone https://github.com/tpope/vim-pathogen.git"
    check $? 'clone' 'cloned' 'vim-pathogen repository.'

    cd /home/$behalf
    if [ -d '.vim' ]; then
        state info '.vim directory already exists.'
        state info 'Deleting to install latest versions of vim plugins.'
        rm -r -f .vim
        check $? 'delete' 'deleted' 'folder .vim'
    fi

    state info "Creating directory /home/$behalf/.vim."
    runuser $behalf -c "mkdir -p .vim"
    check $? 'create' 'created' "directory /home/$behalf/.vim"

    cd .vim
    state info "Creating directory /home/$behalf/.vim/autoload"
    runuser $behalf -c "mkdir -p autoload"
    check $? 'create' 'created' "directory /home/$behalf/.vim/autoload"
    
    state info "Creating directory /home/$behalf/.vim/bundle"
    runuser $behalf -c "mkdir -p bundle"
    check $? 'create' 'created' "directory /home/$behalf/.vim/bundle"

    state info 'Installing Pathogen files.'
    runuser $behalf -c "cp $origin/gonads/chromosomes/vim-pathogen/*/a*/*vim autoload"
    check $? 'install' 'installed' 'Pathogen files'

    state info 'Installing Vim hox gene.'
    runuser $behalf -c "cp $origin/gonads/hox-genes/vim.hox /home/$behalf/.vimrc"
    check $? 'install' 'installed' 'Vim hox gene'

    cd /home/$behalf/.vim/bundle
    for ((index = 0; index < ${#VIM_PLUGINS[@]}; index++)); do
        vim_plugin="${VIM_PLUGINS[$index]}"
        state info "installing plugin $vim_plugin."
        runuser $behalf -c "git clone https://github.com/$vim_plugin.git"
        check $? 'install' 'installed' "plugin $vim_plugin"
    done

    cd $origin
    AUTO_VIM=1
else
    AUTO_VIM=0
fi

if ( [ $auto -eq 1 ] && [ $AUTO_NODE -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Install Node.js?' ); then
    state info 'Installing Node.js.'
    cd $origin/gonads/chromosomes
    if [ -d 'Node.js' ]; then
        state info 'Node.js directory already exists.'
        state info 'Deleting to grab latest Node.js.'
        rm -r -f Node.js
        check $? 'delete' 'deleted' 'Node.js'
    fi

    state info 'Creating folder gonads/chromosomes/Node.js.'
    runuser $behalf -c 'mkdir Node.js'
    check $? 'create' 'created' 'folder gonads/chromosomes/Node.js'

    cd Node.js
    state info 'Downloading latest Node.js.'
    runuser $behalf -c "wget http://nodejs.org/dist/node-latest.tar.gz"
    check $? 'download' 'downloaded' 'latest Node.js'

    state info 'Untarring node-latest.tar.gz.'
    runuser $behalf -c 'tar -zxvf node-latest.tar.gz'
    check $? 'untar' 'untarred' 'node-latest.tar.gz'

    cd node-v*
    state info 'Configuring Node.js installation.'
    python configure
    check $? 'configure' 'configured' 'Node.js installation'

    state info 'Building Node.js.'
    make
    check $? 'build' 'built' 'Node.js'

    state info 'Installing Node.js.'
    make install
    check $? 'install' 'installed' 'Node.js'

    state info 'Linking node to bin.'
    ln -s /usr/local/bin/node /usr/bin/node
    check $? 'link' 'linked' 'node'

    state info 'Linking npm to bin.'
    ln -s /usr/local/bin/npm /usr/bin/npm
    check $? 'link' 'linked' 'npm'

    state info 'Verifying Node.js installation.'
    node -v
    check $? 'verify' 'verified' 'Node.js installation.'

    state info 'Verifying NPM installation.'
    npm -v
    check $? 'verify' 'verified' 'NPM installation'

    cd $origin
    AUTO_NODE=1
else
    AUTO_NODE=0
fi

node_global_modules_list="${NODE_GLOBAL_MODULES[@]}"
if ( [ $auto -eq 1 ] && [ $AUTO_NODE_GLOBAL_MODULES -eq 1 ] ) || ( [ $auto -eq 0 ] && ask "Install global Node.js modules? ($node_global_modules_list)" ); then
    state info "Installing $node_global_modules_list."
    npm install -g --unsafe-perm ${NODE_GLOBAL_MODULES[@]}
    check $? 'install' 'installed' "$node_global_modules_list"

    AUTO_NODE_GLOBAL_MODULES=1
else
    AUTO_NODE_GLOBAL_MODULES=0
fi

if ( [ $auto -eq 1 ] && [ $AUTO_MONGODB -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Install MongoDB?'; ) then
    state info 'Installing MongoDB gamete.'
    cp $origin/gonads/gametes/mongodb-${arch}.gamete /etc/yum.repos.d/mongodb.repo
    check $? 'install' 'installed' 'MongoDB gamete'

    state info 'Installing MongoDB.'
    yum -y install mongodb-org mongodb-org-server
    check $? 'install' 'installed' 'MongoDB'

    state info 'Verifying MongoDB CLI installation.'
    mongo -version
    check $? 'verify' 'verified' 'MongoDB CLI installation'

    state info 'Verifying MongoDB Server installation.'
    mongod -version
    check $? 'verify' 'verified' 'MongoDB Server installation'

    state info 'Starting MongoDB service.'
    service mongod start
    check $? 'start' 'started' 'MongoDB service'

    state info 'Adding MongoDB service as startup process.'
    chkconfig mongod on
    check $? 'add' 'added' 'MongoDB service as startup process'

    AUTO_MONGODB=1
else
    AUTO_MONGODB=0
fi

if ( [ $auto -eq 1 ] && [ $AUTO_REDIS -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Install Redis?' ); then
    state info 'Installing Redis.'
    yum -y install redis
    check $? 'install' 'installed' 'Redis'

    state info 'Verifying Redis CLI installation.'
    redis-cli -v
    check $? 'verify' 'verified' 'Redis CLI installation'

    state info 'Verifying Redis Server installation.'
    redis-server -v
    check $? 'verify' 'verified' 'Redis Server installation'

    state info 'Starting Redis service.'
    service redis start
    check $? 'start' 'started' 'Redis service'

    state info 'Adding Redis service as startup process.'
    chkconfig redis on
    check $? 'add' 'added' 'Redis service as startup process'

    AUTO_REDIS=1
else
    AUTO_REDIS=0
fi

if ( [ $auto -eq 1 ] && [ $AUTO_POSTGRESQL -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Install PostgreSQL?' ); then
    cd $origin/gonads
    state info 'Replicating PostgreSQL gamete.'
    cp ./gametes/postgresql-$os-$rev-${arch}.gamete ./mitosis/postgresql.rpm
    check $? 'replicate' 'replicated' 'PostgreSQL gamete'

    state info 'Installing PostgreSQL gamete.'
    yum -y localinstall ./mitosis/postgresql.rpm
    check $? 'install' 'installed' 'PostgreSQL gamete'

    state info 'Installing PostgreSQL.'
    yum -y install postgresql93 postgresql93-server postgresql93-devel postgresql93-libs
    check $? 'install' 'installed' 'PostgreSQL'

    state info 'Verifying PostgreSQL installation.'
    psql --version
    check $? 'verify' 'verified' 'PostgreSQL installation'

    state info 'Initializing PostgreSQL.'
    service postgresql-9.3 initdb
    if [ $? -ne 0 ]; then
        state info 'Trying alternate initialization method.'
        /usr/pgsql-9.3/bin/postgresql93-setup initdb
    fi
    check $? 'initialize' 'initialized' 'PostgreSQL'

    state info 'Installing PostgreSQL hox gene.'
    cp ./hox-genes/postgresql.hox /var/lib/pgsql/9.3/data/pg_hba.conf
    check $? 'install' 'installed' 'PostgreSQL'

    state info 'Starting PostgreSQL service.'
    service postgresql-9.3 start
    check $? 'start' 'started' 'PostgreSQL service'

    state info 'Adding PostgreSQL service as startup process.'
    chkconfig postgresql-9.3 on
    check $? 'add' 'added' 'PostgreSQL service as startup process'

    state info 'Linking pg_config to bin.'
    ln -s /usr/pgsql-9.3/bin/pg_config /usr/bin/pg_config
    check $? 'link' 'linked' 'pg_config to bin'

    cd $origin
    AUTO_POSTGRESQL=1
else
    AUTO_POSTGRESQL=0
fi


if ( [ $auto -eq 1 ] && [ $AUTO_SASS -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Install Sass interpreter (Ruby Gem)?' ); then
    state info 'Installing Sass interpreter.'
    gem install sass
    check $? 'install' 'installed' 'Sass Interpreter'

    state info 'Linking sass to bin.'
    ln -s /usr/local/bin/sass /usr/bin/sass
    check $? 'link' 'linked' 'sass to bin'

    state info 'Verifying Sass interpreter installation.'
    runuser $behalf -c 'sass -v'
    check $? 'verify' 'verified' 'Sass interpeter installation'

    AUTO_SASS=1
else
    AUTO_SASS=0
fi

apfInstall=0
if ( [ $auto -eq 1 ] && [ $AUTO_APF -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Install APF?' ); then
    state info 'Installing APF.'
    cd $origin/gonads/chromosomes
    if [ -d 'APF' ]; then
        state info 'APF directory already exists.'
        state info 'Deleting to grab latest APF.'
        rm -r -f APF
        check $? 'delete' 'deleted' 'folder APF'
    fi

    state info 'Creating folder gonads/chromosomes/APF.'
    runuser $behalf -c 'mkdir APF'
    check $? 'create' 'created' 'folder gonads/chromosomes/APF'

    cd APF
    state info 'Downloading latest APF.'
    runuser $behalf -c 'wget http://www.rfxn.com/downloads/apf-current.tar.gz'
    check $? 'download' 'downloaded' 'latest APF'

    state info 'Untarring apf-current.tar.gz.'
    runuser $behalf -c 'tar -zxvf apf-current.tar.gz'
    check $? 'untar' 'untarred' 'apf-current.tar.gz'

    cd *
    sh ./install.sh
    check $? 'install' 'installed' 'APF'

    cd $origin
    AUTO_APF=1
    apfInstall=1
else
    AUTO_APF=0
fi

if [ $apfInstall -eq 1 ] && ( ( [ $auto -eq 1 ] && [ $AUTO_APF_CONFIGURE -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Configure and Start APF?' ) ); then
    state info 'Configuring APF.'
    state warn 'You will still need to set the property DEVEL_MODE to 0 in /etc/apf/conf.apf and run "sudo /usr/sbin/apf -r" after verifying the installation!'

    state info 'Preserving original configuration as /etc/apf/conf.apf.orig.'
    mv /etc/apf/conf.apf /etc/apf/conf.apf.orig
    check $? 'preserve' 'preserved' 'original conf.apf as conf.apf.orig'

    state info 'Preserving original preroute rules as /etc/apf/preroute.rules.orig.'
    mv /etc/apf/preroute.rules /etc/apf/preroute.rules.orig
    check $? 'preserve' 'preserved' 'original preroute.rules as preroute.rules.orig'

    cd $origin/gonads/hox-genes
    
    state info 'Copying apf hox gene.'
    cp apf.hox /etc/apf/conf.apf
    check $? 'copy' 'copied' 'new conf.apf'

    state info 'Copying preroute hox gene.'
    cp preroute.hox /etc/apf/preroute.rules
    check $? 'copy' 'copied' 'new preroute.rules'

    state info 'Linking APF to bin.'
    ln -s /usr/local/sbin/apf /usr/bin/apf
    check $? 'link' 'linked' 'APF to bin'

    state info 'Starting APF.'
    state warn 'If you lose your connection to the server, you will have to tweak /etc/apf/conf.apf. APF will automatically turn off in 5 minutes as a fail safe.'
    apf -r
    check $? 'start' 'started' 'APF'

    state warn 'Remember: You will still need to set the property DEVEL_MODE to 0 in /etc/apf/conf.apf and run "sudo /usr/sbin/apf -r" if you want to make your changes permanent!'

    cd $origin
    AUTO_APF_CONFIGURE=1
else
    AUTO_APF_CONFIGURE=0
fi

if ( [ $auto -eq 1 ] && [ $AUTO_ANATOMY_FRAMEWORK -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Install Anatomy framework?' ); then
    state info 'Installing Anatomy framework.'
    runuser $behalf -c 'anatomy -c'
    check $? 'install' 'installed' 'Anatomy framework'

    AUTO_ANATOMY_FRAMEWORK=1
else
    AUTO_ANATOMY_FRAMEWORK=0
fi

cd $origin/gonads
if [ -d 'mitosis' ]; then
    state info 'Cleaning up mitosis.'
    rm -r -f mitosis
    check $? 'clean up' 'cleaned up' 'mitosis'
fi
cd $origin

if [ $auto -eq 0 ]; then
    state info 'Finished manual install with the following configuration:'
    echo
    state info "Updates:                        $(binaryWord $AUTO_UPDATES)"
    state info "Development Tools:              $(binaryWord $AUTO_DEVELOPMENT_TOOLS)"
    state info "Essentials:                     $(binaryWord $AUTO_ESSENTIALS)"
    state info "Custom .bashrc:                 $(binaryWord $AUTO_BASHRC)"
    state info "Vim:                            $(binaryWord $AUTO_VIM)"
    state info "Node.js:                        $(binaryWord $AUTO_NODE)"
    state info "Node.js Global Modules:         $(binaryWord $AUTO_NODE_GLOBAL_MODULES)"
    state info "MongoDB:                        $(binaryWord $AUTO_MONGODB)"
    state info "Redis:                          $(binaryWord $AUTO_REDIS)"
    state info "PostgreSQL:                     $(binaryWord $AUTO_POSTGRESQL)"
    state info "SASS:                           $(binaryWord $AUTO_SASS)"
    state info "APF:                            $(binaryWord $AUTO_APF)"
    state info "APF Configuration:              $(binaryWord $AUTO_APF_CONFIGURE)"
    state info "Anatomy Framework:              $(binaryWord $AUTO_ANATOMY_FRAMEWORK)"
    echo
    if ask 'Would you like to save this configuration as an server.hox?'; then
        cd $origin/gonads/hox-genes
        state info 'Preserving previous configuration as server.orig.hox'
        runuser $behalf -c 'mv -i server.hox server.orig.hox'
        check $? 'preserve' 'preserved' 'original configuration as server.orig.hox'

        state info 'Saving current configuration as server.hox'
        {
            serverHoxAppend '#!/bin/sh'
            serverHoxAppend
            serverHoxAppend '# This is a config for an automated installation generated from a previous manual installation.'
            serverHoxAppend
            serverHoxAppend "AUTO_UPDATES=$AUTO_UPDATES                             # Fully update all packages."
            serverHoxAppend "AUTO_DEVELOPMENT_TOOLS=$AUTO_DEVELOPMENT_TOOLS         # Group install Development Tools."
            serverHoxAppend "AUTO_ESSENTIALS=$AUTO_ESSENTIALS                       # Install essential packages."
            serverHoxAppend "AUTO_BASHRC=$AUTO_BASHRC                               # Install custom .bashrc settings."
            serverHoxAppend "AUTO_VIM=$AUTO_VIM                                     # Install Vim plugins and vim-pathogen."
            serverHoxAppend "AUTO_NODE=$AUTO_NODE                                   # Install Node.js."
            serverHoxAppend "AUTO_NODE_GLOBAL_MODULES=$AUTO_NODE_GLOBAL_MODULES     # Install Node.js global modules."
            serverHoxAppend "AUTO_MONGODB=$AUTO_MONGODB                             # Install MongoDB."
            serverHoxAppend "AUTO_REDIS=$AUTO_REDIS                                 # Install Redis."
            serverHoxAppend "AUTO_POSTGRESQL=$AUTO_POSTGRESQL                       # Install PostgreSQL."
            serverHoxAppend "AUTO_SASS=$AUTO_SASS                                   # Install SASS gem."
            serverHoxAppend "AUTO_APF=$AUTO_APF                                     # Install APF."
            serverHoxAppend "AUTO_APF_CONFIGURE=$AUTO_APF_CONFIGURE                 # Configure and install APF."
            serverHoxAppend "AUTO_ANATOMY_FRAMEWORK=$AUTO_ANATOMY_FRAMEWORK         # Initialize a Node.js app with the Anatomy framework."
        }
        check $? 'save' 'saved' 'current configuration as server.hox'
    else
        echo
    fi

    cd $origin
fi

state info 'Installation complete! Enjoy your newly setup server!'
