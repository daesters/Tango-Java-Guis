# HOW-TO USE THE TANGO GUIs

The following procedure describes a way to see finally the 

## EXPORT
* Export the TANGO-Host Variable in your shell with the following commmand:
  export TANGO_HOST=172.25.65.1:10000
  To have it exported persistently write the command in your .bashrc file 
  (home/<username>/.bashrc)

## VPN

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

## GUI start
* Start local guiC8 programm in your shell with:
  ./guiC8

