#### Project 2 - **Extract Transform Load**

<table><tr><td align="center"><img src="Images/ETL_img_sm.jpg" width="100%"></tr></td></table>

## Repository Files and Folders:
*  [Resources](/Resources) : 
    * [Images](/Resources/Images)  
    * [Schema](/Resources/Schema)  
    * [Source Data](/Resources/Source_Data)
    * [Transformed Data](/Resources/Transformed_Data)
    * [Bonus Read FromDB Examples](/Resources/Bonus_ReadFromDBExamples)
* [Jupyter Notebook  'ETl_Code.ipynb']('ETl_Code.ipynb') has all the cleaning code 
* [Group Project Detailed Report]('Group-Project-2-Detailed-Report.docx')

## Project Description 
In 2020-2021, the most important global issue has been the COVID19 pandemic. Health professionals and researchers around the world have been working hard to make available, the data related to cases, testing, and mortality. We are utilizing publically available Covid19 data for our ETL project. 

**At the end of ETL process, the prepared data would have answered these questions and more:**
 * "Total reported cases" and "Total reported deaths" per county, state 
 * New cases and new deaths
 * Case Fatality Rate (No. of confirmed positive cases vs no of deaths)
 * Covid Mortality Rate (No. of confirmed positive cases vs no of covid deaths)
 * Positive Cases per capita
 * Flu cases as compared to Covid cases

**Future Analysis Ideas**

Have the births increased or decreased duing the time of Covid <br />
Case positivity Rate <br />
Comparision of covid with other seasonal viruses <br />
Effects of covid on hospital and ER visits for non covid related heath issues <br />
Effects of covid on on going treatments for chronic illnesses <br />
Effect of covid on mental health <br />

**Brief introduction to ETL** 

We are living in a world of data. The volume of data that is being generated and collected continues to increase at an exponential rate.
As the amount of data grows, the importance of making use of that data grows as well. This data is immensely valuable for analytics, data science, and machine learning, not only to present valuable information and noticeable trends but also to derive business insights and predictions.
The data that is being captured and stored cannot be used in its raw form. Processing the raw, messy data into clean, consistent and reliable data is a critical step before it can be used.

ETL, which stands for Extract, Transform, and Load, is the process to
* Extract data from various sources 
* Transform the data into a clean, usable format
* Load the data into target database systems that end-users can access and use for further analysis, to make business decisions and, to solve problems.

**How ETL works** : Lets understand each step of the ETL process and how it relates to our project

## Extract : 
Raw data is extracted from various data sources, which can be structured or non structured. These sources can include but are not limited to:

* APIs, JSON, CSV, XML files
* RDBMS(MS SQl Server, MySql etc.) or NoSQL servers (MongoDB etc.)
* CRM (Salesforce Sales Cloud, Quickbase etc.) and ERP systems(Katana, Oracle NetSuite etc)
* Web pages

## How data was 'Extract'ed in our project:
**Data Sources :**
* Covid 19 Data raw feed : https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv
    * New York Times has collected a large amount of COVID19 data for the United States, and they have made this data publically available. We are connecting and extracting data by connecting to their raw feed.    
* Census Data : https://www2.census.gov/programs-surveys/popest/datasets/2010-2020/counties/totals/
* State FIPS :  https://www.census.gov/library/reference/code-lists/ansi/ansi-codes-for-states.html
* County FIPS : https://www.nrcs.usda.gov/wps/portal/nrcs/detail/national/home/cid=nrcs143_013697
* Flu data for Comparision: https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html

## Transform : 
The second step consists of transforming the raw data that has been extracted from the above-mentioned sources into a format that can be used by different applications.
This can be compared to a staging area where the data gets cleansed, mapped, and transformed, often to a specific schema, so it meets operational requirements. 
This process can involve any of these methods:

* Formatting the data into tables or joined tables
* Performing calculations or summarizations 
* Converting data to correct data types
* Deduplication
* Conducting tests/audits to ensure data quality and compliance
* Encrypting, or protecting data governed by industry standards or government regulations


### How data was 'Transform'ed in our project:
* After studying the raw data and identifying the columns from each table, created an Entity Relationship Diagram (ERD) to view a snap shot before rearranging data into required schema <br />

    * <table><tr><td align="center"><img src="Images/ERD_Vrsn3.jpg"></tr></td></table>
