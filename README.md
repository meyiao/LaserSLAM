# LaserSLAM
SLAM using 2D lidar<br>
![image](https://github.com/meyiao/LaserSlam/blob/master/museum.png)<br>
Video(better watching in 1080p): https://v.qq.com/x/page/q0363h0i1ej.html<br>

## Usage
1. Run the main.m<br>
2. If you'd like to test the loop closure detection(only detection, no pose graph optimization yet) functionality, dequote the 'Loop Closing' codes in the main.m<br>

## To Do
1. Register the laser points in a probability-grid-map, it will help improve the scan-matching performance.[1]<br>
2. Tightly couple the Laser and IMU to improve robustness and efficiency.<br>
3. Estimate relative pose between two consecutive keyscans, estimate the relative pose's covariance following the approach in [1]<br>
4. Use pose graph optimization to close loops.<br>
5. Use branch and bound method to speed up brute force scan matching.<br>
Though it's not so accurate or robust yet, I believe it can have high performance after finishing the tasks in the ToDo list.

## References
[1]W.Hess, D.Kohler, H.Rapp and D.Andor. Real-Time Loop Closure in 2D LIDAR SLAM. ICRA, 2016<br>
