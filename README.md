# RVT

Relief Visualization Toolbox was produced to help scientist visualize raster elevation model datasets. We have narrowed down the selection to include techniques that have proven to be effective for identification of small scale features. Default settings therefore assume working with high resolution digital elevation models, derived from airborne laser scanning missions (lidar).

Despite this, techniques are also used for different other purposes. Sky-view factor, for example, can be efficiently used in numerous studies where digital elevation model visualizations and automatic feature extraction techniques are indispensable, e.g. in geography, geomorphology, cartography, hydrology, glaciology, forestry and disaster management. It can be used even in engineering applications, such as, predicting the availability of the GPS signal in urban areas.

Methods currently implemented are:

*   hillshading,
*   hillshading from multiple directions,
*   PCA of hillshading,
*   slope gradient,
*   simple local relief model,
*   sky illumination,
*   sky-view factor (as developed by our team),
*   anisotropic sky-view factor,
*   positive and negative openness,
*   local dominance.

For a more detailed description see references given at each method in the manual and a comparative paper describing them (e.g. Kokalj et al. 2013, see below).

The tool also supports elevation raster file data conversion. It is possible to convert all frequently used single band raster formats into GeoTIFF, ASCII gridded XYZ, Erdas Imagine file and ENVI file formats.

Development of RVT was part financed by the European Commission's Culture Programme through the ArchaeoLandscapes Europe project.

## Downloads

Relief Visualization Toolbox Standalone version (EXE), Windows 32-bit, version 1.1, no ENVI/IDL installation is required.
Relief Visualization Toolbox manual, version 1.1 (Instructions for use)
Relief Visualization Toolbox Computation code (SAV), version 1.1, for ENVI 5.0. You can also run the computation code with IDL Virtual Machine. You need to copy the GDAL library if you want to process anything other than (geo)TIFF files.

Please report any bugs and suggestions for improvements.

## References

When using the tools, please cite:

*   Zakšek, K., Oštir, K., Kokalj, Ž. 2011. Sky-View Factor as a Relief Visualization Technique. Remote Sensing 3: 398-415.
*   Kokalj, Ž., Zakšek, K., Oštir, K. 2011. Application of Sky-View Factor for the Visualization of Historic Landscape Features in Lidar-Derived Relief Models. Antiquity 85, 327: 263-273.
