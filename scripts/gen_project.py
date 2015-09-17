#!/usr/bin/env python

import urllib2
from urllib2 import urlopen, Request
import json
import sys
import os
from string import Template

LIB_OUT_PATH = ""

try:
    from github_token import GITHUB_TOKEN
except ImportError:
    print 'You need to provide a github personal authorization token first!'
    print 'You should read the documentation in: https://github.com/cdrfiuba/kicad-project-generator'
    print 'and go to: https://github.com/settings/tokens'
    sys.exit(1)


def get_latest_repo_commit(repo_ref_url):
    url = repo_ref_url + '/heads/master'
    token = GITHUB_TOKEN
    request = Request(url)
    request.add_header('Authorization', 'token %s' % token)
    commit = urlopen(request).read()
    c = json.loads(commit)
    latest_commit = c["object"]["sha"]
    return latest_commit


def get_kicad_repos():
    kicad_repo_list = "https://api.github.com/orgs/KiCad/repos?per_page=2000"
    token = GITHUB_TOKEN
    request = Request(kicad_repo_list)
    request.add_header('Authorization', 'token %s' % token)
    list = urllib2.urlopen(kicad_repo_list).read()
    l = json.loads(list)
    return l


def get_latest_lib_conf():
    kicad_lib_conf = "https://api.github.com/repos/kicad/kicad-library/git/refs"
    return get_latest_repo_commit(kicad_lib_conf)


def get_kicad_libs():
    libs = []
    repos = get_kicad_repos()
    for repo in repos:
        fname = repo["full_name"]
        if ".pretty" in fname:
            lib = {'clone_url': repo["clone_url"], 'name': repo["name"]}
            ref_url = repo["git_refs_url"].split("{")[0]
            lib['commit'] = get_latest_repo_commit(ref_url)
            print "Lib {name}, commit: {commit}".format(**lib)
            libs.append(lib)
    return libs


def get_latest_source_lib(latest_lib):
    """Gets the latest commit of the source, schematic libs and dos repo."""

    src_ref = "https://api.github.com/repos/kicad/kicad-source-mirror/git/refs"
    latest_src = get_latest_repo_commit(src_ref)
    vars = {'SRCS_COMMIT': latest_src, 'LIBS_COMMIT': latest_lib}
    return vars


def gen_rosinstall(libs, outfile):
    """Generates a rosinstall file to clone all the kicad libs"""
    with open(outfile, 'w') as out:
        for lib in libs:
            lib['path'] = os.path.join(LIB_OUT_PATH, lib['name'])
            line = "- git: {{local-name: '{path}', uri: '{clone_url}', version: '{commit}' }}\n".format(**lib)
            out.write(line)


def replace_template(infile, vars, outfile):
    with open(infile, 'r') as template_file:
        temp = Template(template_file.read())
        result = temp.substitute(vars)

    with open(outfile, 'w') as out:
        out.write(result)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print "Usage: {} <path to project>".format(sys.argv[0])
        sys.exit(1)

    dest_dir = sys.argv[1]
    # Removes the trailing /
    if dest_dir[-1] == '/':
        dest_dir = dest_dir[:-1]
    proj_name = os.path.basename(dest_dir)

    LIB_COMMIT_SHA = get_latest_lib_conf()
    kicad_libs = get_kicad_libs()
    rosinstall_path = os.path.join(dest_dir, 'docker/kicad_libs.rosinstall')
    gen_rosinstall(kicad_libs, rosinstall_path)

    # Replace kicad build script
    f = os.path.join(dest_dir, 'docker/kicad-install.sh')
    vars = get_latest_source_lib(LIB_COMMIT_SHA)
    replace_template(f, vars, f)

    # Replace install libs script
    f = os.path.join(dest_dir, 'docker/download-kicad-library.sh')
    vars = {'LIB_COMMIT_SHA': LIB_COMMIT_SHA}
    replace_template(f, vars, f)

    # Replace README file
    f = os.path.join(dest_dir, 'README.md')
    replace_template(f, {'PROJECT_NAME': proj_name}, f)

    # Replace the setup.bash
    f = os.path.join(dest_dir, 'setup.bash')
    name = proj_name.lower()
    vars = {'PROJECT_NAME': name, 'PROJECT_PATH': dest_dir}
    replace_template(f, vars, f)
