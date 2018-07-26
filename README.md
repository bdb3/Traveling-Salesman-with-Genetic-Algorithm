# Traveling-Salesman-with-Genetic-Algorithm
This project is a NetLogo model that finds shortest path between nodes using a GA to determine the best path.
Below are screenshots of the model in action. The model is initiated as a set of nodes, the amount of which is determined by the initial_node slider.
Potential paths between these nodes are saved as lists, and each list of paths is considered an individual in the population. As each generation
passes these paths are mutated with differing functions, shown below, and the algorithm trys to achieve the shortest path over multiple iterations. 
<br />
In the screenshot is also an on/off switch for Fitness Uniform Selection Scheme (FUSS). This is a way to maintain more consistent diversity as described in the following paper...
<br />
http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.413.7546&rep=rep1&type=pdf
<br />
![alt text](https://i.imgur.com/mWguhNl.jpg)
<br />

This screenshot shows the Fitness and Diversity graphs, the mutation sliders,  and the sliders for the initial values used when setting up the population. Each mutation slider represents a mutation that the
direction sets will go through. The higher the slider, the more likely that that particular mutation will be chosen on each generation.
<br />
![alt text](https://i.imgur.com/KrRo2gc.jpg)


Made in NetLogo 6.0.2. 
