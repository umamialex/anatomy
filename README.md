Anatomy
=======

Do you like starting from an empty OS install and turning it into a full-fledge Node.js server, but don't want to type out all the commands and write pages of boilerplate? Or are you just starting out with Node.js (maybe even Linux) and have no clue where to begin?

**Anatomy is for you.**

## Installation and Basic Usage
To install Anatomy, simply run:
```
sudo yum -y install git 
git clone https://github.com/suitupalex/anatomy --branch <your operating system>
```
**Note:** *The Anatomy server installation is currently only available for RHEL (i.e. Red Hat, CentOS, and Fedora). If you use a different flavor of Linux, why don't you fork the project and contribute!*

To run through the default server setup, just do:
```
cd anatomy
sh reproduce.sh
```

## What does Anatomy do?
### Simple Server Installation
#### Automated Install
Anatomy is a simple installation tool that takes an empty CentOS server and will automatically install all the tools you need to have a bare bones Node.js server going. The install is fully customizable and can help you quickly spin up multiple production web apps, quickly on-board team members, or even just give you a clean workspace to test projects.

With every command in the installation process, Anatomy will check for any errors and will ask for verification before continuing to the next step.

#### Step-by-step Install
You can also choose to manually verify each step if you'd like to keep tabs on what's happening under the hood. Newcomers to Linux and Node.js can use this method as learning tool for properly configuring their servers.

### Application Framework
Anatomy also has a very opinionated yet open-ended framework for Node.js projects. There are two main goals for the Anatomy framework.
#### Minimize boilerplate but keeping it basic.
Node.js projects generally require quite a bit of boilerplate to get a basic web application going. Anatomy.io takes care of the tedious base code and package installations for you so you can get into the fun stuff.

But you're probably wondering why not just use something like [Meteor.js](http://meteor.com)? Meteor.js is a fantastic solution, but we found it to be too high level to do anything extremely complicated. On top of that, we found that people who started their Node.js experience on Meteor.js did not know how to use vanilla Node.js. Meteor.js does a fine job of adding an abstraction layer, but there is just way too much stuff inbetween the programmer and Node.js.

Anatomy does offer a very opinionated view on what technologies to use with a typical Node.js web app. But all the code is out in the open and is implemented as its most basic form. We give you the option to remove and add anything you wish. In fact, if all you want to do is quickly setup a server, *you don't have to use our framework at all.*
#### Provide a new metaphor for structuring web apps.
Anatomy also provides a strong opinion about structuring your web apps. Every good application programmer knows about the Model-View-Controller (MVC) paradigm. But it can take a few blog posts, a YouTube lecture or two, and then hours of trial-and-error to figure out what the actually concept is trying to achieve.

On top of that, when programmers create their directory hierarchy, they use boring, nondescript terms like **views**, **lib**, **models**, **public**, and **static**. They call their files more vague things like **app.js**, **index.html**, **stylesheet.css**, **utils.js**.

We can be more creative than that and come up with something more descriptive and more relatable. Maybe come up with something even non-programmers can understand. Why not use something we all know and love as a metaphor, **the human body.**

## Configuration
## Structure
### reproduce.sh

### gonads/
#### gametes/
#### chromosomes/
#### hox-genes/
#####anatomy.hox
#####apf.hox
#####preroute.hox
#####vim.hox
#####bashrc.hox
### skeleton/
#### spine.jade
### muscle/
#### skeletal.js
#### visceral/
### skin/
#### epidermis.sass
#### dermis/
### voice/
### brain/
#### cerebellum.js
