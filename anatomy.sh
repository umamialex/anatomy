#!/bin/sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_BIN_DIR="$( dirname "$( readlink -f $SCRIPT_DIR/anatomy )" )"

if [ "$1" != '-l' ] && [ "$1" != '-r' ] && [ "$1" == '' ]; then
  sh $SCRIPT_DIR/anatomy -l $1 $2 $3 $4 | tee -a ./memory.log
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
╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝  ╚═════╝ ╚═╝   ╚═╝   ╚═╝\e[0m'
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

function askOptions {
  while true; do
    now=`date +"%T"`

    options=''
    for option in "$@"; do
      if [ "$option" != "$1" ]; then
        if [ "$option" != "$2" ]; then
          option="/$option"
        fi
        options="$options$option"
      fi
    done
    options="$options/none"

    echo -n -e '\e[93m' 
    read -e -p "# $now - $1 - [$options] " reply
    echo -n -e '\e[0m'

    for option in "$@"; do
      if [ "$option" == "$reply" ]; then
        LAST_ANSWER="$reply"
        return
      fi
    done

    if [ "$reply" == "none" ]; then
      LAST_ANSWER="none"
      return
    fi
  done
}

function binaryWord {
  if [ $1 -eq 1 ]; then
    echo -e '\e[92mYES\e[0m'
  else
    echo -e '\e[91mNO\e[0m'
  fi
}

function greenify {
  if [ $1 == "none" ]; then
    output="<none>"
  else
    output="$1"
  fi

  echo -e "\e[92m$output\e[0m"
}

function autoHoxAppend {
  echo "$1" >> generator.hox
}

function commandsHoxAppend {
  echo "$1" >> commands.hox
}

function findOrigin {
  if [ -d 'node_modules' ]; then
    origin=$(pwd)
    originDirName=${PWD##*/}
  elif [ -d 'gonads' ]; then
    origin=$(pwd)
    originDirName=${PWD##*/}
  elif [ "$(pwd)" == '/home' ]; then
    state error 'Could not locate an Anatomy or Node.js project.'
    exit 1
  else
    cd ..
    findOrigin
  fi
}

if [ "$1" == '-l' ]; then
  if [ "$2" == '-c' ]; then
    echo; echo '----------------------------------------------------------------'; echo
    state info 'Starting Anatomy generator.'
  elif [ "$2" == '' ]; then
    clear
    title
    state info 'Starting Anatomy generator.'
  fi
elif [ "$1" == '-v' ] || [ "$1" == '--version' ]; then
  state info 'Anatomy v1.0.0'
  exit 0
else
  findOrigin

  . $SCRIPT_BIN_DIR/gonads/hox-genes/commands.hox
  if [ -f "$origin/gonads/hox-genes/commands.hox" ]; then
    . $origin/gonads/hox-genes/commands.hox
  fi

  case "$1" in
    name)
      state info "Project name is: '$originDirName'"
    ;;
    root)
      if [ "$2" == '-p' ] || [ "$2" == '--pretty' ]; then
        state info "Root project path is: $origin"
      else
        echo $origin
      fi
    ;;
    skeleton)
      if [ "$2" == '' ]; then
        echo $origin/skeleton
      else
        $COMMANDS_EDITOR $origin/skeleton/${2}.$COMMANDS_SKELETON_EXT
      fi
    ;;
    spine)
      $COMMANDS_EDITOR $origin/skeleton/spine.$COMMANDS_SKELETON_EXT
    ;;
    skin)
      if [ "$2" == '' ]; then
        echo $origin/skin
      else
        $COMMANDS_EDITOR $origin/skin/${2}.$COMMANDS_SKIN_EXT
      fi
    ;;
    dermis)
      if [ "$2" == '' ]; then
        echo $origin/skin/dermis
      else
        $COMMANDS_EDITOR $origin/skin/dermis/${2}.css
      fi
    ;;
    epidermis)
      $COMMANDS_EDITOR $origin/skin/epidermis.$COMMANDS_SKIN_EXT
    ;;
    muscle)
      if [ "$2" == '' ]; then
        echo $origin/muscle
      else
        $COMMANDS_EDITOR $origin/muscle/${2}.$COMMANDS_MUSCLE_EXT
      fi
    ;;
    skeletal)
      $COMMANDS_EDITOR $origin/muscle/skeletal.$COMMANDS_MUSCLE_EXT
    ;;
    visceral)
      if [ "$2" == '' ]; then
        echo $origin/muscle/visceral
      else
        $COMMANDS_EDITOR $origin/muscle/visceral/${2}.$COMMANDS_MUSCLE_EXT
      fi
    ;;
    brain)
      if [ "$2" == '' ]; then
        echo $origin/brain
      else
        $COMMANDS_EDITOR $origin/brain/${2}.$COMMANDS_BRAIN_EXT
      fi
    ;;
    stem)
      $COMMANDS_EDITOR $origin/brain/stem.$COMMANDS_BRAIN_EXT
    ;;
    cerebellum)
      $COMMANDS_EDITOR $origin/brain/cerebellum.$COMMANDS_BRAIN_EXT
    ;;
    cerebrum)
      if [ "$2" == '' ]; then
        echo $origin/brain/cerebrum
      else
        $COMMANDS_EDITOR $origin/brain/cerebrum/${2}.$COMMANDS_BRAIN_EXT
      fi
    ;;
    gonads)
      echo $origin/gonads
    ;;
    hox)
      if [ "$2" == '' ]; then
        echo $origin/gonads/hox-genes
      else
        $COMMANDS_EDITOR $origin/gonads/hox-genes/${2}.hox
      fi
    ;;
    hox-genes)
      if [ "$2" == '' ]; then
        echo $origin/gonads/hox-genes
      else
        $COMMANDS_EDITOR $origin/gonads/hox-genes/${2}.hox
      fi
    ;;
    build)
      $COMMANDS_BUILDER $2
    ;;
    watch)
      $COMMANDS_BUILDER watch
    ;;
    start)
      case "$2" in
        memory)
          $COMMANDS_DAEMONIZER start $origin/brain/stem.js --name "$originDirName"
          $COMMANDS_DAEMONIZER logs $originDirName
        ;;
        once)
          node $origin/brain/stem.js
        ;;
        *)
          $COMMANDS_DAEMONIZER start $origin/brain/stem.js --name "$originDirName"
        ;;
      esac
    ;;
    restart)
      $COMMANDS_DAEMONIZER restart $originDirName
    ;;
    stop)
      $COMMANDS_DAEMONIZER stop $originDirName
    ;;
    kill)
      $COMMANDS_DAEMONIZER delete $originDirName
    ;;
    memory)
      $COMMANDS_DAEMONIZER logs $originDirName
    ;;
    *)
      state error "The command '$1' is not supported. Use help, -h, or --help for a list of commands."
    ;;
  esac
  exit
