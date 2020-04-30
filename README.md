CovidModelling
Script for COVID-19 model optimisation for matlab



Usage:
Change "Country" and "Province" in main.m according available values from ISO_Table.csv 

Choose algorithm on which you want to run it

    Available algorithms:

- lsqnonlin
- patternsearch
- fminunc
- fminsearch
- fmincon
- ga
- pso (first you need you download psopt toolbox and place it in +optim folder)

If you need to change algorithm options, you can do so in according section in algorithm.m


