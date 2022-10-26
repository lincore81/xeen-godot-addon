#!/usr/bin/env python3
""" 
Generate a *rudimentary* documentation of a gdscript project. There are probably
a million better ways to do this, but I'm too lazy to learn about them.

(c) 2022 by lincore81

(UN)LICENSE:

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
"""

# TODO: Clean up this mess ;)

import os
#import argparse
import re

ignore_list = [
    ".git",
    "ignore"
]

project_name = "Xeen Map Editor"
extension = ".gd"
output = os.path.expanduser("~/projects/godot/xeen/addons/xeen/docs/reference.md")
basedir = os.path.expanduser("~/projects/godot/xeen/addons/xeen")

re_extends = re.compile("^extends\s+(?P<extends>\w+)", re.MULTILINE)
re_class_name = re.compile("^\s*class_name\s+(?P<classname>\w+)", re.MULTILINE)
re_func = re.compile("^((?P<static>static)\s)?func\s+(?P<funcname>\w+)\s*\((?P<params>[^)]*)\)\s*(->\s*(?P<returns>\w+)\s*)?:", re.MULTILINE)
re_param = re.compile("^(?P<name>\w+)(\s*(:\s*(?P<type>\w+)?)?\s*(=\s*(?P<default>\S+)))?$")


def find_script_files(base_dir):
    filelist = []
    for (path, dirs, files) in os.walk(base_dir):
        for f in files:
            fullname = os.path.normpath(path + '/' + f)
            ignore = next(filter(lambda i: i in fullname, ignore_list), False)
            if not ignore and fullname.endswith(extension):
                filelist.append(fullname)
    return filelist

#def parse_params(params):
#    params = params.strip()
#    if params == "":
#        return []
#    result = []
#    for param in params.split(","):
#        match = re_param.search(param.strip())
#        if match:
#            result.append({
#                "name": match.group("name"),
#                "type": match.group("type"),
#                "default": match.group("default"),
#            })
#    return result
#

def generate_doc(path, content):
    doc = {"funcs": {}, "path": path}
    match = re_extends.search(content)
    if match:
        doc["extends"] = match.group("extends")
    match = re_class_name.search(content)
    if match:
        doc["class"] = match.group("classname")
    else:
        doc["class"] = os.path.basename(path)
    for match in re_func.finditer(content):
        if match and not match.group("funcname").startswith("_"):
            funcdef = {
                "static": not not match.group("static"),
                "name": match.group("funcname"),
                "params": match.group("params"),
                "returns": match.group("returns"),
            }
            doc["funcs"][funcdef["name"]] = funcdef
    return doc



def write_func_md(funcdef):
    static = "static " if funcdef["static"] else ""
    returns = "-> %s" % funcdef["returns"] if funcdef["returns"] else ""
    return "`%s%s(%s) %s`" % (static, funcdef["name"], funcdef["params"], returns)

def write_script_md(scriptdef):
    classname = scriptdef
    md = """
# %s

- *extends:* %s
- *file:* %s

""" % (scriptdef.get("class"), scriptdef.get("extends"), scriptdef.get("path"))
    return md + "\n\n".join([write_func_md(f) for f in scriptdef["funcs"].values()])

#def write_toc_md(docs):
#    return "\n".join(["- [%s (%s)](#%s)" % (doc["class"], doc["path"], doc["class"].replace(" ", "-").lower()) for doc in docs.values()])

def write_classes_md(docs):
    return "\n\n".join([write_script_md(x) for x in docs.values()])

def write_docs_md(docs):
    return """%% %s

%s""" % (project_name, write_classes_md(docs))



def main():
    scripts = find_script_files(basedir)
    docs = {}
    for s in scripts:
        with open(s, "r") as f:
            content = f.read()
        relative_file = s.removeprefix(basedir)
        docs[relative_file] = generate_doc(relative_file, content)
    md = write_docs_md(docs)
    with open(output, "w", encoding="utf-8") as f:
        f.write(md)

if __name__ == "__main__": 
    main()