fi
echo

origin=$(pwd)
state info "Current project directory: $origin"
if ask "Continue in in $origin?"; then
  state success "Installing Anatomy generator in $origin."
else
  state error 'Please run Anatomy in the desired project directory.'
  exit 1
fi
echo

if [ "$2" != '-c' ]; then
  if [ -d 'gonads' ]; then
    gonads=1
    state info 'Loading generator hox gene.'
    . ./gonads/hox-genes/generator.hox
    check $? 'load' 'loaded' 'generator hox gene'

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
  else
    gonads=0
  fi
fi

if [ $gonads -eq 1 ]; then
  state warn 'If this is the first time running Anatomy, we suggest NOT performing the default automatic install.'
  state warn 'A manual installation will allow you to configure the generator for your app step-by-step and learn about the setup.'
  state warn 'Once finished, you can then choose to save this configuration for future automated installs.'
  if ask 'Perform automatic installation as described in generator.hox?'; then
    auto=1
  else
    auto=0
  fi
  echo
else
  auto=0
fi

if ( [ $auto -eq 1 ] && [ $AUTO_FOLDERS -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Create anatomy folder structure?' ); then
  if [ ! -d 'brain' ]; then
    state info 'Spawning brain.'
    mkdir brain
    check $? 'spawn' 'spawned' 'brain'
  fi

  if [ ! -d 'brain/cerebrum' ]; then
    state info 'Spawning brain/cerebrum.'
    mkdir brain/cerebrum
    check $? 'spawn' 'spawned' 'brain/cerebrum'
  fi

  if [ ! -d 'muscle' ]; then
    state info 'Spawning muscle.'
    mkdir muscle
    check $? 'spawn' 'spawned' 'muscle'
  fi

  if [ ! -d 'muscle/visceral' ]; then
    state info 'Spawning muscle/visceral.'
    mkdir muscle/visceral
    check $? 'spawn' 'spawned' 'muscle/visceral'
  fi

  if [ ! -d 'skeleton' ]; then
    state info 'Spawning skeleton.'
    mkdir skeleton
    check $? 'spawn' 'spawned' 'skeleton'
  fi

  if [ ! -d 'skin' ]; then
    state info 'Spawning skin.'
    mkdir skin
    check $? 'spawn' 'spawned' 'skin'
  fi

  if [ ! -d 'skin/dermis' ]; then
    state info 'Spawnking skin/dermis.'
    mkdir skin/dermis
    check $? 'spawn' 'spawned' 'skin/dermis'
  fi

  if [ ! -d 'voice' ]; then
    state info 'Spawning voice.'
    mkdir voice
    check $? 'spawn' 'spawned' 'voice'
  fi

  if [ ! -d 'gonads' ]; then
    state info 'Spawning gonads.'
    mkdir gonads
    check $? 'spawn' 'spawned' 'gonads'
  fi

  if [ ! -d 'gonads/hox-genes' ]; then
    state info 'Spawning gonads/hox-genes.'
    mkdir gonads/hox-genes
    check $? 'spawn' 'spawned' 'gonads/hox-genes'
  fi

  if [ ! -d 'gonads/chromosomes' ]; then
    state info 'Spawning gonads/chromosomes.'
    mkdir gonads/chromosomes
    check $? 'spawn' 'spawned' 'gonads/chromosomes'
  fi

  AUTO_FOLDERS=1
else
  AUTO_FOLDERS=0
fi

if [ $auto -eq 0 ]; then
  askOptions 'What text editor would you like to use?' 'vim' 'emacs' 'gedit' 'nano' 'pico'
  AUTO_EDITOR="$LAST_ANSWER"
fi
COMMANDS_EDITOR=$AUTO_EDITOR

if [ $auto -eq 0 ]; then
  askOptions 'What JavaScript preprocessor would you like to use?' 'coffeescript'
  AUTO_JAVASCRIPT_PREPROCESSOR="$LAST_ANSWER"
fi

case "$AUTO_JAVASCRIPT_PREPROCESSOR" in
  none)
    COMMANDS_MUSCLE_EXT='js'
    COMMANDS_BRAIN_EXT='js'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What templating language would you like to use?' 'jade' 'ejs' 'handlebars'
  AUTO_TEMPLATE_LANGUAGE="$LAST_ANSWER"
fi

case "$AUTO_TEMPLATE_LANGUAGE" in
  jade)
    state info 'Installing Jade module.'
    npm install jade
    check $? 'install' 'installed' 'Jade module'

    COMMANDS_SKELETON_EXT='jade'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What CSS preprocessor would you like to use?' 'sass' 'scss' 'less'
  AUTO_CSS_PREPROCESSOR="$LAST_ANSWER"
