TSA Claims Data Analysis (2002–2017)
This project explores and cleans data from the US Transportation Security Administration (TSA) covering claims filed by passengers between 2002 and 2017. The goal is to clean messy text entries, flag suspicious records, analyze patterns, and generate a summary report by state using SAS.

# Files in this Repo
•	TourismCaseStudy_Requirements: Includes the outline for this project, provided by SAS
•	tsa_claims_analysis.sas: The full SAS program with data import, cleaning, transformation, and report generation logic.
•	ClaimReports.pdf: Output report generated via ODS PDF, summarizing data quality issues, yearly trends, and state-specific breakdowns.
•	README.md: This file.

# Objectives
•	Clean and standardize inconsistent or missing values in fields like Claim_Type, Claim_Site, and Disposition.
•	Flag invalid records using custom logic (e.g., date anomalies, missing values).
•	Summarize trends in claim types, sites, and outcomes.
•	Generate reports for specific US states using a macro.

# Tools Used
•	SAS 9.4
•	ODS PDF for report generation
•	PROC IMPORT, DATA step, PROC FREQ, PROC MEANS, macros

# Key Steps
1.	Data Import
Import CSV with PROC IMPORT, guess all rows for accuracy, and save it into a library.
2.	Data Cleaning
Standardize values and fill blanks/missing fields with "Unknown"
Normalize text case (PROPCASE, UPCASE)
Consolidate rare/invalid claim types and sites as "MOW" (miscellaneous or wrong)
3.	Flagging Data Issues
Flag records with date problems (e.g., future incident dates, out-of-range values)
Label suspicious rows as 'Needs Review' in a new Date_Issues column
4.	Filtering and Sorting
Create a clean subset excluding flagged rows
Sort records by date
5.	State-Level Analysis
Use a macro %run_state_freq() to automate report generation for any state (e.g., HI for Hawaii)

# Outputs
•	Total rows with date issues
•	Frequency of claims by year
•	Per-state breakdown of:
Claim Type
Claim Site
Disposition
Total and average close amount

# Example Report Snippets
•	HI (Hawaii):
Most common claim type: Passenger Property Loss
Highest close amount in a single claim: $3500
Total claims after filtering: 48

# How to Run
If you're using SAS OnDemand for Academics:
1.	Upload the TSAClaims2002_2017.csv file to your Files (Home) directory.
2.	Upload and run tsa_claims_analysis.sas.
3.	The output will be saved as ClaimReports.pdf in the same directory.
