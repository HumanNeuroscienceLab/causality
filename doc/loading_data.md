# Loading Simulations

All the data are located in the `data/netsim` directory. For each simulation, there three routes to loading the same data:

* Load the `sim*.rda` file with the `load_rda` function in `lib/utils.R`. The R function loads all the data into a list with the elements: `nsubs`, `nnodes`, `ntpts`, `ts`, and `net`. The first three are just integers while the last two (ts and net) are arrays of # of subject x # of time-points x # of nodes for `ts` and # of subject x # of nodes x # of nodes for `net`. The `ts` object is basically the simulated time-series for each node for each subject, while the `net` array is the ground truth for the connections between regions.
* Or you can load the `sim*_ts.csv` and `sim*_net.csv`, which are the same thing as above but in dataframe form.
* You can load the time-series and ground-truth data for each subject separately if you want and these are located in the `sim*` directories. Each directory includes two files for each subject which are the `net` and `ts` matrices saved as text files.

Note that for the `net` output the direction of the connectivity is the row (ith element) to the column (jth element).

Finally information on each simulation can be found in `data/netsim/sim_specs.csv`. I have also pasted that information below:

Sim	#nodes	  duration (min)	TR (s)	Noise (%)	HRF std. dev. (s)	Other factors
sim num-nodes duration  tr    noise-hrf std   other
1	  5	        10	      3.00	1.0       0.5 
2	  10	      10	      3.00	1.0       0.5 
3	  15	      10	      3.00	1.0       0.5 
4	  50	      10	      3.00	1.0       0.5 
5	  5	        60	      3.00	1.0       0.5 
6	  10	      60	      3.00	1.0       0.5 
7	  5	        250	      3.00	1.0       0.5 
8	  5	        10	      3.00	1.0       0.5   shared inputs
9	  5	        250	      3.00	1.0       0.5   shared inputs
10	5	        10	      3.00	1.0       0.5   global mean confound
11	10	      10	      3.00	1.0       0.5   bad ROIs (timeseries mixed with each other)
12	10	      10	      3.00	1.0       0.5   bad ROIs (new random timeseries mixed in)
13	5	        10	      3.00	1.0       0.5   backwards connections
14	5	        10	      3.00	1.0       0.5   cyclic connections
15	5	        10	      3.00	0.1       0.5   stronger connections
16	5	        10	      3.00	1.0       0.5   more connections
17	10	      10	      3.00	0.1       0.5   
18	5	        10	      3.00	1.0       0.0   
19	5	        10	      0.25	0.1       0.5   neural lag = 100 ms
20	5	        10	      0.25	0.1       0.0   neural lag = 100 ms
21	5	        10	      3.00	1.0       0.5   2-group test
22	5	        10	      3.00	0.1       0.5   nonstationary connection strengths
23	5	        10	      3.00	0.1       0.5   stationary connection strengths
24	5	        10	      3.00	0.1       0.5   only one strong external input
25	5	        5	        3.00	1.0       0.5 
26	5	        2.5	      3.00	1.0       0.5 
27	5	        2.5	      3.00	0.1       0.5 
28	5	        5	        3.00	0.1       0.5 