fi

case "$AUTO_CSS_PREPROCESSOR" in
  sass)
    COMMANDS_SKIN_EXT='sass'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What front-end framework would you like to use?' 'ampersand' 'backbone' 'angular' 'ember'
  AUTO_FRONT_END_FRAMEWORK="$LAST_ANSWER"
fi

case "$AUTO_FRONT_END_FRAMEWORK" in
  ampersand)
    state info 'Installing Ampersand framework modules.'
    npm install ampersand-collection ampersand-model ampersand-view ampersand-router
    check $? 'install' 'installed' 'Ampersand framework modules'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What database would you like to use?' 'postgresql' 'mongodb' 'mysql' 'sqlite3'
  AUTO_DATABASE="$LAST_ANSWER"
fi

case "$AUTO_DATABASE" in
  postgresql)
    state info 'Installing PostgreSQL module.'
    npm install pg
    check $? 'install' 'installed' 'PostgreSQL module'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What caching database would you like to use?' 'redis' 'memcached' 'cassandra' 'couchdb'
  AUTO_CACHE_DATABASE="$LAST_ANSWER"
fi

case "$AUTO_CACHE_DATABASE" in
  redis)
    state info 'Installing Redis and hiredis modules.'
    npm install redis hiredis
    check $? 'install' 'installed' 'Redis and hiredis modules'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What object relational mapping (ORM) would you like to use?' 'bookshelf' 'sequalize' 'mongoose'
  AUTO_ORM="$LAST_ANSWER"
