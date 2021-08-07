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

Drop table if exists US_Covid_Cases cascade;
CREATE TABLE US_Covid_Cases (
    Case_ID Serial   NOT NULL,
    CDate date   NOT NULL,
    County_Fips int   NOT NULL,
    No_Of_Cases int   NOT NULL,
    No_Of_Deaths int   NOT NULL,
    PRIMARY KEY (Case_ID),
    FOREIGN KEY(County_Fips) REFERENCES US_Counties (County_Fips) 
);

Drop table if exists US_Population_2020_County cascade;
CREATE TABLE US_Population_2020_County (
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
    Percent_Positive int   NOT NULL,
    Percent_A decimal   NOT NULL,
    Percent_B decimal   NOT NULL,
    PRIMARY KEY (Case_ID),
    FOREIGN KEY(State_Fips) REFERENCES US_States (State_Fips)
);