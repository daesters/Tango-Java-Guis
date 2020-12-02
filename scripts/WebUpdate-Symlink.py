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

import shutil
import threading
import time


# Constants
LIBFOLDER = '../libs/'
SOURCE_FILE = 'sources.json'
ERROR_VERSION_TEXT = "Couldn't find latest version"
TIMEOUT_DOWNLOAD_TEXT = "Timeout occured when downloading"
ERROR_DOWNLOAD_TEXT = "Couldn't download"
ERROR_PROCESS_TEXT = "Couldn't process downloaded file"
TIMEOUT_TOOL_PROCESS_TEXT = "Couldn't finish proccessing, timeout occured"


class Files:
    def __init__(self, folder="../libs", filetype='.jar'):
        """ Looks for the library files (typically 'jar' files) and
        stores them in a list
        """
        if folder != "":
            if os.path.exists(folder):
                myfiles = [files for _, _, files in os.walk(folder)][0]
                self.libfiles = [file for file in myfiles if filetype in file]
                self.filetype = filetype
            else:
                raise ProcessError(f"       Scanning folder {folder} failed ",
                                   self, "!!!")

    def get_downloaded_version(tool):
        """Returns the local version from a downloaded file
        """
        if hasattr(self, 'libfiles'):
            version_files = [file for file in self.libfiles
                             if tool in file and "-" in file]
            versions = []
            for file in version_files:
                v = _get_version_from_name(file)
                versions.append(v)

            if len(versions) > 1:
                return versions
            elif len(versions) == 1:
                return versions[0]
            else:
                return None

    def _get_version_from_name(filename):
        """ From the filename it derives the version
        """
        version_split = "-"
        return filename.split("-")[1].split(self.filetype)[0]


# ####### Classes ############

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
    timeout = 10

    def __init__(self, tool, parameters, offline=False):
        self.requiredKeys = ['url']
        self._tool = tool
        self._offline = offline

        if self._checkKeys(parameters):
            self._url = parameters['url']

        self._version = ""
        self._downloadURL = ""

        self._files = Files()

    def __str__(self):
        """String representation overload, for example when using print()"""
        if self._version == "":
            version = "?"
        else:
            version = self._version
        return self._tool+", "+"version: "+version

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
    def generalname(self):
        """Name of the general symlink (to the jar file)
        without version numbers"""
        return self.tool+".jar"

    def relativepath(self, name=""):
        """Path of the library file name or given name in lib folder"""
        if name == "":
            name = self.filename
        return os.path.join(LIBFOLDER, name)

    def download(self):
        """Downloads a file from given URL
        Thanks to https://stackoverflow.com/a/34863581"""
        if self.skip():
            print("Skipped")
            return

        if self._checkURL(self.downloadURL):
            with open(self.relativepath(), "wb") as jarfile:
                try:
                    jarfile.write(self._getFileContent(self.downloadURL))
                except requests.exceptions.Timeout:
                    raise DownloadError(self._tool,
                                        TIMEOUT_DOWNLOAD_TEXT,
                                        self.downloadURL)
        else:
            raise DownloadError(self._tool, ERROR_DOWNLOAD_TEXT,
                                self.downloadURL)

    def createSymlink(self):
        """Create a symlink to the jar file"""
        try:
            os.remove(self.relativepath(self.generalname))
        except FileNotFoundError:
            pass
        # Symlink in lib folder
        os.symlink(self.relativepath(), self.relativepath(self.generalname))

    def copy(self):
        """Copies the jar file without the version in the file name"""
        try:
            os.remove(self.relativepath(self.generalname))
        except FileNotFoundError:
            pass
        # Copy in lib folder
        shutil.copy(self.relativepath(), self.relativepath(self.generalname))

    def isValid(self):
        """Determines, whethter this item is valid to download"""
        if self.version == "" or self.downloadURL == "" \
                or self.version == ERROR_VERSION_TEXT:
            return False

        return True

    def skip(self):
        """Skipping tool"""
        return self._skip and self._offline

    # "Private" functions
    def _checkURL(self, url=""):
        """Check if URL exists"""
        if url == "":
            url = self._url

        if self._offline:
            print("Don't check URLs when offline")
            return False

        try:
            status = requests.head(url).status_code
        except ConnectionError:
            print("Connection error to {}".format(url))
            return False
        except Exception:
            print("General network error. Connection could not be "
                  "established to {}".format(url))
            return False

        # corresponds to HTTP 200 and 302
        if status in [requests.codes.ok, requests.codes.found]:
            return True
        else:
            print("Access error, status: {}, url: {}".format(status, url))
            return False

    def _getFileContent(self, url):
        """Get the content of the file of the given URL"""
        try:
            return requests.get(url, timeout=self.timeout).content
        except requests.exceptions.Timeout:
            raise DownloadError(self.tool, TIMEOUT_DOWNLOAD_TEXT, url)

    def _getFileText(self, url):
        """Get the text of the file of the given URL"""
        try:
            return requests.get(url, timeout=self.timeout).text
        except requests.exceptions.Timeout:
            raise DownloadError(self.tool, TIMEOUT_DOWNLOAD_TEXT, url)

    def _debugPrint(self, *text):
        """Prints text when self.debug is True"""
        if self.debug:
            print(" ".join(text))

    def _checkKeys(self, parameters):
        """Check for skipping and required keys"""
        if "skip" in parameters:
            self._skip = True
            return False
        else:
            self._skip = False
        for key in self.requiredKeys:
            if key not in parameters:
                raise ConfigError(self._tool,
                                  "key {} not found in "
                                  "source config".format(key))
        return True

