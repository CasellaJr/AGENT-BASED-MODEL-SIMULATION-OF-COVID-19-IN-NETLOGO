# AGENT-BASED-MODEL-SIMULATION-OF-COVID-19-IN-NETLOGO
AGENT-BASED MODEL SIMULATION OF COVID-19 IN NETLOGO

## Description

Inspired in the COVID-19 pandemic, this simplified model simulates the transmission and perpetuation of a virus in a human population. The model is initialized with 720 people, of which only 1 is infected. People move randomly about the world in one of the following states: not infected (blue), infected (yellow), immune (green). People may die (red) of infection. Upon setup, population is assigned a random age. Elders (those older than 60 years old) have a different risk to die from the disease.

## Usage
Each “tick” represents a day in the time scale of this model.
The recoverProbability slider controls the likelihood that an infection will end in recovery/immunity.
The deathProbability slider controls the likelihood that an infection will end in death.
The awarenessProbability slider controls the likelihood that an agent knows its own state.
The numberAgents slider controls the number of agents involved in the simulation.
The connections switch controls the possibility of drawing links among the infected.
The Setup button resets the graphics and plots and randomly distributes numberAgents in the view. The GO button starts the simulation and the plotting function.
An output monitor plots the number of agents that are infected, the number of agents that are immune, and the number of agents that are dead.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)

## Contacts
Bruno Casella - casella0798@gmail.com

https://colab.research.google.com/drive/1o4n2joJGmPYtKYu19ZY3mchgGroqWu0n?usp=sharing
