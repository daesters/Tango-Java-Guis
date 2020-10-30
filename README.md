# REAMDE

This repo contains the most important TANGO Tools based on java.
Furhtermore, it allows you to update to the newest version of the java binaries


## Usage

Start the TANGO Guis in your shell, for example

    ./jive
  
 In Windows, start *jive.bat*
 
 You need to have set the *TANGO_HOST*, see below

#### Set TANGO_HOST
* Export the TANGO-Host Variable in your shell with the following commmand:
  export TANGO_HOST=<yourtangohost>:10000
  
  If you have the TANGO locally installed, use *localhost* instead of *<yourtangohost>*.
 
  
  To have it exported persistently write the command in your .bashrc file 
  (home/<username\>/.bashrc) or in /etc/tangorc
  
  Or add the environment variable to the file /etc/environment
  (note: you need superuser priviledges).
  Add the line `TANGO_HOST=<yourtangohost>:10000`
  
#### Symlinks (Linux) or copy files
The libraries in the libs folder contain the version number.
In order to avoid to change the scripts every time an update has been performed, we use symlinks (linux) or copy the library files (Windows) in the libs order. These symlinks/copies don't contain the version number.

If you have updated the repo or just clone, you need to performe the creation of symlinks /copies.

1. Go to the folder scripts
2. Execute CreateSymlinks.sh (linux) or CreateCopies.bat (Windows)


## Update binaires

Just execute GetLatestBinaries.py. It will download the latest binaries from bintray and github

#### Where are the java binaries from

Get latest details from doc,   [https://tango-controls.readthedocs.io/en/latest/installation/binary_package.html](https://tango-controls.readthedocs.io/en/latest/installation/binary_package.html)
  
  * Most of the tools are from bintray, see [doc](https://tango-controls.readthedocs.io/en/latest/installation/binary_package.html) 
  * JTango is from [github](https://github.com/tango-controls/JTango/releases/tag/9.5.18)
  * TangORB is from sourceforge, version 8.3.5 is available here: [https://sourceforge.net/projects/tango-cs/files/tools/TangORB-8.3.5_jeromq_android.jar/download](https://sourceforge.net/projects/tango-cs/files/tools/TangORB-8.3.5_jeromq_android.jar/download])
  * log4j is an apache thing, can be downloaded [http://archive.apache.org/dist/logging/log4j/](http://archive.apache.org/dist/logging/log4j/). Important, we use log4j version 1. Version 2 seems to be incompatible