# ##
# Class BintrayLib
# ##


class BintrayLib(Library):
    """Binaries from Bintray.com"""

    def __init__(self, tool, parameters, offline=False):
        self._mavenFile = 'maven-metadata.xml'
        self.requiredKeys = ['url']
        super().__init__(tool, parameters, offline)

    @property
    def version(self):
        """Returns the version of the tool"""
        if self._version == "":
            try:
                self._debugPrint("    Request", self._mavenFile)
                xmltext = self._getFileText(self._url+self._mavenFile)
                self._version = str(minidom.parseString(xmltext).
                                    getElementsByTagName('latest')[0].
                                    firstChild.nodeValue)
            except Exception:
                self._version = ERROR_VERSION_TEXT

        return self._version

    @property
    def downloadURL(self):
        """Returns the download URL"""
        if self._downloadURL == "":
            self._downloadURL = self._url + self.version + "/" +\
                                self._tool+"-" + self.version+".jar"

        return self._downloadURL


###
# Class GithubLib
###

class GithubLib(Library):
    def __init__(self, tool, parameters, offline=False):
        super().__init__(tool, parameters, offline)
        # Store request, therefore class attribute
        self._request = None
        self._getGithubInfos()

    @property
    def version(self):
        """Returns the version of the tool"""
        if self._version == "" and self._request is not None:
            self._version = self._request.json()['tag_name']
        else:


        return self._version

    @property
    def downloadURL(self):
        """Returns the download URL"""
        if self._downloadURL == "" and self._request is not None:
            self._downloadURL =\
                self._request.json()['assets'][0]['browser_download_url']

        return self._downloadURL

    def _getGithubInfos(self):
        if self._checkURL():
            self._debugPrint("    Request infos from github")
            self._request = requests.get(self._url)


###
# Class GeneralLib
###
class GeneralLib(Library):
    def __init__(self, tool, parameters, offline=False):
        self.requiredKeys = ['url', 'version']
        super().__init__(tool, parameters, offline)

        if self._checkKeys(parameters):
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
        """Download file (usually a archive) and
        make post actions if defined"""

        if self._checkURL(self.downloadURL):
            # Download
            fname = self._parameters['url'].split('/')[-1]
            fpath = self.relativepath(fname)
            with open(fpath, "wb") as f:
                f.write(self._getFileContent(self.downloadURL))

            # Action
            key = 'postParameters'
            fnKey = 'function'
            ptKey = 'path'

            # Check postParameters
            if key in self._parameters.keys() and \
                    fnKey in self._parameters[key].keys() and \
                    ptKey in self._parameters[key].keys():

                fn = self._parameters[key][fnKey]
                path = self._parameters[key][ptKey]
                # Unzip action
                if fn == 'unzip' and path != "":
                    # Processing
                    self._debugPrint("      extract and move")
                    exf = zipfile.ZipFile(fpath).\
                        extract(member=path, path=LIBFOLDER)

                    try:
                        os.rename(exf, self.relativepath())
                    except FileExistsError:
                        os.remove(self.relativepath())
                        os.rename(exf, self.relativepath())

                    # Clean up
                    self._debugPrint("      clean up")
                    try:
                        # FIXME: Fails on windows
                        os.rmdir(exf.rsplit('/', maxsplit=1)[0])
                        os.remove(fpath)
                    except OSError:
                        raise ProcessError("       Cleanup failed for tool",
                                           self.tool, "!!!")
                else:
                    # No post parameters
                    raise ProcessError(self._tool, ERROR_PROCESS_TEXT, fname)

            else:
                raise ProcessError(self._tool, ERROR_PROCESS_TEXT, fname)
        else:
            raise DownloadError(self._tool, ERROR_DOWNLOAD_TEXT,
                                self.downloadURL)


# User Exception classes


class ConfigError(Exception):
    """Exception raised when problems with configuration occur"""
    def __init__(self, tool, text):
        self.tool = tool
        self.text = text


class DownloadError(Exception):
    """Exception raised when problems with download occur"""
    def __init__(self, tool, text, url=None):
        self.tool = tool
        self.text = text
        self.url = url


class ProcessError(Exception):
    """Exception raised when problems with processing file occur"""
    def __init__(self, tool, text, filename=None):
        self.tool = tool
        self.text = text
        self.filename = filename
######################################
# Main Class
####


