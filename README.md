# ImageProcessingWithCliqueTop
Application of Clique-Top library to the images.

## The procedure
The "image_processing.m" file contains script to load an image (one of the two present in the repo), convert it to grayscale, 
reduce the image size 6 times (arbitrarly chosen number). Then thresholding and binarization is applied to the image- pixels 
which values are within the thresholds are converted to max grayscale values, other pixels are converted to minimal values.
The maximal-value pixels are treated then as set of point cloud and the Euclidean distance between them is evaluated. After
that, betti curves are computed for symetric matrix (which is result of distance computation) using the cliquetop library.
This procedure is based on the [1].

## The "clique_top_testin.m"
This script loads symetric matrices of random, geometric and shuffeled form, and then betti curves are computed.

# Reference
[1] T. Kaczynski, K. Mischaikow, and M. Mrozek, Computational homology. Pages:268-269
