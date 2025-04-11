# global WB_tool
#TOOL BEGIN sde
# output files
lappend WB_tool(sde,output)            tdrop
lappend WB_tool(sde,output)            tdr
lappend WB_tool(sde,input)             episcm
set WB_tool(sde,output,tdrop,file)     n@node@_op_msh.tdr
lappend WB_tool(sde,output,files)      *n@node@_*_msh.tdr
#TOOL END

#TOOL BEGIN sdevice

lappend WB_tool(sdevice,input)          tdrop
lappend WB_tool(sdevice,input)          mprpar
#output
lappend WB_tool(sdevice,output,files) *n@node@_des.plt
lappend WB_tool(sdevice,output,files) *n@node@_*.plt
lappend WB_tool(sdevice,output,files) *n@node@_*_des.dat
lappend WB_tool(sdevice,output,files) *n@node@_*_des.sav
lappend WB_tool(sdevice,output,files) *n@node@_des.tdr
lappend WB_tool(sdevice,output,files) *n@node@*.tdr
#TOOL END

puts "Reading epi/matpar utility SWB set-up..."
lappend WB_tool(file_types) episcm
set WB_tool(episcm,ext) scm
lappend WB_tool(file_types) tdrop
set WB_tool(tdrop,ext) tdr
lappend WB_tool(file_types) epitcl
set WB_tool(epitcl,ext) tcl
lappend WB_tool(file_types)       mprpar
set WB_tool(mprpar,ext)            par

#TOOL BEGIN  epi
set WB_tool(epi,category)               utility
set WB_tool(epi,visual_category)        utility
set WB_tool(epi,acronym)                epi
set WB_tool(epi,after)                  all
set WB_tool(epi,cmd_line)               "[gproject::Wdir]/../lib/epi.tcl @commands@"
set WB_tool(epi,epilogue)               { extract_vars "$wdir/results/nodes/@node@" @stdout@ @node@ }

set WB_binaries(tool,epi)               $app_data(bin_dir)/gtclsh
set Icon(epi)                           [gproject::Wdir]/../lib/epi.gif
set WB_manual(epi)                      $app_data(manual_dir)/epi.pdf

# input files
set WB_tool(epi,input)                  [list commands]
set WB_tool(epi,input,commands,file)    @toolname@_epi.csv
set WB_tool(epi,input,commands,label)   "Commands..."
set WB_tool(epi,input,commands,editor)  text

# add capability to open layer file in spreadsheet application
global WB_Miscellaneous
set WB_binaries(editor,spreadsheet) oocalc
lappend WB_editor(all) spreadsheet
lappend WB_tool(file_types)       xls
set WB_tool(xls,ext)            xls
if {[lsearch -exact $WB_tool(epi,input) xls] == -1} {
  lappend WB_tool(epi,input)     xls
}
set WB_tool(epi,input,xls,file)    @toolname@_epi.csv
set WB_tool(epi,input,xls,label) "Edit in Spreadsheet Application..."
set WB_tool(epi,input,xls,parametrized) 0
set WB_tool(epi,input,xls,editor)  spreadsheet


# output files
set WB_tool(epi,output)                 [list episcm epitcl]
set WB_tool(epi,output,episcm,file)     n@node@_epi.scm
set WB_tool(epi,output,epitcl,file)     n@node@_epi.tcl

# cleanup pattern
set WB_tool(epi,output,files)           "n@node@_epi.*"
lappend WB_tool(all) epi
#TOOL END

#TOOL BEGIN  mpr
set WB_tool(mpr,category)               utility
set WB_tool(mpr,visual_category)        utility
set WB_tool(mpr,acronym)                mpr
set WB_tool(mpr,after)                  all
set WB_tool(mpr,cmd_line)               "[gproject::Wdir]/../lib/mpr.tcl @commands@"
set WB_tool(mpr,epilogue)               { extract_vars "$wdir/results/nodes/@node@" @stdout@ @node@ }

set WB_binaries(tool,mpr)               $app_data(bin_dir)/gtclsh
set Icon(mpr)                           [gproject::Wdir]/../lib/mpr.gif
set WB_manual(mpr)                      $app_data(manual_dir)/mpr.pdf

# input files
set WB_tool(mpr,input)                  [list commands epitcl]
set WB_tool(mpr,input,commands,file)    @toolname@_mpr.cmd
set WB_tool(mpr,input,commands,label)   "Commands..."
set WB_tool(mpr,input,commands,editor)  text

set WB_tool(mpr,input,parmatedit,file)    "[glob -nocomplain [gproject::Wdir]/../par/*.tcl]"
set WB_tool(mpr,input,parmatedit,label)   "Edit All material.tcl Files"
set WB_tool(mpr,input,parmatedit,editor)  text
if {[lsearch -exact $WB_tool(mpr,input) parmatedit] == -1} {
  lappend WB_tool(mpr,input)                  parmatedit
}

set WB_tool(mpr,input,parlib,file)    "file://[gproject::Wdir]/../pardb/index.html"
set WB_tool(mpr,input,parlib,label)   "View Parameter Library (HTML)..."
set WB_tool(mpr,input,parlib,editor)  html_browser
if {[lsearch -exact $WB_tool(mpr,input) parlib] == -1} {
  lappend WB_tool(mpr,input)                  parlib
}
set WB_tool(mpr,input,parlibrefresh,file)    "[gproject::Wdir]/../lib/MakeParDoc.tcl [gproject::Wdir]/../pardb"
set WB_tool(mpr,input,parlibrefresh,label)   "Refresh Documentation"
set WB_tool(mpr,input,parlibrefresh,editor)  gtclsh
if {[lsearch -exact $WB_tool(mpr,input) parlibrefresh] == -1} {
  lappend WB_tool(mpr,input)                  parlibrefresh
}


# output files
set WB_tool(mpr,output)                 [list mprpar]
set WB_tool(mpr,output,mprpar,file)     n@node@_mpr.par

# cleanup pattern
set WB_tool(mpr,output,files)           "n@node@_*.*"
lappend WB_tool(mpr,output,files)       "[gproject::Wdir]/npar/n@node@_*.par"

lappend WB_tool(all) mpr 

# python pyCollector update file
set WB_tool(gsub,prologue) { exec python $wdir/../Python/py2prepper.py $wdir  }
#TOOL END

##INPUT-EDITORS BEGIN
set WB_binaries(editor,gtclsh) "gtclsh"
lappend WB_editor(all) gtclsh
##INPUT-EDITORS END