class Updater:

    def __init__(self, args=sys.argv):

        # default values
        self.allowSymlink = True
        self.allowDownload = True
        self.makeCopy = False
        self.helpNeeded = False
        self.assumeYes = False
        self.requestTimeout = 5
        self.toolProcessTimeout = 180

        self.pages = []

        # overwrite default values
        self.checkOptions(args)

    def action(self):
        """ Checks what to do"""
        if self.helpNeeded:
            self.printHelp()
        elif not self.allowSymlink and not self.allowDownload:
            print("There is nothing to do... Quit")
        else:
            answer = "invalid"
            if not self.assumeYes:
                if self.allowDownload:
                    answer = input("You really want to update "
                                   "the libs from the web? [Y/n]")
                elif self.makeCopy:
                    answer = input("You really want to copy (and overwrite?) "
                                   "the libraries? [Y/n]")
                elif self.allowSymlink:
                    answer = input("You really want to create "
                                   "symbolic links? [Y/n]")

            if self.assumeYes or answer in ["y", "Y", ""]:
                try:
                    self.initTools()
                    print("Processing...")
                    self.process()
                    print("...done")
                except ConfigError as e:
                    print("ERROR when reading config for tool {}: {}".
                          format(e.tool, e.text))
                    raise
                except DownloadError as e:
                    print("ERROR when downlading tool {}: {}. url {}".
                          format(e.tool, e.text, e.url))
                    raise
                except ProcessError as e:
                    print("ERROR when processing file for tool {}: {}. file {}".
                          format(e.tool, e.text, e.filename))
                    raise
                else:
                    print("Quit")

    def initTools(self):
        """Reads source file and updates binaries"""
        print("Check binaries...")

        sources = {}
        try:
            with open(SOURCE_FILE, 'r') as fsource:
                sources = json.loads(fsource.read())

            self.pages.append([BintrayLib(tool, parameters, self.allowDownload) for
                               tool, parameters in sources['bintray'].items()])
            self.pages.append([GithubLib(tool, parameters, self.allowDownload) for
                               tool, parameters in sources['github'].items()])
            self.pages.append([GeneralLib(tool, parameters, self.allowDownload) for
                               tool, parameters in sources['general'].items()])

        except json.decoder.JSONDecodeError:
            print("ERROR decoding source file!")
            raise

    # ## Helpers
    def process(self):
        """Downloads the items from the various sites"""
        threads = []
        for page in self.pages:
            for tool in page:
                t = threading.Thread(target=processTool,
                                     name=tool,
                                     args=(tool,
                                           self.allowDownload,
                                           self.makeCopy,
                                           self.allowSymlink,))
                threads.append(t)
                t.start()

        for t in threads:
            t.join(self.toolProcessTimeout)  # wait 3 min per tool
            if t.is_alive():
                print("Timeout occured for {}".format(t.name))

    def checkOptions(self, args):
        """ Checks the option arguments"""
        # Check debug flag
        if self._isOption(args, '-d', '--debug'):
            Library.debug = True  # so all Library subclasses know ;-)
        # Check download flag
        if self._isOption(args, '-n', '--no-download'):
            self.allowDownload = False
        # Check symlink flag
        if self._isOption(args, '-t', '--no-symlinks'):
            self.allowSymlink = False
        # Check copy flag
        if self._isOption(args, '-c', '--copy'):
            self.makeCopy = True
        # Check help flag
        if self._isOption(args, '-h', '--help'):
            self.helpNeeded = True
        # Check assume-yes flag
        if self._isOption(args, '-y', '--assume-yes'):
            self.assumeYes = True

    def printHelp(self):
        print(
            "This is the library updater, which takes the binaries "
            "from the various webpages \n"
            "Usage \n"
            "-d|--debug \t Debug option \n"
            "-n|--no-download \t Don't donwload files \n"
            "-t|--no-symlinks \t Don't create symlinks \n"
            "-c|--copy \t\t Create copies instead of symlinks \n"
            "-y|assume-yes \t Assume yes and don't ask questions\n"
            "-h|--help \t This help"
        )

    # #
    # Helper function
    def _isOption(self, arguments, *options):
        """ Checks whether at least one of the options is in arguments"""
        return not set(arguments).isdisjoint(options)


def processTool(tool, allowDownload, makeCopy, allowSymlink):
    if tool.skip():
        print("Skipped", tool)
        return

    if tool.isValid():
        if allowDownload:
            print("...download", tool)
            startT = time.process_time()
            try:
                tool.download()
                endT = time.process_time()
                diffT = endT - startT
            except DownloadError as e:
                print("{} \t tool: {} url: {}".format(e.text, e.tool, e.url))
            else:
                print("downloaded {} ({:3.2f} s)".format(tool, diffT))
        if makeCopy:
            print("... copy jarfile for", tool)
            tool.copy()
        elif allowSymlink:
            print("... create symlink for", tool)
            tool.createSymlink()
    else:
        print("Cannot download", tool)

# ####### Shell script ############


if __name__ == "__main__":
    updater = Updater(sys.argv)
    updater.action()
