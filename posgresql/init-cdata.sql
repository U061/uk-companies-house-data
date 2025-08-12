CREATE TABLE IF NOT EXISTS cdata (
    companyname VARCHAR(255) NULL,
    companynumber VARCHAR(255) NULL,
    regaddress_careof VARCHAR(255) NULL,
    regaddress_pobox VARCHAR(255) NULL,
    regaddress_addressline1 VARCHAR(255) NULL,
    regaddress_addressline2 VARCHAR(255) NULL,
    regaddress_posttown VARCHAR(255) NULL,
    regaddress_county VARCHAR(255) NULL,
    regaddress_country VARCHAR(255) NULL,
    regaddress_postcode VARCHAR(20) NULL,
    companycategory VARCHAR(255) NULL,
    companystatus VARCHAR(255) NULL,
    countryoforigin VARCHAR(255) NULL,
    dissolutiondate DATE NULL,
    incorporationdate DATE NULL,
    accounts_accountrefday INT NULL,
    accounts_accountrefmonth INT NULL,
    accounts_nextduedate DATE NULL,
    accounts_lastmadeupdate DATE NULL,
    accounts_accountcategory VARCHAR(255) NULL,
    returns_nextduedate DATE NULL,
    returns_lastmadeupdate DATE NULL,
    mortgages_nummortcharges VARCHAR(50) NULL,
    mortgages_nummortoutstanding VARCHAR(50) NULL,
    mortgages_nummortpartsatisfied VARCHAR(50) NULL,
    mortgages_nummortsatisfied VARCHAR(50) NULL,
    siccode_sictext_1 VARCHAR(255) NULL,
    siccode_sictext_2 VARCHAR(255) NULL,
    siccode_sictext_3 VARCHAR(255) NULL,
    siccode_sictext_4 VARCHAR(255) NULL,
    limitedpartnerships_numgenpartners INT NULL,
    limitedpartnerships_numlimpartners INT NULL,
    uri VARCHAR(255) NULL,
    previousname_1_condate DATE NULL,
    previousname_1_companyname VARCHAR(255) NULL,
    previousname_2_condate DATE NULL,
    previousname_2_companyname VARCHAR(255) NULL,
    previousname_3_condate DATE NULL,
    previousname_3_companyname VARCHAR(255) NULL,
    previousname_4_condate DATE NULL,
    previousname_4_companyname VARCHAR(255) NULL,
    previousname_5_condate DATE NULL,
    previousname_5_companyname VARCHAR(255) NULL,
    previousname_6_condate DATE NULL,
    previousname_6_companyname VARCHAR(255) NULL,
    previousname_7_condate DATE NULL,
    previousname_7_companyname VARCHAR(255) NULL,
    previousname_8_condate DATE NULL,
    previousname_8_companyname VARCHAR(255) NULL,
    previousname_9_condate DATE NULL,
    previousname_9_companyname VARCHAR(255) NULL,
    previousname_10_condate DATE NULL,
    previousname_10_companyname VARCHAR(255) NULL,
    confstmtnextduedate DATE NULL,
    confstmtlastmadeupdate DATE NULL
);


CREATE INDEX IF NOT EXISTS companyname_fulltext_idx ON cdata USING GIN (to_tsvector('english', companyname));

CREATE INDEX IF NOT EXISTS cdata_regaddress_postcode_idx ON cdata (regaddress_postcode);

CREATE TABLE cdata_not_active AS
SELECT *
FROM cdata
WHERE companystatus <> 'Active';

DELETE FROM cdata
WHERE companystatus <> 'Active';
