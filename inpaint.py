import cv2 
import sys
import os
import glob
import timeit
  
img  = cv2.imread(sys.argv[1]) 
mask = cv2.imread(sys.argv[2], cv2.COLOR_BGR2GRAY)
dst  = cv2.inpaint(img, mask, 5, cv2.INPAINT_NS)

cv2.imwrite(sys.argv[3], dst)
