#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""GetLatestBinary

This starts the check and search for the latest java binaries for Tango

How is this performed?
There are three known sources for TANGO binaries
- bintray.com
- github.com
- general websites

To access the various sources and to download the binaries directly,
this script has been written.
It contains
- base Library class
- BintrayLib class whicch 
- 
"""

import requests
from xml.dom import minidom
import os
import sys
import zipfile
import json


# Constants
LIBFOLDER = '../libs/'
ERROR_VERSION_TEXT = "Couldn't find latest version"
ERROR_DOWNLOAD_TEXT = "Couldn't download"
ERROR_PROCESS_TEXT = "Couldn't process downloaded file"


########### Classes ############


###
# Class Library
###
class Library:
    """General with
    - __init__ generator
    - __string__ for presenting
    - version property (abstract)
    - downloadURL (abstract)
    - isValid() 
    """
    debug = False
    
    def __init__(self, tool, parameters):
        self._tool = tool
        self._url = parameters['url']
        self._version = ""
        self._downloadURL = ""
        
    def __str__(self):
        """String representation overload, for example when using print()"""
        return self._tool+", "+"version: "+self._version
        
    @property
    def tool(self):
        """Returns tool name"""
        return self._tool
    
    @property    
    def version(self):
        """Returns the version of the tool"""
        pass
        
    @property    
    def downloadURL(self):
        """Returns the download URL"""
        pass
        
    @property
    def filename(self):
        """Name of the jar file in the libs folder"""
        return self.tool+"-"+self.version+".jar"
        
    @property
    def symlinkname(self):
        """Name of the general symlink (to the jar file) without version numbers"""
        return self.tool+".jar"
        
    def download(self):
        """Downloads a file from given URL
        Thanks to https://stackoverflow.com/a/34863581"""
        if self._checkURL(self.downloadURL):
            with open(os.path.join(LIBFOLDER,self.filename), "wb") as jarfile:
                jarfile.write(self._getFileContent(self.downloadURL))
        else:
            print(self._tool,ERROR_DOWNLOAD_TEXT,self.downloadURL)    
        
            
    def createSymlink(self):
        """Create a symlink to the jar file"""
        try:
            os.remove(os.path.join(LIBFOLDER,self.symlinkname))
        except FileNotFoundError:
            pass
        # Symlink in lib folder
        os.symlink(self.filename,os.path.join(LIBFOLDER,self.symlinkname))
        
    def isValid(self):
        """Determines, whethter this item is valid to download"""
        if self.version == "" or self.downloadURL == "" \
            or self.version == ERROR_VERSION_TEXT:
            return False
            
        return True;
        
    
    # "Private" functions    
    def _checkURL(self,url=""):
        """Check if URL exists"""
        if url == "":
            url = self._url
            
        try:
            status = requests.head(url).status_code
        except ConnectionError:
            print("Connection error to",url)
            return False
        
        # corresponds to HTTP 200 and 302
        if status in [requests.codes.ok, requests.codes.found]:
            return True
        else:
            print("Access error, status",status,"url",url)
            return False
            
    def _getFileContent(self,url):
        return requests.get(url).content
            
    def _getFileText(self,url):
        return requests.get(url).text
        
    def _debugPrint(self, *text):
        if self.debug:
            print(" ".join(text))

###
# Class BintrayLib
###
class BintrayLib(Library):
    """Binaries from Bintray.com"""
    
    def __init__(self, tool, parameters):
        self._mavenFile = 'maven-metadata.xml'
        super().__init__(tool,parameters)
        
    @property    
    def version(self):
        """Returns the version of the tool"""
        if self._version == "":
            try:
                self._debugPrint("    Request",self._mavenFile )
                xmltext = self._getFileText(self._url+self._mavenFile)
                self._version = str(minidom.parseString(xmltext).getElementsByTagName('latest')[0].firstChild.nodeValue)
            except:
                self._version = ERROR_VERSION_TEXT
        
        return self._version
        
    @property    
    def downloadURL(self):
        """Returns the download URL"""
        if self._downloadURL == "":
            self._downloadURL = self._url+self.version+"/"+self._tool+"-"+self.version+".jar"
            
        return self._downloadURL
        
        
###
# Class GithubLib
###

