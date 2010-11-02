#!/bin/sh

## git publish is a modified version of git-publish-branch, found:
## http://git-wt-commit.rubyforge.org/git-publish-branch
##
## As this is a fork of git-publish-branch, it retains the original copyright.
## git-publish-branch Copyright 2008 William Morgan <wmorgan-git-wt-add@masanjin.net>.
##
## The modifications are copyright.
## git publish Copyright 2010 Gavin Beatty <gavinbeatty@gmail.com>.
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You can find the GNU General Public License at:
##   http://www.gnu.org/licenses/

set -e

# @VERSION@

SUBDIRECTORY_OK=Yes
OPTIONS_KEEPDASHDASH=""
OPTIONS_SPEC="\
git publish [options] [<branch> [<remote>]]
git publish [options] -r <newName> [<branch> [<remote>]]
git publish [options] -d [<branch>]
--
v,verbose   print each command as it is run
n,dry-run   don't run any commands, just print them
f,force     don't do any checks on whether <local_branch> is tracking a branch already
r,rename=    rename the local <branch> and the remote branch to <newName>
d,delete    delete tracking configuration for <local_branch>
t,tracking-only only update tracking info - don't publish or delete any remote branches
version     print version info in 'git publish version \$version' format

NOTE: See help for full details on all options."

. "$(git --exec-path)/git-sh-setup"

version_print() {
    echo "git publish version ${VERSION}"
}

doit() {
    if test -n "$verbose" ; then
        echo "$@"
    fi
    if test -z "$dryrun" ; then
        "$@"
    fi
}
assert_HEAD() {
    if ! git rev-parse --verify -q HEAD >/dev/null ; then
        die "Cannot operate with detached HEAD without being given <branch>"
    fi
}

main() {
    dryrun=""
    force=""
    verbose=""
    rename=""
    newBranch=""
    delete=""
    branch=""
    track=""
    currentBranch="$(git symbolic-ref HEAD | sed -e 's|^refs/heads/||')"
    while test $# -ne 0 ; do
        case "$1" in
        -n|--dry-run)
            dryrun="true"
            verbose="true"
            ;;
        -f|--force)
            force="true"
            ;;
        -v|--verbose)
            verbose="true"
            ;;
        -r|--rename)
            rename="true"
            newBranch="$2"
            shift
            ;;
        -d|--delete)
            delete="true"
            ;;
        -t|--tracking-only)
            track="true"
            ;;
        --version)
            version_print
            exit 0
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done

    remote="origin"
    if test $# -gt 0 ; then
        branch="$1"
    else
        assert_HEAD
        branch=$currentBranch
    fi
    if test $# -gt 1 ; then
        remote="$2"
    fi
    if test $# -gt 2 ; then
        usage >&2
        exit 1
    fi
    
    if test -n "$rename" ; then
        if test -z "$force" ; then
            local_ref="$(git show-ref "heads/${branch}" || e=$?)"
            if test -z "$local_ref" ; then
                die "ERROR: No local branch ${branch} exists!"
            fi
            remote_ref="$(git show-ref "remotes/${remote}/${newBranch}" || e=$?)"
            if test -n "$remote_ref" ; then
                die "ERROR: A remote branch ${newBranch} on ${remote} already exists!"
            fi
	fi
	# If not set to only updating tracking info...
        if test -z "$track" ; then
	    # Publish existing to the new name
	    doit git push "${remote}" "${branch}:refs/heads/${newBranch}"
	    # Now fetch the remote to get the tracking branch locally
            doit git fetch "${remote}"
	    # Create new local branch that tracks the new remote branch
	    doit git branch --track "${newBranch}" "${remote}/${newBranch}"
	    # If currently on the branch in question...
	    if [ "${currentBranch}" == "${branch}" ]; then
	        # Then switch to the newly created branch
	        doit git checkout ${newBranch}
            fi

	    # Check to see if the branch in question was previously tracking a remote branch
	    trackingBranch=$(git for-each-ref --format='%(upstream)' refs/heads/${branch} | sed "s|refs/remotes/||")
	    # If it was...
	    if test -n "${trackingBranch}" ; then
		# Grab the old remote
	        oldRemote=$(echo $trackingBranch | sed 's|\([^/]*\)/.*|\1|')
		# Grab the old tracking branch name
		oldBranch=$(echo $trackingBranch | sed 's|[^/]*/\(.*\)|\1|')
		# Then delete the old remote branch
		doit git push "${oldRemote}" ":refs/heads/${oldBranch}"
		# Now fetch the remote to get everything up to date
		doit git fetch "${oldRemote}"
		# Then, prune the remote to get rid of old tracking branches
		doit git remote prune "${oldRemote}"
	    fi

	    # Finally, delete the old local branch
            doit git branch -d ${branch}
	# If set to only update tracking info...
	else
	    # Set the proper remote
            doit git config "branch.${branch}.remote" "${remote}"
	    # Set the tracking branch to the one specified
	    doit git config "branch.${branch}.merge" "refs/heads/${newBranch}"
	fi
    elif test -n "$delete" ; then
        if test -z "$track" ; then
            doit git push "$remote" ":refs/heads/${branch}"
        fi
        doit git config --unset "branch.${branch}.remote"
        doit git config --unset "branch.${branch}.merge"

    else
        if test -z "$force" ; then
            local_ref="$(git show-ref "heads/${branch}" || e=$?)"
            if test -z "$local_ref" ; then
                die "No local branch ${branch} exists!"
            fi
            remote_ref="$(git show-ref "remotes/${remote}/${branch}" || e=$?)"
            if test -n "$remote_ref" ; then
                die "A remote branch ${branch} on ${remote} already exists!"
            fi
            remote_config="$(git config "branch.${branch}.merge" || e=$?)"
            if test -n "$remote_config" ; then
                die "Local branch ${branch} is already tracking ${remote_config}"
            fi
        fi

        if test -z "$track" ; then
            doit git push "$remote" "${branch}:refs/heads/${branch}"
        fi
        doit git config "branch.${branch}.remote" "$remote"
        doit git config "branch.${branch}.merge" "refs/heads/${branch}"
    fi
}

trap "echo \"caught SIGINT\" ; exit 1 ;" INT
trap "echo \"caught SIGTERM\" ; exit 1 ;" TERM
trap "echo \"caught SIGHUP\" ; exit 1 ;" HUP

main "$@"

