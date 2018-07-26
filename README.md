# Traveling-Salesman-with-Genetic-Algorithm

This folder contains a .nlogo file and supporting .nls files.  Made in NetLogo 6.0.2. /n
Below are screenshots of the model in action. The main model is a set of nodes, the amount of which is determined by the initial_node slider.
Potential paths between these nodes are saved as lists, and each list of paths is considered an individual in the population. As each generation
passes these paths are mutated with differing functions, shown below, and the algorithm trys to achieve the shortest path over multiple iterations. 
![alt text](https://i.imgur.com/mWguhNl.jpg)

This screenshot shows the Fitness and Diversity graphs, as well as the mutation sliders. Each slider represents a mutation that the
direction sets will go through. The higher the slider, the more likely that that particular mutation will be chosen on each generation.

![alt text](https://i.imgur.com/KrRo2gc.jpg)
