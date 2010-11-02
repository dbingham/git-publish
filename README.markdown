git-publish
===========
Daniel Bingham <git@dbingham.com>

git publish: a simple shell script to ease the unnecessarily complex task of
"publishing" a branch, i.e., taking a local branch, creating a reference to it
on a remote repo, and setting up the local branch to track the remote one, all
in one go.

From the manpage:

    NAME
           git-publish - push a git branch to a remote and track it

    SYNOPSIS
           git-publish [OPTIONS] [<remote>]
           git-publish [OPTIONS] [<branch> [<remote>]]
           git-publish [OPTIONS] -r <newName> [<branch> [<remote>]]
           git-publish [OPTIONS] -d [<branch>]

    DESCRIPTION
           The first syntax publishes <branch> to <remote> and configures the 
           local <branch> to track the new remote <branch>.

           The second syntax renames <branch> to <newName>. If <branch> is 
           currently tracking a remote branch, the one it is currently tracking 
           will be renamed to <newName> as well. If it is not currently tracking 
           a remote branch, this command will publish it to a remote branch named 
           <newName> and will begin tracking that new remote branch (after it is
           renamed locally as well).

           The third syntax deletes the remote branched named <branch> and 
           removes tracking info from a local branch of the same name.

           If <branch> is not specified, the current branch is assumed.

           If <remote> is not specified, "origin" is assumed.

    OPTIONS
           -v, --verbose
               Print the git commands before executing them.

           -n, --dry-run
               Don’t run any of the git commands. Only print them, as in -v.

           -f, --force
               Don’t run any tests on the local and remote branches to see if they
               are already tracking branches, etc.

           -r, --rename=<newName>
               Rename <branch> to <newName>. If the local branch named 
               <branch> is tracking a remote branch, that remote branch will be 
               renamed to <newName> as well (regardless of its original name).  

               If the local branch named <branch> is *not* tracking a remote 
               branch, it will be published to a new remote branch named <newName>, 
               renamed to <newName> locally, and then configured to track the new 
               remote branch named <newName>.

               If combined with *-t*, this option only updates the tracking info 
               for <branch> to point to a remote branch named <newName>.  Even 
               if the local branch <branch> wasn't previously tracking any remote 
               branch, it will now.

           -d, --delete
               Delete the specified <branch> from <remote> and stop tracking it.

           -t, --tracking-only
               Don’t push any local branches or delete any remote ones - only
               change tracking configuration.

           --version
               Print version info in the format ´git publish version $version´.

           <remote>
               The remote to which you want to publish.

    EXIT STATUS
           0 on success and non-zero on failure.

    AUTHOR
           Daniel Bingham <git@dbingham.com>
           Forked from git-publish which was written by
           Gavin Beatty <gavinbeatty@gmail.com>
           And which was, in turn, forked from git-publish-branch by William Morgan

    RESOURCES
           Website: http://github.com/dbingham/git-publish/

    REPORTING BUGS
           Please report all bugs and wishes to <git@dbingham.com>

    COPYING
           git-publish Copyright (C) 2010 Daniel Bingham, <git@dbingham.com>

           Originally a fork of git-publish by Gavin Beatty, and as such, 
           retaining copyright: http://github.com/gavinbeatty/git-publish
           git-publish Copyright (C) 2010 Gavin Beatty, <gavinbeatty@gmail.com>

           Originally a fork of git-publish-branch, and as such, retaining 
           copyright: http://git-wt-commit.rubyforge.org/git-publish-branch
           git-publish-branch Copyright (C) 2008 William Morgan 
           <wmorgan-git-wt-add@masanjin.net>.

           Free use of this software is granted under the terms of the GNU General
           Public License version 3, or at your option, any later version.
           (GPLv3+)


Dependencies
------------

* sh: in POSIX
* sed: in POSIX.
* git: it is very much not in POSIX.

As such, git-publish should be portable across all platforms that Git supports.


License
-------
git publish is a modified version of git-publish, found:
http://github.com/gavinbeatty/git-publish

git-publish (by Gavin Beatty) is a modified version of git-publish-branch, found:
http://git-wt-commit.rubyforge.org/git-publish-branch

As this is a fork of git-publish (by Gavin Beatty), it retains the original 
copyright.
git-publish Copyright 2010 Gavin Beatty <gavinbeatty@gmail.com>.

As Gavin Beatty's git-publish is a fork of git-publish-branch, it retains the 
original copyright to git-publish-branch as well.
git-publish-branch Copyright 2008 William Morgan <wmorgan-git-wt-add@masanjin.net>.

The modifications are copyright.
git publish Copyright 2010 Daniel Bingham <git@dbingham.com>.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You can find the GNU General Public License at:
http://www.gnu.org/licenses/


Install
-------
Configure:
    make

Or configure with your own build directory:
    make builddir=../build/git-publish

Build:
    make

Default prefix is `/usr/local`:
    sudo make install

Select your own prefix:
    make install prefix=~/


