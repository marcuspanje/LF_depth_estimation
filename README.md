#Light Field Depth Estimation Using Optical Flow

This code estimates depth from a light field image.
Supported light field formats are .png outputs from Lytro's .lfr raw image, and a 5D image in MATLAB's .mat format from the [dataset](http://hci-lightfield.iwr.uni-heidelberg.de/)
 by HCI and the University of Konstanz.

The top-level script to run in MATLAB is: ```estimate_depth.m```
Additional parameters can be found in
```compute_of```
```run_admm_vec```
```plotter```


