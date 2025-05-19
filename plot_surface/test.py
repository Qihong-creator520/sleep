# script for mask out subcortical

import sys
from sys import argv
import nibabel as nib

def usage():
   print ("Usage: " + argv[0] + " <folder where data metrics are> <weightsFile> <hemisphere> <output filename>")
   sys.exit(1)
if len(argv) < 2:
   usage()

inFolder=argv[1]
indata_name=argv[2]
outdata_path=argv[3]
outdata_name=argv[4]
mask_path=argv[5]
mask_name=argv[6]
tempdata_name=argv[7]



mask_name_new=str(mask_path) + "/" + str(mask_name)
giiFilename=str(inFolder) + "/" + str(indata_name)
out_name=str(outdata_path) + "/" + str(outdata_name)
temp_name=str(outdata_path) + "/" + str(tempdata_name)

print(mask_name)
print(giiFilename)
print(out_name)
print(temp_name)

mask_file=nib.load(mask_name_new)
giiFile=nib.load(giiFilename)
tempd=nib.load(temp_name)

mask_matrix=mask_file.darrays[0].data
data_matrix=giiFile.dataobj

mask_matrix[mask_matrix>1]=1
data_matrix_new=data_matrix * mask_matrix

tempd.darrays[0].data=data_matrix_new

nib.save(tempd,out_name)


