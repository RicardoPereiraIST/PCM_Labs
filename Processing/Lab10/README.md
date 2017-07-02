# PCM exercise 4

1. Perform stroboscopic segmentation. Save the first frame of each video segment as an image file and create a text file where you display the time index of each segment's first frame.

2. Implement transition detection with a parameterisable threshold. To do so, compute histograms and use differences between consecutive frames' histograms (histogram differences or squared histogram differences). Again, save the first frame of each video segment as an image file and create a text file where you display the time index of each segment's first frame.

3. Repeat point 2, but using twin-comparison. Check the handouts in the materials for a quick reference on twin-comparison.

4. Save a text file that lists the histogram differences between consecutive frames of the video and register the thresholds used for transitions detection.
The file should present the list with four columns like this:
     Frame		Histogram_Diff		Threshold1	Threshold2
     (…)

5. Detect transitions using the methods implemented in 2 and 3. Create algorithms to compute suitable thresholds. Think, explore, create and innovate!