class GithubLib(Library):
    def __init__(self, tool, parameters):
        super().__init__(tool,parameters)
        # Store request, therefore class attribute
        self._request = None
        self._getGithubInfos()
        
        
    @property    
    def version(self):
        """Returns the version of the tool"""
        if self._version == "" and self._request != None:
            self._version = self._request.json()['tag_name']
        
        return self._version
        
    @property    
    def downloadURL(self):
        """Returns the download URL"""
        if self._downloadURL == "" and self._request != None:
            self._downloadURL = self._request.json()['assets'][0]['browser_download_url']
            
        return self._downloadURL
        
    def _getGithubInfos(self):
        if self._checkURL():
            self._debugPrint("    Request infos from github")
            self._request = requests.get(self._url)


###
# Class GeneralLib
###            
class GeneralLib(Library):
    def __init__(self, tool, parameters):
        self._tool = tool
        self._version = parameters['version']
        self._downloadURL = parameters['url']
        self._parameters = parameters
        
    @property    
    def version(self):
        """Returns the version of the tool"""
        return self._version
        
    @property    
    def downloadURL(self):
        """Returns the download URL"""
        return self._downloadURL
        
    def download(self):
        """Overwrite standard download procedure"""
        key = 'postAction'
        if key in self._parameters.keys() and self._parameters[key]:
            # Post action required
            self._download()
        else:
            # Normal behaviour
            super().download()
          
    def _download(self):
        """ Download file (usually a archive) and make post actions if defined"""
        
        if self._checkURL(self.downloadURL):
            # Download
            fname = self._parameters['url'].split('/')[-1]
            fpath = os.path.join(LIBFOLDER,fname)
            with open(fpath, "wb") as f:
                f.write(self._getFileContent(self.downloadURL))
                
            #Action
            key = 'postParameters'
            fnKey = 'function'
            ptKey = 'path'
            
            #Check postParameters
            if key in self._parameters.keys() and \
                fnKey in self._parameters[key].keys() and \
                ptKey in self._parameters[key].keys():
                
                fn = self._parameters[key][fnKey]
                path = self._parameters[key][ptKey]
                #Unzip action
                if fn == 'unzip' and path != "":
                    #Processing
                    self._debugPrint("      extract and move")
                    exf = zipfile.ZipFile(fpath).extract(member=path,path=LIBFOLDER)
                    
                    os.rename(exf,os.path.join(LIBFOLDER,self.filename))
                    
                    
                    # Clean up
                    self._debugPrint("      clean up")
                    os.rmdir(exf.rsplit('/',maxsplit=1)[0])
                    os.remove(fpath)
                else:
                    #No post parameters
                    print(self._tool,ERROR_PROCESS_TEXT,downloadFile)
                
            else:
                print(self._tool,ERROR_PROCESS_TEXT,downloadFile)
        else:
            print(self._tool,ERROR_DOWNLOAD_TEXT,self.downloadURL)
          


######################################

### Main Programm
def start(debug=False):
    """Main programm to check and start binaries"""
    if debug:
        Library.debug = debug
    print("Check binaries...")

    sources = {}
    with open('sources.json', 'r') as fsource:
        sources = json.loads(fsource.read())
    
    pages = []
    pages.append([BintrayLib(tool,parameters) for tool,parameters in sources['bintray'].items()])
    pages.append([GithubLib(tool,parameters) for tool,parameters in sources['github'].items()])
    pages.append([GeneralLib(tool,parameters) for tool,parameters in sources['general'].items()])

    print("Downloading...")    
    
    for page in pages:
        process(page)
    
    print("...done")

### Helpers
def process(page):
    """Downloads the Items from the various sites"""
    for tool in page:
        if tool.isValid():
            print("...Downloading",tool)   
            tool.download()
            tool.createSymlink()
        else:
            print("Cannot download",tool)
    
def isOption(arguments, *options):
    """ Checks whether at least one of the options is in arguments"""
    return not set(arguments).isdisjoint(options)
    
def printHelp():
    print(
        "This is the library updater, which takes the binaries " \
        "from the various webpages \n" \
        "Usage \n" \
        "-d|--debug \t Debug option \n" \
        "--noprompt \t Don't ask questions\n" \
        "-h|--help \t This help"
    )



######## Shell script ############

if __name__ == "__main__":
    
    debug = False;
    
    ## Check options
    if isOption(sys.argv, '-d','--debug'):
            debug = True;
            
    if isOption(sys.argv, '-h','--help'):
        printHelp() 
    elif isOption(sys.argv, '--noprompt'):
        start(debug)
    else:
        answer = input("You really want to update the libs from the web? [Y/n]")
        
        if answer in ["y","Y",""]:
            start(debug)
        else:
            print("Quit")
