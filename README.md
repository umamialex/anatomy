Anatomy CLI
=============

## Installation and Build
```bash
npm install -g anatomy
```

Create the Browserified bundle script and CSS:
```bash
anatomy build

# Anatomy-less variants:
## Using Docker
cd mission-control
fig run webdev gulp build

## Dockerless
cd mission-control
gulp build
```

If you want to watch and build, use:
```bash
anatomy watch

# Anatomy-less variant:
## Using Docker
fig run webdev gulp

## Dockerless
gulp
```

If you just want to watch without running a build, use:
```bash
anatomy watch only

# Anatomy-less variant:
## Using Docker
fig run webdev gulp watch

## Dockerless
gulp watch
```

> Tip: **anatomy** commands work everywhere inside the application folder. The **anatomy** tool automatically looks for root of the application then executes from there.

## Controlling the App
To start the app as a daemon, use:
```bash
anatomy start

# Anatomy-less variant:
## Using Docker
cd /path/to/mission-control
fig start webdev

## Dockerless
pm2 start /path/to/mission-control/brain/stem.js --name "mission-control"
```
To start the app inside the terminal, use:
```bash
anatomy start once

# Antomy-less variant:
## Using Docker
cd /path/to/mission-control
fig up webdev

## Dockerless
node /path/to/mission-control/brain/stem.js
```
To restart the daemon, use:
```bash
anatomy restart

# Anatomy-less variant:
## Using Docker (until Fig v1.0)
cd /path/to/mission-control
fig stop webdev; fig start webdev

## Dockerless
pm2 restart "mission-control"
```
To stop the daemon, use:
```bash
anatomy stop

# Anatomy-less variant:
## Using Docker
cd /path/to/mission-control
fig stop webdev

## Dockerless
pm2 stop "mission-control"
```
Stopping the daemon only freezes the process. The HTTP port will still report back as occupied.
To completely kill the process, use:
```bash
anatomy kill

# Anatomy-less variant:
## Using Docker
cd /path/to/mission-control
fig kill webdev

## Dockerless
pm2 delete "mission-control"
# Or to completely kill the entire pm2 process:
pm2 kill
```

## Logging
PM2 automatically logs any output to console.

To view these logs, use:
```bash
anatomy memory

# Anatomy-less variant
## Using Docker
cd /path/to/mission-control
fig logs webdev

## Dockerless
pm2 logs mission-control
```
To start the app as a daemon and immediately watch the logs, use:
```bash
anatomy start memory

# Anatomy-less variant
## Using Docker
cd /path/to/mission-control
fig start webdev; fig logs webdev

## Dockerless
pm2 start /path/to/mission-control/brain/stem.js --name "mission-control"; pm2 logs mission-control
```

# Editing and Navigating with Anatomy
If you choose to use Anatomy, you can take advantage of some shortcuts.  These shortcuts work no matter where your terminal is placed in the `mission-control folder` structure.  These commands can be customized in `commands.hox`.
```bash
# Special File Keywords
anatomy stem                # Edit brain/stem.js
anatomy cerebellum          # Edit brain/cerebellum.js
anatomy skeletal            # Edit muscle/skeletal.js
anatomy epidermis           # Edit skin/epidermis.sass

# Creating / Editing Files
# Note, do not use file extensions.
# E.g., "anatomy brain stem" NOT "anatomy brain stem.js"
anatomy brain <filename>    # Create/Edit file in brain
anatomy cerebrum <filename> # Create/Edit file in brain/cerebrum
anatomy muscle <filename>   # Create/Edit file in muscle
anatomy visceral <filename> # Create/Edit file in muscle/visceral
anatomy skin <filename>     # Create/Edit file in skin
anatomy dermis <filename>   # Create/Edit file in skin/dermis
anatomy hox <filename>      # Create/Edit file in gonads/hox

# Changing / Listing Directories
# You can use any of the keyword folder names.
cd $(anatomy brain)         # cd to root/brain
ls $(anatomy brain)         # ls root/brain

# There is also a special keyword for the root directory.
cd $(anatomy root)
```

## Folder and File Structure
### skeleton/
*The skeleton provides structure for the body.* HTML gives a data structure for the client-side of a web app. Specifically, we will be using Jade for its ease-of-use, readability, and resemblance to SASS.
#### plugins/
*Plugins are* `mission-control` *specific directories*. It includes the client-side templates for the customer-facing plugin.
#### spine.jade
*The spine provides the core structure for the human body.* `spine.jade` includes all the templates that we will need for the web app, as well as the basic document metadata. It will possibly have includes from other Jade files as the app becomes more complicated.
### skin/
*Skin is the outermost layer of the human body which gives us our aesthetic.* Any CSS, images, fonts, etc. for the web app are placed in this folder.
#### dermis/
*The dermis is the penultimate layer of skin, right under the dermis.* `dermis/` contains any outputted CSS from either SASS files, or CSS frameworks, such as Foundation or jQuery-UI.
##### plugins/
*Plugins are* `mission-control` *specific directories*. It includes the client-side CSS for the customer-facing plugin.
#### epidermis.sass
*The epidermis is the top most layer of skin.* `epidermis.sass` includes any custom styling for the web app. It will possibly have indlues from other SASS files as the app becomes more complicated.
### muscle/
*Muscles are responsible for moving the skeleton and subsequently the skin.* `muscle/` contains any client-side JavaScript.
#### visceral/
*Visceral muscles are muscles of the organs.* `visceral/` contains any kind of module that provides logic or modeling for the client-side.
##### plugins/
*Plugins are* `mission-control` *specific directories.* It includes the client-side JavaScript for the customer-facing plugin.
#### skeletal.js
*Skeletal muscles are the muscles that directly manipulate the skeleton.* 
#### skeletal.bundle.js
This is the output file once `browserify` has concatenated all the client-side scripts. It is the main entry point for the client-side JavaScript.
### brain/
*The brain ultimately controls and processes feedback from the entire body.* In a web app, this is the function of server-side code.
#### cerebrum/
*The cerebrum is the white-matter and bulk of the brain.* `cerebrum` contains any kind of module that provides logic or modeling for the server.
#### stem.js
*The brain stem is responsible for essential functions, such as breathing, heart rate, sleeping, and eating.* The brain stem is the entry point for the web app's server side. The stem should handle loading modules and configurations for any server side code, as well as clustering child processes.
#### cerebellum.js
*The cerebellum provides fine motor control.* The cerebellum provides the fine utilities to be used within the web app. This includes logging, simple methods such as number-to-leading-zeros-string. Since the cerebellum is important for proper muscle functioning, utilities here can be shared with the client-side code.
### voice/
*The voice provides audible communication for the body.* This is where any kind of audio assets are placed.
### gonads/
*The gonads are the reproductive organs of the body.*
#### chromosomes/
*Chromosomes contain strings of DNA.*
#### hox-genes/
*Hox-genes determine the placement of different appendages of the body.*
### gulpfile.js
Links to `gonads/hox-genes/gulp.js`.
### package.json
