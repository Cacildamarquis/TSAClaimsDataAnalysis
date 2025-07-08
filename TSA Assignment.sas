LIBNAME TSA "/home/u64100426/TSA";

PROC IMPORT datafile="/home/u64100426/ECRB94/data/TSAClaims2002_2017.csv" 
		DBMS=csv OUT=TSA.claims_cleaned replace;
	GUESSINGROWS=MAX;
	GETNAMES=YES;
RUN;

DATA claims_cleaned1;
	SET tsa.claims_cleaned;
	LENGTH Date_Issues $12;
	LABEL Airport_Code="Airport Code" Airport_Name="Airport Name" 
		Claim_Number="Claim Number" Claim_Site="Claim Site" Claim_Type="Claim Type" 
		Close_Amount="Close Amount" Date_Received="Date Received" 
		Item_Category="Item Category" Date_Issues="Date Issues";

	IF Claim_Type="." OR Claim_Type="" or Claim_Type=" " or Claim_Type="-" THEN
		Claim_Type='Unknown';

	IF Claim_Site="." OR Claim_Site="" or Claim_Site=" " OR Claim_Site="-" THEN
		Claim_Site='Unknown';

	IF Disposition="." OR Disposition="" or Disposition=" " OR Disposition="-" THEN
		Disposition='Unknown';

	IF index(Claim_Type, "/") >0 then
		Claim_Type=scan(Claim_Type, 1, "/");

	IF Claim_Type not in ('Bus Terminal', 'Complaint', 'Compliment', 
		'Employee Loss (MPCECA)', 'Missed Flight', 'Motor Vehicle', 'Not Provided', 
		'Passenger Property Loss', 'Passenger Theft', 'Personal Injury', 
		'Property Damage', 'Property Loss', 'Unknown', 'Wrongful Death') THEN
			Claim_Type='MOW';

	IF Claim_Site not in ('Bus Station', 'Checked Baggage', 'Checkpoint', 
		'Motor Vehicle', 'Not Provided', 'Other', 'Pre-Check', 'Unknown') THEN
			Claim_Site='MOW';

	IF Disposition="Closed:Canceled" THEN
		Disposition="Closed: Canceled";

	IF Disposition="losed: Contractor Claim" THEN
		Disposition="Closed:Contractor Claim";
	STATENAME=PROPCASE(STATENAME);
	STATE=UPCASE(STATE);
RUN;

PROC SORT data=claims_cleaned1 noduprecs;
	by _all_;
RUN;

PROC FREQ data=claims_cleaned1;
	table Claim_Type Claim_Site Disposition;
RUN;

DATA claims_cleaned2;
	SET claims_cleaned1;
	Date_Issues=' ';

	IF Incident_Date>Date_Received THEN
		Date_Issues='Needs Review';
	Else IF missing(Incident_Date) THEN
		Date_Issues='Needs Review';
	ELSE IF missing(Date_Received) THEN
		Date_Issues='Needs Review';
	ELSE IF (Incident_Date<'01jan2002'd or Incident_Date> '31dec2017'd) THEN
		Date_Issues='Needs Review';
	ELSE IF (Date_Received<'01jan2002'd or Date_Received>'31dec2017'd) THEN
		Date_Issues='Needs Review';
	FORMAT Incident_Date Date_Received DATE9. CLOSE_AMOUNT DOLLAR8.2;
	DROP County City;
RUN;

PROC SORT data=claims_cleaned2;
	by Incident_Date;
RUN;

PROC FREQ DATA=claims_cleaned2;
	table state;
RUN;

ODS PDF FILE="/home/u64100426/TSA/ClaimReports.pdf" style=sasdocprinter;
options noproctitle;
ods pdf startpage=yes;
title "Total number of date issues";

PROC FREQ DATA=claims_cleaned2;
	tables Date_Issues/ nocol norow nopercent;
RUN;

data claims_cleaned3;
	set claims_cleaned2;
	where Date_Issues ne 'Needs Review';
RUN;

ods pdf startpage=yes;
title "Claims per year of Incident_Date";

PROC FREQ DATA=claims_cleaned3;
	tables Incident_Date/ nocol norow nopercent plots=freqplot;
	FORMAT Incident_Date year4.;
RUN;

%macro run_state_freq(state=);
	PROC SORT data=claims_cleaned3;
		by State;
	RUN;

	ods pdf startpage=yes;

	PROC FREQ DATA=claims_cleaned3;
		TABLES Claim_Type Claim_Site Disposition/ nocol norow nopercent nocum;
		where state="&state";
		title "Freq distribution of &state";
	RUN;

	ods pdf startpage=yes;

	PROC MEANS DATA=claims_cleaned3 mean min max sum MAXDEC=0;
		VAR Close_Amount;
		where state="&state";
		title "Close amount summary";
		OUTPUT;
	RUN;

%mend run_state_freq;

%run_state_freq(state=HI);
ods exclude none;
ods pdf close;