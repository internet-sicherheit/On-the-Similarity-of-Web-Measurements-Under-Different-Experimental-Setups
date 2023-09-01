# Complete Data Processing and Evaluation Pipeline

The table below provides an overview of each file in this folder, its purpose, and its categorization. 
These SQLs are used to process the data and generate the results for the paper.

File | Category | Description | 
--- | --- | ---
1. main data process.sql | Data pre- and postprocessing | Here we create the tree structure for the requests
2. single main operations.sql | Data pre- and postprocessing | Here we do the main data postprocessing operations (e.g. assigning tracking requests, defining scope, rank buckets etc.)
e1. general overview.sql | evaluation | This is the SQL used to generate the results for the general overview section of the paper.
e10. DNS.sql | evaluation | This is SQL used to generate results for DNS analysis
e11. tracking request.sql | evaluation | This SQL is used to generate the results for tracking requests.
e12. sim by rank.sql | evaluation | This is the SQL used to generate results for similarity of the nodes by rank.
e13. cookies.sql | evaluation | This is the SQL used to generate results for Implications on Cookies.
e2. sim of nodes depth.sql | evaluation | This is the SQL used to generate the results for similarity of the nodes by depth.
e3. request chain.sql | evaluation | This is the SQL used to generate the results for dependency of the nodes (request chain).
e4. first and third party.sql | evaluation | This is the SQL used to generate the results for first and third party nodes.
e5. sim1 vs. sim2.sql | evaluation | This is the SQL used to generate the results when comparing sim1 vs. sim2.
e6 sim1 vs old1.sql | evaluation | This is the SQL used to generate the results when comparing profile Sim1 vs Old1.
e7. sim1 vs. NoAction.sql | evaluation | This is the SQL used to generate the results when comparing profile Sim1 vs. Noaction.
e8. Headless vs. Sim1.sql | evaluation | This is the SQL used to generate the results when comparing profile Headless vs Sim1.
e9. uniq nodes.sql | evaluation | This is the SQL used to generate the results for unique nodes (Case Study).
eval 1 tree_by_parent.sql | Create the trees | This is SQL used to create the trees by parent(table tree_by_parent). This table contains all requests of a visit and their parent-child relationships.
eval 2 tree_eval_url.sql | Create the trees | This SQL is used to create the trees by URL (table tree_eval_url)
eval 3 tree_by_chain.sql | Create the trees | This SQL is used to create the trees by request chain (table tree_by_chain). It is one of the main tables used in the evaluation.
eval 4 tree_distinct_cookies.sql | Create the trees | This SQL is used to create a table that contains only the cookies that are in scope.
eval 5 tree_cookies_visit.sql | Create the trees | This is SQL used to evaluate similarity of the cookies on webpage level.
eval 6 tree_cookies_site.sql | Create the trees | This is SQL used to evaluate similarity of the cookies on site level.
functions.sql | Functional | This SQL contains SQL functions used in Bigquery.
plots.sql | Plots | This SQL is used to generate the results for plots used in the paper.
statistics.sql | Statistics | This SQL is used to generate the results for statistical analysis used in the paper.
tables.sql | Tables | This is SQL used to generate the results for the tables used in the paper.
