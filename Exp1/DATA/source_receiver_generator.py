#!/usr/bin/python
import numpy as np
import math

def create_linear_source(NSRC,xs0,dxs,zs0,dzs):
    """ 
     to create linear source list with fixed space
     # NSRC -- total # of sources
     # xs0 -- first source coordinate in x 
     # dxs -- space in x 
     # zs0 -- first source coordinate in z 
     # dzs -- space in z 
    """
    specfem_source_name = 'sources.dat'

    specfem_source_file = open(specfem_source_name, "w")
    for iproc in range (0,NSRC):
      xs=xs0+iproc*dxs
      zs=zs0+iproc*dzs
     # print ' %d\t%f\t%f\n'%(iproc,xs,zs)
      specfem_source_file.write("%f\t%f\n" % (xs,zs))

    specfem_source_file.close()
########################################################################33
def create_linear_station(NREC,xr0,dxr,zr0,dzr):
    """ 
     to create linear station list with fixed space
     # NREC -- total # of stations
     # xr0 -- first station coordinate in x 
     # dxr -- space in x 
     # zr0 -- first station coordinate in z 
     # dzr -- space in z 
    """
    specfem_station_name = 'STATIONS'

    specfem_station_file = open(specfem_station_name, "w")
    for ir in range (0,NREC):
      xr=xr0+ir*dxr
      zr=zr0+ir*dzr
      Elevation=0
      Burial=0
     # print ' %d\t%f\t%f\n'%(iproc,xs,zs)
      specfem_station_file.write("S%04d\tAA\t%f\t%f\t%f\t%f\n"
                                   % (ir+1,xr,zr,Elevation, Burial))


    specfem_station_file.close()
###############################################################################
###############################################################################
def main():
    """
    """
    print " This is to generate equally spaced source list ..."
    NSRC=int(raw_input('Total number of sources in a line: '))
    xs0 = float(raw_input('starting coordinate in x: '))
    xs1 = float(raw_input('ending coordinate in x: '))
    zs0 = float(raw_input('starting coordinate in z: '))
    zs1 = float(raw_input('ending coordinate in z: '))
    if (NSRC>1):
        dxs=(xs1-xs0)/(NSRC-1)
        dzs=(zs1-zs0)/(NSRC-1)
    else:
        NSRC=1
        dxs=0.0
        dzs=0.0

    create_linear_source(NSRC,xs0,dxs,zs0,dzs)

    print " This is to generate equally spaced station list ..."
    NREC=int(raw_input('Total number of stations in a line: '))
    xr0 = float(raw_input('starting coordinate in x: '))
    xr1 = float(raw_input('ending coordinate in x: '))
    zr0 = float(raw_input('starting coordinate in z: '))
    zr1 = float(raw_input('ending coordinate in z: '))
    if (NREC>1):
        dxr=(xr1-xr0)/(NREC-1)
        dzr=(zr1-zr0)/(NREC-1) 
    else:
        NREC=1
        dxr=0.0
        dzr=0.0


    create_linear_station(NREC,xr0,dxr,zr0,dzr)


if __name__ == "__main__":
    main()