fi

case "$AUTO_ORM" in
  bookshelf)
    state info 'Installing bookshelf module and knex dependancy.'
    npm install knex bookshelf
    check $? 'install' 'installed' 'bookshelf and knex modules'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What build tool would you like to use?' 'gulp' 'grunt' 'bower'
  AUTO_BUILD_TOOL="$LAST_ANSWER"
fi

case "$AUTO_BUILD_TOOL" in
  gulp)
    state info 'Installing gulp module and plugins.'
    npm install gulp gulp-watch gulp-shell gulp-util gulp-plumber vinyl-source-stream
    check $? 'install' 'installed' 'gulp module and plugins'

    COMMANDS_BUILDER='gulp'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What daemonizer would you like to use?' 'pm2' 'forever' 'nodemon'
  AUTO_DAEMONIZER="$LAST_ANSWER"
fi

case "$AUTO_DAEMONIZER" in
  pm2)
    COMMANDS_DAEMONIZER='pm2'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What back-end framework would you like to use?' 'express' 'hapi' 'connect'
  AUTO_BACK_END_FRAMEWORK="$LAST_ANSWER"
fi

case "$AUTO_BACK_END_FRAMEWORK" in
  express)
    state info 'Installing express framework module and plugins.'
    npm install express express-session connect-flash cookie-parser body-parser
    check $? 'install' 'installed' 'express framework module and plugins'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What websocket engine would you like to use?' 'socket.io' 'sockjs'
  AUTO_WEBSOCKET_ENGINE="$LAST_ANSWER"
fi

case "$AUTO_WEBSOCKET_ENGINE" in
  socket.io)
    state info 'Installing socket.io module and plugins.'
    npm install socket.io socket.io-redis
    check $? 'install' 'installed' 'socket.io module and plugins'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What JavaScript library would you like to use?' 'jquery' 'zepto'
  AUTO_LIBRARY="$LAST_ANSWER"
fi

case "$AUTO_LIBRARY" in
  jquery)
    state info 'Installing jquery module.'
    npm install jquery
    check $? 'install' 'installed' 'jQuery module'
  ;;
  zepto)
    state info 'Installing browserify-zepto module.'
    npm install browserify-zepto
    check $? 'install' 'installed' 'browserify-zepto'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What animation library would you like to use?' 'gsap' 'jqueryui'
  AUTO_ANIMATION_ENGINE="$LAST_ANSWER"
fi

case "$AUTO_ANIMATION_ENGINE" in
  gsap)
    state info 'Installing GSAP module.'
    npm install gsap
    check $? 'install' 'installed' 'GSAP module'
  ;;
  jqueryui)
    state info 'Installing jQuery-UI module.'
    npm install jquery-ui
    check $? 'install' 'installed' 'jQuery-UI module'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What bundler would you like to use?' 'browserify'
  AUTO_BUNDLER="$LAST_ANSWER"
fi

case "$AUTO_BUNDLER" in
  browserify)
    state info 'Installing browserify module.'
    npm install browserify
    check $? 'install' 'installed' 'browserify'

    COMMANDS_BUNDLER='browserify'
  ;;
esac

if [ $auto -eq 0 ]; then
  askOptions 'What CSS framework would you like to use?' 'foundation' 'bootstrap'
  AUTO_CSS_FRAMEWORK="$LAST_ANSWER"
fi

