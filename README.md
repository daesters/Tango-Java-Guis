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
  export TANGO_HOST=orkan.mott.loc:10000
  
  If you have the TANGO locally installed, use *localhost* instead of *orkan.mott.loc*.
  
  To access *orkan.mott.loc*, you need access to the green network (see below)
  
  To have it exported persistently write the command in your .bashrc file 
  (home/<username\>/.bashrc) or in /etc/tangorc

#### Access the green network

If you have the TANGO_HOST 

  - Start VPN Connection to Orkan
		(the following details are just written in case of loosing the settings,
		the are usually already implemented)
  - DNS server is 172.25.65.1
  - Gateway is 192.33.96.34
  - Authentication Type: Certificates (TLS)
  - Ask system responsible (currently Yves) for User Certificate, CA Certificate
		and Private Key files
		* User Certificate: client1.crt
		* CA Certificate: ca.crt
		* Private Key: client1.key
		* No Private Key Password
  - Advanced options: Check options 'Use LZO data compression' and 
		'Use a TAP device'.

----

## Update binaires

Just execute GetLatestBinaries.py. It will download the latest binaries from bintray and github

Currently, TangORB cannot be installed this way.

#### Where are the java binaries from

Get latest details from doc,   [https://tango-controls.readthedocs.io/en/latest/installation/binary_package.html](https://tango-controls.readthedocs.io/en/latest/installation/binary_package.html)
  
  * Most of the tools are from bintray, see [doc](https://tango-controls.readthedocs.io/en/latest/installation/binary_package.html) 
  * JTango is from [github](https://github.com/tango-controls/JTango/releases/tag/9.5.18)
  * TangORB is from sourceforge, version 8.3.5 is available here: [https://sourceforge.net/projects/tango-cs/files/tools/TangORB-8.3.5_jeromq_android.jar/download](https://sourceforge.net/projects/tango-cs/files/tools/TangORB-8.3.5_jeromq_android.jar/download])
  * log4j is an apache thing, can be downloaded [http://archive.apache.org/dist/logging/log4j/](http://archive.apache.org/dist/logging/log4j/). Important, we use log4j version 1. Version 2 seems to be incompatible