* We identified, cleaned, formatted and redistributed the data that we gathered from multiple datasets in to the new PostgreSQL database, making sure it was executed in a sequence that data is loaded into relational tables accurately.

**Table 1 : US_States**
* Read from source to Pandas Dataframe
* Trimmed Leading and Trailing Spaces
* Made sure There were no duplicates
* Identified 'State_Fips' as primary key
* Wrote to US_States.csv that can be imported in PostgreSQL

<details>
<summary><strong>Click to see code!</strong></summary>

```python
    states_df =  pd.read_csv('Resources/Source_Data/US_States.csv')
    states_df

    #Trim leading and trailing spaces for string type data
    sdf_obj = states_df.select_dtypes(['object'])
    states_df[sdf_obj.columns] = sdf_obj.apply(lambda x: x.str.strip()) 

    # Check for duplicates 
    # checking total States_Fips vs. total unique States_Fips. 
    # If they are equal, then there are no duplicates
    States_Fips_List = states_df['State_Fips']
    States_Table_Count = States_Fips_List.count()
    Unique_States_Count = States_Fips_List.nunique()
    print (States_Table_Count, Unique_States_Count)

    # State Table is clean. No duplicate FIPS exist. 
    # This table is ready for PostgreSQL Table

        
    # Write to US_States.csv that can be imported in PostgreSQL
    states_df.to_csv('Resources/Transformed_Data/Us_States.csv', index=False)


```
</details>

<br />

**Table 2 : US_Counties**
* Read from source to Pandas Dataframe
* Trimmed Leading and Trailing Spaces
* Made sure There were no duplicates
* Assigned State_Fips to each record by merging with States Dataframe using state abbeviation to compare
* To handle the issue of incoming data from sources with unknown counties but known States, created a unique code based on the state_fips and assigned StateName as county Name. This observation came from US Census Data Table from where we used the same process for our county table.
* created a new dataframe with 'County_Fips','County','State_Fips' columns
* Identified 'County_Fips' as primary key
* Identified 'State_Fips' as foreign key
* Wrote to Us_Counties.csv that can be imported in PostgreSQL

<details>
<summary><strong>Click to see code!</strong></summary>

```python
    counties_df = pd.read_csv('Resources/Source_Data/US_Counties.csv', encoding='latin-1')

    # counties are uniquly identified by County_FIPS which is a unique ID 
    # called Federal Information Processing Standards
    # Check for duplicates 
    # I am checking total County_Fips vs. total unique County_Fips. 
    # If they are equal, then there are no duplicates
    County_Fips_List = counties_df['County_Fips']
    County_Table_Count = County_Fips_List.count()
    Unique_Counties_Count = County_Fips_List.nunique()
    print (County_Table_Count, Unique_Counties_Count)


    # County Table is Clean. No Nulls, no duplicate FIPS exist
    #Trim leading and trailing spaces for string type data
    df_obj = counties_df.select_dtypes(['object'])
    counties_df[df_obj.columns] = df_obj.apply(lambda x: x.str.strip()) 

    # Merge County table with state 
    county_table = counties_df.merge(states_df, how='left', left_on='State', right_on='Sabbr')
    county_table = county_table[['County_Fips', 'County', 'State_Fips']]
    county_table['County'] = county_table['County'].str.title()


    df_obj = county_table.select_dtypes(['object'])
    county_table[df_obj.columns] = df_obj.apply(lambda x: x.str.strip()) 
    county_table_strip = county_table
    county_table_strip

    # This table is ready for PostGressql
    county_table_strip
    # LOAD Us_Counties.csv

    # Write to Us_Counties.csv that can be imported in PostgreSQL
    county_table_strip.to_csv('Resources/Transformed_Data/Us_Counties.csv', index=False)


```
</details>

<br />