case "$AUTO_CSS_FRAMEWORK" in
  foundation)
    state info 'Installing Foundation 5.4.5 Essentials.'
    cd $origin/gonads/chromosomes
    if [ -d 'Foundation' ]; then
      state info 'Foundation directory already exists.'
      state info 'Deleting to grab latest Foundation.'
      rm -r -f Foundation
      check $? 'delete' 'deleted' 'Foundation'
    fi

    state info 'Creating folder gonads/chromosomes/Foundation.'
    mkdir 'Foundation'
    check $? 'create' 'created' 'folder gonads/chromosomes/Foundation'

    cd Foundation
    state info 'Downloading Foundation 5.4.5 Essentials.'
    wget http://foundation.zurb.com/cdn/releases/foundation-essentials-5.4.5.zip
    check $? 'download' 'downloaded' 'Foundation 5.4.5 Essentials'

    state info 'Unzipping foundation-essentials-5.4.5.zip'
    unzip foundation-essentials-5.4.5.zip
    check $? 'unzip' 'unzipped' 'foundation-essentials-5.4.5.zip'

    cd css
    state info 'Copying foundation.min.css to skin/dermis.'
    cp foundation.min.css $origin/skin/dermis
    check $? 'copy' 'copied' 'foundation.min.css'

    state info 'Copying normalize.css to skin/dermis.'
    cp normalize.css $origin/skin/dermis
    check $? 'copy' 'copied' 'normalize.css'
  ;;
esac
cd $origin

