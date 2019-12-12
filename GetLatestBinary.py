#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""GetLatestBinary

This starts the check and search for the latest java binaries for Tango
"""

import requests
from xml.dom import minidom
import os


# Check new path on https://bintray.com/tango-controls

BinaryParentURL = {
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
    'Pogo': 'https://dl.bintray.com/tango-controls/maven/org/tango/tools/pogo/gui/Pogo/',
    #'MustFail': 'https://dl.bintray.com/Fails/',
}

mavenFile = 'maven-metadata.xml'

libfolder = './libs/'

JarDownload = {}


def start():
    print("Check binaries...")
    for tool,path in BinaryParentURL.items():
        #print(path)
        try:
            version = getVersion(getFileText(path+mavenFile))
        except:
            print("  ",tool+", "+"Couldn't find latest version in maven metafile")
            continue
            
        print("  ",tool+",","version:",version)
        url = getJarPath(path,tool,version)
        if URLexists(url):
            JarDownload[tool] = [version,getJarPath(path,tool,version)]
        else:
            print("  ",tool+": couldn't access "+url)
    
    print("Downloading...")    
    for tool,parts in JarDownload.items():
        version,url = parts
        print("  ",tool,version)
        removeDownloadSymlink(tool,version,url)
        
    print("...done")

def getVersion(xmltext):
    """Renders a XML file to get the latest version number of the binary"""
    return minidom.parseString(xmltext).getElementsByTagName('latest')[0].firstChild.nodeValue


def getFileText(url):
    return requests.get(url).text

def getFileContent(url):
    return requests.get(url).content

def getJarPath(parentpath,tool,version):
    return parentpath+version+"/"+tool+"-"+version+".jar"
    
def URLexists(url):
    try:
        status = requests.head(url).status_code
    except ConnectionError:
        return False
    
    if status == 200:
        return True
    else:
        return False
        
def genVersionFilename(tool, version,withLib=True):
    name = tool+"-"+version+".jar"
    if withLib:
        return os.path.join(libfolder,name)
    else:
        return name
    
def genFilename(tool,withLib=True):
    name = tool+".jar"
    if withLib:
        return os.path.join(libfolder,name)
    else:
        return name

def download(url,filename):
    """Downloads a file from given URL
    Thanks to https://stackoverflow.com/a/34863581"""
    
    with open(filename, "wb") as jarfile:
        jarfile.write(getFileContent(url))
        
def removeDownloadSymlink(tool,version,url):
    try:
        os.remove(genFilename(tool))
    except FileNotFoundError:
        pass
    download(url,genVersionFilename(tool, version))
    # Symlink in lib folder
    os.symlink(genVersionFilename(tool,version,False),genFilename(tool))


if __name__ == "__main__":
    start();