**Table 3 : US_Covid_Data**
* This was the data that required most transformation
* Read from source raw feed to Pandas Dataframe 
* Checked for Nulls in any columns
* If there are records that have a valid state but an unknown county, kept the records and assigned the fips_county for these records (with the special id's mentioned above in the county table)
    * column 'deaths' can contain Nulls but not Fips 
    * Identified these records that has Fips as Null
* moved them to a seperate Dataframe    
* Trimmed Leading and Trailing Spaces for required fields
* Merged with county table and assigned the County_Fips
* Created a dataframe for records with No Nulls
* Concatenated the clean dataframes
* Replaced Null with zeros for column 'Deaths'
* Converted fips and deaths columns to Int
* selected fields 'date', 'county_fips', 'cases', 'deaths' to final dataframe
* Wrote the final dataframe to US_Covid_Data.csv that can be imported in PostgreSQL

<details>
<summary><strong>Click to see code!</strong></summary>

```python
    
    # This will connect to the raw file on their website to get yo to date data
    covid_df = pd.read_csv('https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv', parse_dates=['date'])
    #if we are reading it form the raw file from the source, we can write it to csv if we choose to save it locally
    #covid_df.to_csv('Resources/Source_Data/US_Covid_Data.csv', index=False)
    print(covid_df)

    # Check for Nulls in any colums
    covid_df.isna().any()
    # column 'deaths' can contain Nulls but not Fips 
    # Identify these records for cleaning

    # if (covid_df['fips'].isnull().values.any()):
    #     print(covid_df[covid_df['fips'].isna()])

    covid_df['fips'].isnull().values.any()

    # If covid table has records that have state but an unknown county, we keep the data
    na_covid_df = covid_df[covid_df['fips'].isna()]
    
    # stripping 'state' column of any leading and trailing spaces

    #na_covid_df['state'] = na_covid_df['state'].str.strip()
    na_covid_df['state'].apply(lambda x: x.strip()) 
    #na_covid_df

    na_covid_df = na_covid_df.merge(county_table_strip, how="left", left_on = "state", right_on="County")
    

    na_covid_df_final = na_covid_df[['date', 'county', 'state', 'County_Fips', 'cases', 'deaths']]
    na_covid_df_final

    # Records with Null Fips have been cleaned and fips from cencus table for --
    # -- state_unknown counties have been used
    # Renaming the column to match Us_Covid_Table

    na_covid_df_final = na_covid_df_final.rename(columns = {'County_Fips':'county_fips'})
    na_covid_df_final

    na_covid_df_final['county_fips'].isnull().values.any()
    # Non Null Covid Data
    non_na_covid_df = covid_df[covid_df['fips'].notna()]  
    non_na_covid_df

    non_na_covid_df = non_na_covid_df.rename(columns = {'fips':'county_fips'})
    non_na_covid_df
    # Concatenate the clean dataframes
    vertical_stack = pd. concat([na_covid_df_final, non_na_covid_df], axis=0) 
    vertical_stack.isnull().any()
    vertical_stack['deaths'] = vertical_stack['deaths'].fillna(0)
    # Converting fips columns to Int
    vertical_stack.county_fips = vertical_stack.county_fips.astype(int)
    vertical_stack.deaths = vertical_stack.deaths.astype(int)


    us_covid_table = vertical_stack[['date', 'county_fips', 'cases', 'deaths']]
    #us_covid_table = us_covid_table.sort_values(by='date', ascending=False)
    us_covid_table

    # This table is ready for Loading
    # LOAD US_Covid_Data.csv

    # Write to US_Covid_Data.csv that can be imported in PostgreSQL
    us_covid_table.to_csv('Resources/Transformed_Data/US_Covid_Data.csv', index=False)


```
</details>

<br />

**Table 4 : Us_Census_Data**
* Read from source to Pandas Dataframe
* The original table had 150+ columns
* Removed records with for State Totals as they are reduntant
* state totals can be calculated from county information
* Created Fips_County Field using State and County Fields that were both stored seperately as integers 
    * converted state and county fields from int to str
    * added leading zeros to State and County get the format required for fips_county
    * concatenated state and county to make County_Fips Code that follows the Fips_County format
* created final dataframe with selected fields   
    * 'fips','POPESTIMATE2016','POPESTIMATE2017','POPESTIMATE2018','POPESTIMATE2019',
    'POPESTIMATE2020', 'BIRTHS2016','BIRTHS2017','BIRTHS2018','BIRTHS2019','BIRTHS2020',
    'DEATHS2016','DEATHS2017','DEATHS2018','DEATHS2019','DEATHS2020'
* Wrote to US_Census_Data.csv that can be imported in PostgreSQL

<details>
<summary><strong>Click to see code!</strong></summary>

```python
    population_data = pd.read_csv('Resources/Source_Data/US_Census_Data_2020.csv', encoding='latin-1')
    # population_data.loc[population_data['STNAME'] == population_data['CTYNAME']]
    # County = 0 are records for State Totals
    # removed these because state totals can be calculated from county information
    population_data = population_data.loc[population_data['COUNTY'] > 0]

    # converted state and county fields from int to str
    population_data['STATE'] = population_data['STATE'].astype('str')
    population_data['COUNTY'] = population_data['COUNTY'].astype('str')

    # filled with leading zeros to get the format required for fips_county
    population_data['STATE']=population_data['STATE'].apply(lambda x: x.zfill(2))
    population_data['COUNTY']=population_data['COUNTY'].apply(lambda x: x.zfill(3))

    # concatenated state and county fips to make a County_Fips Code that follows the Fips_County convention
    population_data['fips'] = population_data['STATE'] + population_data['COUNTY']
    # population_data['fips'] 
    population_data


    population_data = population_data[['fips','POPESTIMATE2016','POPESTIMATE2017','POPESTIMATE2018','POPESTIMATE2019',
    'POPESTIMATE2020', 'BIRTHS2016','BIRTHS2017','BIRTHS2018','BIRTHS2019','BIRTHS2020',
    'DEATHS2016','DEATHS2017','DEATHS2018','DEATHS2019','DEATHS2020']]
    population_data
    # Table is ready to load

    # LOAD US_Census_Data.csv

    # Write to US_Census_Data.csv that can be imported in PostgreSQL
    population_data.to_csv('Resources/Transformed_Data/US_Census_Data.csv', index=False)


```
</details>

<br />

**Table 5 : WHO_Flu_Data**
* Read from source to Pandas Dataframe
* Dropped a column not required
* Records with missing data came in with 'X' instead of Null. Replaced 'X' with -1 as they were nummeric fields in destination table.
* Trimmed leading/trailing spaces for columns that are used in join conditions for merging dataframes
* Added State_Fips 
    * 'State_Fips','YEAR','WEEK','TOTAL SPECIMENS','TOTAL A','TOTAL B','PERCENT POSITIVE',
    'PERCENT A','PERCENT B'
* Wrote to WHO_Flu_Data.csv that can be imported in PostgreSQL

<details>
<summary><strong>Click to see code!</strong></summary>

```python
    who_flu_df = pd.read_csv('Resources/Source_Data/WHO_NREVSS_Clinical_Labs.csv')
    #who_flu_df

    # Drop Region Type
    who_flu_df.drop(columns=['REGION TYPE'], inplace=True) 

    # Replace 'X' with -1
    who_flu_df.loc[who_flu_df['REGION'] == 'New York City', 'REGION'] = 'New York'
    who_flu_df.loc[who_flu_df['TOTAL SPECIMENS'] == 'X', 'TOTAL SPECIMENS'] = -1
    who_flu_df.loc[who_flu_df['TOTAL A'] == 'X', 'TOTAL A'] = -1
    who_flu_df.loc[who_flu_df['TOTAL B'] == 'X', 'TOTAL B'] = -1
    who_flu_df.loc[who_flu_df['PERCENT POSITIVE'] == 'X', 'PERCENT POSITIVE'] = -1
    who_flu_df.loc[who_flu_df['PERCENT A'] == 'X', 'PERCENT A'] = -1
    who_flu_df.loc[who_flu_df['PERCENT B'] == 'X', 'PERCENT B'] = -1
    who_flu_df

    # Add State_Fips and Remove Region
    # Strip spaced
    who_flu_df['REGION'].apply(lambda x: x.strip()) 

    # Merge with US_States
    who_flu_table = who_flu_df.merge(states_df, how='left', left_on='REGION', right_on='Sname')
    who_flu_table = who_flu_table[['State_Fips','YEAR','WEEK','TOTAL SPECIMENS','TOTAL A','TOTAL B','PERCENT POSITIVE',
    'PERCENT A','PERCENT B']]
    who_flu_table
    # Table is ready to load
    # LOAD WHO_Flu_Data.csv
    # Write to WHO_Flu_Data.csv that can be imported in PostgreSQL
    who_flu_table.to_csv('Resources/Transformed_Data/WHO_Flu_Data.csv', index=False)


```
</details>

<br />

## Load : 
This last step involves moving the transformed data to a target data warehouse. Initially, the final data is loaded once, and thereafter periodic loading of data happens to keep the database up to date. Most of the time the ETL process is automated and batch-driven. Typically, ETL is scheduled to trigger during off-hours when traffic on the source systems and the destination systems is at its lowest.

## How data was 'Load'ed  in our project:
* RDBMS Used : PostgreSQL
* Created a PostgreSQL database 'ETL'
    <table><tr><td align="center" width="80%"><img src="Images/Load_Process_Images/db_ETL_create_1.jpg"></tr></td></table>
* Followed ERD created earlier, developed SQL DDL queries with correct data types, primary keys, foreign keys, and other constraints
* Created tables making sure they were created in correct order to handle foreign keys.

<details>
<summary><strong>Click to see code!</strong></summary>

    Drop table if exists US_States cascade;
    CREATE TABLE US_States (
        State_Fips int   NOT NULL,
        Sabbr char(2)   NOT NULL,
        Sname varchar(356)   NOT NULL,
        PRIMARY KEY (State_Fips)
    );

    Drop table if exists US_Counties cascade;
    CREATE TABLE US_Counties (
        County_Fips int   NOT NULL,
        County varchar(356)   NOT NULL,
        State_Fips int   NOT NULL,
        PRIMARY KEY (County_Fips),
        FOREIGN KEY(State_Fips) REFERENCES US_States (State_Fips)
    );

    Drop table if exists US_Covid_Data cascade;
    CREATE TABLE US_Covid_Data (
        Case_ID Serial   NOT NULL,
        CDate date   NOT NULL,
        County_Fips int   NOT NULL,
        No_Of_Cases int   NOT NULL,
        No_Of_Deaths int   NOT NULL,
        PRIMARY KEY (Case_ID),
        FOREIGN KEY(County_Fips) REFERENCES US_Counties (County_Fips) 
    );

    Drop table if exists US_Census_Data cascade;
    CREATE TABLE US_Census_Data (
        ID Serial   NOT NULL,
        County_Fips int   NOT NULL,
        Population_2016 int   NOT NULL,
        Population_2017 int   NOT NULL,
        Population_2018 int   NOT NULL,
        Population_2019 int   NOT NULL,
        Population_2020 int   NOT NULL,
        Births_2016 int   NOT NULL,
        Births_2017 int   NOT NULL,
        Births_2018 int   NOT NULL,
        Births_2019 int   NOT NULL,
        Births_2020 int   NOT NULL,
        Deaths_2016 int   NOT NULL,
        Deaths_2017 int   NOT NULL,
        Deaths_2018 int   NOT NULL,
        Deaths_2019 int   NOT NULL,
        Deaths_2020 int   NOT NULL,
        PRIMARY KEY (ID),
        FOREIGN KEY(County_Fips) REFERENCES US_Counties (County_Fips)
    );


    Drop table if exists WHO_Flu_Data cascade;
    CREATE TABLE WHO_Flu_Data (
        Case_ID Serial   NOT NULL,
        State_Fips int   NOT NULL,
        Year int   NOT NULL,
        Week int   NOT NULL,
        Total_Specimens int   NOT NULL,
        Total_A int   NOT NULL,
        Total_B int  NOT NULL,
        Percent_Positive decimal   NOT NULL,
        Percent_A decimal   NOT NULL,
        Percent_B decimal   NOT NULL,
        PRIMARY KEY (Case_ID),
        FOREIGN KEY(State_Fips) REFERENCES US_States (State_Fips)
    );


</details>

* Executed these queries on pgAdmin to create tables
    * <table><tr><td align="center"  width="80%"><img src="Images/Load_Process_Images/db_ETL_execute_schema.jpg"></tr></td></table>

* Imported each CSV file into the corresponding SQL table making sure data is imported in the same order that the tables were created and account for the headers when importing to avoid errors.
    * <table><tr><td align="center"  width="80%"><img src="Images/Load_Process_Images/db_ETL_load_transformed_data_1_2.jpg"></tr></td></table>

* Created a view with most used tables for easy querying of data
    * <table><tr><td align="center"  width="80%"><img src="Images/Load_Process_Images/view.jpg"></tr></td></table>

* Examples of some queries we executed to test Data:
* Latest Covid19 numbers for All States 
    * <table><tr><td align="center"  width="80%"><img src="Images/Load_Process_Images/Qry1.jpg"></tr></td></table>   
* Latest Covid19 numbers for the  of California per county      
    * <table><tr><td align="center"  width="80%"><img src="Images/Load_Process_Images/Qry2.jpg"></tr></td></table>       