if ( [ $auto -eq 1 ] && [ $AUTO_PASSPORT -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Use passport.js for authentication?' ); then
  state info 'Installing passport module and plugins.'
  npm install passport passport-local bcrypt-nodejs
  check $? 'install' 'installed' 'passport module and plugins'

  AUTO_PASSPORT=1  
else
  AUTO_PASSPORT=0
fi

if ( [ $auto -eq 1 ] && [ $AUTO_STICKY_SESSION -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Use sticky sessions?' ); then
  state info 'Installing sticky-session module.'
  npm install sticky-session
  check $? 'install' 'installed' 'sticky-session'

  AUTO_STICKY_SESSION=1  
else
  AUTO_STICKY_SESSION=0
fi

if ( [ $auto -eq 1 ] && [ $AUTO_COLORS -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Use colors logging module?' ); then
  state info 'Installing colors module.'
  npm install colors
  check $? 'install' 'installed' 'colors'

  AUTO_COLORS=1  
else
  AUTO_COLORS=0
fi


if ( [ $auto -eq 1 ] && [ $AUTO_BOILERPLATE -eq 1 ] ) || ( [ $auto -eq 0 ] && ask 'Create boilerplate code?' ); then
  cd $SCRIPT_BIN_DIR

  state info 'Copying brain/stem.js boilerplate.'
  cp brain/stem.js $origin/brain
  check $? 'copy' 'copied' 'brain/stem.js boilerplate'

  state info 'Copying brain/cerebellum.js boilerplate.'
  cp brain/cerebellum.js $origin/brain 
  check $? 'copy' 'copied' 'brain/cerebellum.js boilerplate'

  state info 'Copying muscle/skeletal.js boilerplate.'
  cp muscle/skeletal.js $origin/muscle 
  check $? 'copy' 'copied' 'brain/skeletal.js boilerplate'

  state info 'Copying skeleton/spine.jade boilerplate.'
  cp skeleton/spine.jade $origin/skeleton 
  check $? 'copy' 'copied' 'skeleton/spine.jade boilerplate'

  state info 'Copying skin/epidermis.sass boilerplate.'
  cp skin/epidermis.sass $origin/skin 
  check $? 'copy' 'copied' 'skin/epidermis.sass boilerplate'

  state info 'Copying gonads/hox-genes/brain.hox boilerplate.'
  cp gonads/hox-genes/brain.hox $origin/gonads/hox-genes 
  check $? 'copy' 'copied' 'gonads/hox-genes/brain.hox boilerplate'

  state info 'Copying gonads/hox-genes/express.hox boilerplate.'
  cp gonads/hox-genes/express.hox $origin/gonads/hox-genes 
  check $? 'copy' 'copied' 'gonads/hox-genes/express.hox boilerplate'

  state info 'Copying gonads/hox-genes/knex.hox boilerplate.'
  cp gonads/hox-genes/knex.hox $origin/gonads/hox-genes 
  check $? 'copy' 'copied' 'gonads/hox-genes/knex.hox boilerplate'

  state info 'Copying gonads/hox-genes/passport.hox boilerplate.'
  cp gonads/hox-genes/passport.hox $origin/gonads/hox-genes 
  check $? 'copy' 'copied' 'gonads/hox-genes/passport.hox boilerplate'

  state info 'Copying gonads/hox-genes/socketio.hox boilerplate.'
  cp gonads/hox-genes/socketio.hox $origin/gonads/hox-genes 
  check $? 'copy' 'copied' 'gonads/hox-genes/socketio.hox boilerplate'

  state info 'Copying gonads/hox-genes/gulp.hox boilerplate.'
  cp gonads/hox-genes/gulp.hox $origin/gonads/hox-genes 
  check $? 'copy' 'copied' 'gonads/hox-genes/gulp.hox boilerplate'

  cd $origin
  state info 'Linking gulp.hox to gulpfile.js.'
  ln -s gonads/hox-genes/gulp.hox gulpfile.js
  check $? 'link' 'linked' 'gulp.hox to gulpfile.js'

  AUTO_BOILERPLATE=1
else
  AUTO_BOILERPLATE=0
fi

cd $origin/gonads/hox-genes
state info 'Creating new commands.hox.'

if [ -f commands.hox ]; then
  state info 'Preserving previous commands.hox as commands.orig.hox'
  mv -i commands.hox commands.orig.hox
  check $? 'preserve' 'preserved' 'previous commands.hox as commands.orig.hox'
fi

state info 'Saving new commands.hox.'
{
  commandsHoxAppend '#!/bin/sh'
  commandsHoxAppend
  commandsHoxAppend '# This is a config for the command line interface generated from a previous installation.'
  commandsHoxAppend
  commandsHoxAppend "COMMANDS_EDITOR='$COMMANDS_EDITOR'         # Text Editor"
  commandsHoxAppend "COMMANDS_BUILDER='$COMMANDS_BUILDER'       # Build Tool"
  commandsHoxAppend "COMMANDS_DAEMONIZER='$COMMANDS_DAEMONIZER'     # Daemonizer"
  commandsHoxAppend "COMMANDS_BUNDLER='$COMMANDS_BUNDLER'       # Bundler"
  commandsHoxAppend
  commandsHoxAppend "COMMANDS_SKELETON_EXT='$COMMANDS_SKELETON_EXT'   # Template Language"
  commandsHoxAppend "COMMANDS_SKIN_EXT='$COMMANDS_SKIN_EXT'       # CSS Preprocessor"
  commandsHoxAppend "COMMANDS_MUSCLE_EXT='$COMMANDS_MUSCLE_EXT'     # Client-side Language"
  commandsHoxAppend "COMMANDS_BRAIN_EXT='$COMMANDS_BRAIN_EXT'     # Server-side Language"
}
check $? 'save' 'saved' 'new commands.hox.'

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
  state info "Folders:            $(binaryWord $AUTO_FOLDERS)"
  state info "Text Editor:          $(greenify $AUTO_EDITOR)"
  state info "JavaScript Preprocessor:    $(greenify $AUTO_JAVASCRIPT_PREPROCESSOR)"
  state info "Templating Language:      $(greenify $AUTO_TEMPLATE_LANGUAGE)"
  state info "CSS Preprocessor:         $(greenify $AUTO_CSS_PREPROCESSOR)"
  state info "Front-end Framework:      $(greenify $AUTO_FRONT_END_FRAMEWORK)"
  state info "Database:             $(greenify $AUTO_DATABASE)"
  state info "Cache Database:         $(greenify $AUTO_CACHE_DATABASE)"
  state info "ORM:              $(greenify $AUTO_ORM)"
  state info "Build Tool:           $(greenify $AUTO_BUILD_TOOL)"
  state info "Daemonizer:           $(greenify $AUTO_DAEMONIZER)"
  state info "Back-end Framework:       $(greenify $AUTO_BACK_END_FRAMEWORK)"
  state info "Websocket Engine:         $(greenify $AUTO_WEBSOCKET_ENGINE)"
  state info "Animation Engine:         $(greenify $AUTO_ANIMATION_ENGINE)"
  state info "Bundler:            $(greenify $AUTO_BUNDLER)"
  state info "CSS Framework:          $(greenify $AUTO_CSS_FRAMEWORK)"
  state info "Passport.js:          $(binaryWord $AUTO_PASSPORT)"
  state info "Sticky Sessions:        $(binaryWord $AUTO_STICKY_SESSION)"
  state info "Boilerplate:          $(binaryWord $AUTO_BOILERPLATE)"
  state info "Colors:             $(binaryWord $AUTO_COLORS)"
  echo
  if ask 'Would you like to save this configuration as generator.hox?'; then
    cd $origin/gonads/hox-genes

    if [ $gonads -eq 1 ]; then
      state info 'Preserving previous configuration as generator.orig.hox'
      mv -i generator.hox generator.orig.hox
      check $? 'preserve' 'preserved' 'original configuration as generator.orig.hox'
    fi

    state info 'Saving current configuration as generator.hox'
    {
      autoHoxAppend '#!/bin/sh'
      autoHoxAppend
      autoHoxAppend '# This is a config for an automated installation generated from a previous manual installation.'
      autoHoxAppend
      autoHoxAppend "AUTO_FOLDERS=$AUTO_FOLDERS # Scaffold out a basic anatomy app."
      autoHoxAppend "AUTO_EDITOR=$AUTO_EDITOR # Set text editor."
      autoHoxAppend "AUTO_JAVASCRIPT_PREPROCESSOR=$AUTO_JAVASCRIPT_PREPROCESSOR # Set a JavaScript preprocessor."
      autoHoxAppend "AUTO_TEMPLATE_LANGUAGE=$AUTO_TEMPLATE_LANGUAGE # Set a templating language."
      autoHoxAppend "AUTO_CSS_PREPROCESSOR=$AUTO_CSS_PREPROCESSOR # Set a CSS preprocessor."
      autoHoxAppend "AUTO_FRONT_END_FRAMEWORK=$AUTO_FRONT_END_FRAMEWORK # Set a front-end framework."
      autoHoxAppend "AUTO_DATABASE=$AUTO_DATABASE # Set a database."
      autoHoxAppend "AUTO_CACHE_DATABASE=$AUTO_CACHE # Set a caching database."
      autoHoxAppend "AUTO_ORM=$AUTO_ORM # Set an ORM."
      autoHoxAppend "AUTO_BUILD_TOOL=$AUTO_BUILD_TOOL # Set a build tool."
      autoHoxAppend "AUTO_DAEMONIZER=$AUTO_DAEMONIZER # Set a daemonizer."
      autoHoxAppend "AUTO_BACK_END_FRAMEWORK=$AUTO_BACK_END_FRAMEWORK # Set a back-end framework."
      autoHoxAppend "AUTO_WEBSOCKET_ENGINE=$AUTO_WEBSOCKET_ENGINE # Set a websocket engine."
      autoHoxAppend "AUTO_ANIMATION_ENGINE=$AUTO_ANIMATION_ENGINE # Set an animation engine."
      autoHoxAppend "AUTO_BUNDLER=$AUTO_BUNDLER # Set an animation engine."
      autoHoxAppend "AUTO_CSS_FRAMEWORK=$AUTO_CSS_FRAMEWORK # Set a CSS framework."
      autoHoxAppend "AUTO_PASSPORT=$AUTO_PASSPORT # Use Passport.js for authentication."
      autoHoxAppend "AUTO_STICKY_SESSION=$AUTO_STICKY_SESSION # Use sticky sessions."
      autoHoxAppend "AUTO_BOILERPLATE=$AUTO_BOILERPLATE # Copy boilerplate code."
      autoHoxAppend "AUTO_COLORS=$AUTO_COLORS # Use colors logging module."
    }
    check $? 'save' 'saved' 'current configration as generator.hox'
  else
    echo
  fi

  cd $origin
fi

state info 'Installation complete! Enjoy your newly setup server!'
