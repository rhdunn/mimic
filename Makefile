###########################################################################
##                                                                       ##
##                  Language Technologies Institute                      ##
##                     Carnegie Mellon University                        ##
##                      Copyright (c) 1999-2014                          ##
##                        All Rights Reserved.                           ##
##                                                                       ##
##  Permission is hereby granted, free of charge, to use and distribute  ##
##  this software and its documentation without restriction, including   ##
##  without limitation the rights to use, copy, modify, merge, publish,  ##
##  distribute, sublicense, and/or sell copies of this work, and to      ##
##  permit persons to whom this work is furnished to do so, subject to   ##
##  the following conditions:                                            ##
##   1. The code must retain the above copyright notice, this list of    ##
##      conditions and the following disclaimer.                         ##
##   2. Any modifications must be clearly marked as such.                ##
##   3. Original authors' names are not deleted.                         ##
##   4. The authors' names are not used to endorse or promote products   ##
##      derived from this software without specific prior written        ##
##      permission.                                                      ##
##                                                                       ##
##  CARNEGIE MELLON UNIVERSITY AND THE CONTRIBUTORS TO THIS WORK         ##
##  DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING      ##
##  ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT   ##
##  SHALL CARNEGIE MELLON UNIVERSITY NOR THE CONTRIBUTORS BE LIABLE      ##
##  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    ##
##  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN   ##
##  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,          ##
##  ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF       ##
##  THIS SOFTWARE.                                                       ##
##                                                                       ##
###########################################################################
##                                                                       ##
##    Fast efficient small run-time speech synthesis system              ##
##    http://cmuflite.org                                                ##
##                                                                       ##
##       Authors:  Alan W Black (awb@cs.cmu.edu)                         ##
##                 Kevin A. Lenzo (lenzo@cs.cmu.edu)                     ##
##                 and others see ACKNOWLEDGEMENTS                       ##
##          Date:  December 2014                                         ##
##       Version:  2.0.0 release                                         ##
##                                                                       ## 
###########################################################################
TOP=.
DIRNAME=
BUILD_DIRS = include src lang doc
ALL_DIRS=config $(BUILD_DIRS) testsuite \
         wince windows android \
         tools main 
CONFIG=configure configure.in config.sub config.guess \
       missing install-sh mkinstalldirs
WINDOWS = Exports.def mimic.sln mimicDll.vcproj
FILES = Makefile README ACKNOWLEDGEMENTS COPYING $(CONFIG) $(WINDOWS)
DIST_CLEAN = .time-stamp $(TOP)/build/ \
                config.cache config.log config.status \
		config/config config/system.mak FileList

HOST_ONLY_DIRS = tools main
ALL = $(BUILD_DIRS)

config_dummy := $(shell test -f config/config || ( echo '*** '; echo '*** Making default config file ***'; echo '*** '; ./configure; )  >&2)

include $(TOP)/config/common_make_rules

ifeq ($(TARGET_OS),wince)
BUILD_DIRS += wince
endif

config/config: config/config.in config.status
	./config.status

configure: configure.in
	autoconf

backup: time-stamp
	@ $(RM) -f $(TOP)/FileList
	@ $(MAKE) file-list
	@ echo .time-stamp >>FileList
	@ ln -s . $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)
	@ sed 's/^\.\///' <FileList | sed 's/^/'$(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)'\//' >.file-list-all
	@ tar jcvf $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE).tar.bz2 `cat $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)/.file-list-all`
	@ $(RM) -f $(TOP)/.file-list-all
	@ $(RM) $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE) 
	@ ls -l $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE).tar.bz2

backupbz2: time-stamp
	@ $(RM) -f $(TOP)/FileList
	@ $(MAKE) file-list
	@ echo .time-stamp >>FileList
	@ ln -s . $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)
	@ sed 's/^\.\///' <FileList | sed 's/^/'$(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)'\//' | grep -v cmu_us_kal | grep -v cmu_us_awb | grep -v cmu_us_rms | grep -v cmu_us_slt | grep -v cmu_time_awb >.file-list-all
	@ tar jcvf $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE).tar.bz2 `cat $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)/.file-list-all`
	@ $(RM) -f $(TOP)/.file-list-all
	@ $(RM) $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE) 
	@ ls -l $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE).tar.bz2

tags:
	@ $(RM) -f $(TOP)/FileList
	@ $(MAKE) file-list
	etags `cat FileList | grep "\.[ch]$$"`

install:
	@echo Installing 
	mkdir -p $(DESTDIR)$(INSTALLBINDIR)
	mkdir -p $(DESTDIR)$(INSTALLLIBDIR)
	mkdir -p $(DESTDIR)$(INSTALLINCDIR)
	$(INSTALL) -m 644 include/*.h $(DESTDIR)$(INSTALLINCDIR)
	@ $(MAKE) -C main --no-print-directory DESTDIR=$(DESTDIR) install

time-stamp :
	@ echo $(PROJECT_NAME) >.time-stamp
	@ echo $(PROJECT_PREFIX) >>.time-stamp
	@ echo $(PROJECT_VERSION) >>.time-stamp
	@ echo $(PROJECT_DATE) >>.time-stamp
	@ echo $(PROJECT_STATE) >>.time-stamp
	@ echo $(LOGNAME) >>.time-stamp
	@ hostname >>.time-stamp
	@ date >>.time-stamp

# Convinience command, to generate cg dumped voices
voices: ./bin/mimic_cmu_us_awb ./bin/mimic_cmu_us_rms ./bin/mimic_cmu_us_rms
	mkdir -p voices
	./bin/mimic_cmu_us_awb -voicedump voices/cmu_us_awb.mimicvox
	./bin/mimic_cmu_us_rms -voicedump voices/cmu_us_rms.mimicvox
	./bin/mimic_cmu_us_slt -voicedump voices/cmu_us_slt.mimicvox

test:
	@ $(MAKE) --no-print-directory -C testsuite test

