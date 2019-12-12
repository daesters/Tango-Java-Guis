#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""GetLatestBinary

This starts the check and search for the latest java binaries for Tango
"""

import requests
from xml.dom import minidom
import os


# Check new versions on https://bintray.com/tango-controls
# In the maven-medata.xml, we find the newest version.
# This is also the name of the folder, where we get the binaries.
BintrayPaths = {
    'Astor': 'https://dl.bintray.com/tango-controls/maven/org/tango/gui/Astor/',
    'ATKCore': 'https://dl.bintray.com/tango-controls/maven/org/tango/atk/ATKCore/',
    'ATKPanel': 'https://dl.bintray.com/tango-controls/maven/org/tango/gui/ATKPanel/',
    'ATKTuning': 'https://dl.bintray.com/tango-controls/maven/org/tango/atk/ATKTuning/',
    'ATKWidget': 'https://dl.bintray.com/tango-controls/maven/org/tango/atk/ATKWidget/',
    'DBBench': 'https://dl.bintray.com/tango-controls/maven/org/tango/DBBench/',
    'Jive': 'https://dl.bintray.com/tango-controls/maven/org/tango/Jive/',
    'JSSHTerminal': 'https://dl.bintray.com/tango-controls/maven/org/tango/JSSHTerminal/',
    #'JTangoServer': 'https://dl.bintray.com/tango-controls/jtango/org/tango-controls/JTangoServer/',
    'LogViewer': 'https://dl.bintray.com/tango-controls/maven/org/tango/gui/LogViewer/',
    'Pogo': 'https://dl.bintray.com/tango-controls/maven/org/tango/tools/pogo/gui/Pogo/'
}

# Check verion on github
# We need assets.0.browser_download_url
# Version is given by tag_name
GithubPaths = {
	'JTango': 'https://api.github.com/repos/tango-controls/JTango/releases/latest'
}

# Check versions on http://archive.apache.org/dist/logging/log4j/
ApachePath = {
	'log4j': 'http://archive.apache.org/dist/logging/log4j/1.2.17/log4j-1.2.17.tar.gz'
}



LIBFOLDER = './libs/'
ERROR_VERSION_TEXT = "Couldn't find latest version"
ERROR_DOWNLOAD_TEXT = "Couldn't download"


DEBUG = True

class DownloadItem:
    """General download item with
    - __init__ generator
    - __string for presentin__
    - version property (abstract)
    - downloadURL (abstract)
    - isValid() 
    - update()
    """
    
    def __init__(self, tool, url):
        self._tool = tool
        self._url = url
        self._version = ""
        self._downloadURL = ""
        
    def __str__(self):
        """String representation overload, for example when using print()"""
        return "   "+self._tool+", "+"version: "+self._version
        
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
                jarfile.write(self.getFileContent(self.downloadURL))
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
        
    def update(self):
        self.downloadURL
        self.version
    
    # "Private" functions    
    def _checkURL(self,url=""):
        """Check if URL exists"""
        if url == "":
            url = self._url
            
        try:
            status = requests.head(url).status_code
        except ConnectionError:
            print("Connection error")
            return False
        
        if status == 200 or status == 302 or status == 301:
            return True
        else:
            print("Access error of",url)
            return False
            
    def getFileContent(self,url):
        return requests.get(url).content
            
    def getFileText(self,url):
        return requests.get(url).text
        
    def debugPrint(self, text):
        if DEBUG:
            print(text)
        

class BintrayItem(DownloadItem):
    """Binaries from Bintray.com"""
    
    def __init__(self, tool, url):
        self._mavenFile = 'maven-metadata.xml'
        super().__init__(tool,url)
        
    @property    
    def version(self):
        """Returns the version of the tool"""
        if self._version == "":
            try:
                xmltext = self.getFileText(self._url+self._mavenFile)
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
        
        
        
class GithubItem(DownloadItem):
    def __init__(self, tool, url):
        super().__init__(tool,url)
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
            self.debugPrint("In github,infos")
            self._request = requests.get(self._url)
            self.debugPrint(self._request.json())
    
        
        
def start():
    
    print("Check binaries...")

    bintrayItems = [BintrayItem(tool,url) for tool,url in BintrayPaths.items()]
    githubItems = [GithubItem(tool,url) for tool,url in GithubPaths.items()]

    
    print("Downloading...")    

    #downloadItems(bintrayItems)
    
    downloadItems(githubItems)
    print("...done")
    
def downloadItems(siteItems):
    for tool in siteItems:
        if tool.isValid():
            print("...Downloading",tool)
            tool.download()
            tool.createSymlink()
        else:
            print("Cannot download",tool)
    

if __name__ == "__main__":
    start();
