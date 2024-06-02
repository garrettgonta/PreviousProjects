clear all
//set trace on
cd "C:\Users\gonta\Documents\Econ 191"
use "AlabamaData.dta"
append using "AlaskaData.dta", force
append using "ArizonaData.dta", force
append using "ArkansasData.dta", force
append using "CaliforniaData.dta", force
append using "ColoradoData.dta", force
append using "ConnecticutData.dta", force
append using "DelawareData.dta", force
append using "DCData.dta", force
append using "FloridaData.dta", force
append using "GeorgiaData.dta", force
append using "HawaiiData.dta", force
append using "IdahoData.dta", force
append using "IllinoisData.dta", force
append using "IndianaData.dta", force
//No Iowa Data
append using "KansasData.dta", force
append using "KentuckyData.dta", force
append using "LouisianaData.dta", force
append using "MaineData.dta", force
append using "MarylandData.dta", force
append using "MassachusettsData.dta", force
append using "MichiganData.dta", force
append using "MinnesotaData.dta", force
append using "MississippiData.dta", force
append using "MissouriData.dta", force
//No Montana Data
append using "NebraskaData.dta", force
append using "NevadaData.dta", force
append using "NewHampshireData.dta", force
append using "NewJerseyData.dta", force
append using "NewMexicoData.dta", force
append using "NewYorkData.dta", force
append using "NorthCarolinaData.dta", force
append using "NorthDakotaData.dta", force
append using "OhioData.dta", force
//No Data for Oklahoma
append using "OregonData.dta", force
append using "PennsylvaniaData.dta", force
append using "RhodeIslandData.dta", force
append using "SouthCarolinaData.dta", force
append using "SouthDakotaData.dta", force
append using "TennesseeData.dta", force
append using "TexasData.dta", force
append using "UtahData.dta", force
append using "VermontData.dta", force
append using "VirginiaData.dta", force
append using "WashingtonData.dta", force
append using "WestVirginiaData.dta", force
append using "WisconsinData.dta", force
append using "WyomingData.dta", force



tempfile 
cap log close
log using "Econ_190_DataBuilding", text replace

generate int dumVirtual = 0
replace dumVirtual = 1 if learningmodel == "Virtual"
generate int dumHybrid = 0
replace dumHybrid = 1 if learningmodel == "Hybrid"
generate int dumOpen = 0
replace dumOpen = 1 if learningmodel == "In-person"
generate int dumClose = 0
replace dumClose = 1 if learningmodel == "Closed"
generate int dumAnyButOpen = 0
replace dumAnyButOpen = 1 if learningmodel == "Virtual" || learningmodel == "Hybrid" || learningmodel == "Closed"

generate yeardate = date(timeperiodstart, "MD20Y")
format yeardate %td
generate month = month(yeardate)
generate schYear = year(yeardate)
replace schYear = schYear + 1 if month>6

//replace yeardate = date
//replace year = year(yeardate)
//drop if year == 2000

merge m:1 ncesdistrictid using "NCEStoCFIPS.dta"
rename cnty county
keep if _merge==3
collapse dumVirtual dumHybrid dumClose dumOpen dumAnyButOpen, by(county schYear)
sort county

/*drop name
drop opstfips
drop street
drop state
drop zip
drop stfip
drop nmcnty
drop lat
drop lon
drop city
drop nmcbsa
drop csa
drop cbsa
drop nmcsa
drop necta
drop nmnecta
drop cd
drop sldl
drop sldu
drop schoolyear
drop locale
drop pct_city11
drop pct_city12
drop pct_city13
drop pct_sub21
drop pct_sub22
drop pct_sub23
drop pct_town31
drop pct_town32
drop pct_town33
drop pct_rural41
drop pct_rural42
drop pct_rural43
drop cbsatype*/

//drop _merge
merge 1:m county schYear using "dumEnrollDataNoCollapse.dta"
sort county schYear
replace dumVirtual = 0 if dumVirtual ==.
replace dumHybrid = 0 if dumHybrid ==.
replace dumClose = 0 if dumClose ==.
replace dumOpen = 1 if dumOpen ==.
replace dumAnyButOpen = 0 if dumAnyButOpen ==.
drop if _merge==1
//keep if _merge==3
drop if schYear == 2012
drop if schYear==2021 & _merge==2

levelsof county, local(unique_counties)
foreach i in `unique_counties'{
	qui levelsof schYear if county == `i', local(unique_years)
	qui local tempCounter = wordcount("`unique_years'")
	qui drop if `tempCounter' != 11 & county == `i'
}


/*gen int tempCounter = 0
gen int fullyears = 0
foreach i of county {
	replace tempCounter = 0 if county == `i'
	foreach j of schYear{
		replace tempCounter = `tempCounter' + 1 if county == `i'
	}
}
replace fullyears = 1 if tempCounter == 11*/

 
gen int dum2013 = 0
replace dum2013 = 1 if schYear == 2013
gen int dum2014 = 0
replace dum2014 = 1 if schYear == 2014
gen int dum2015 = 0
replace dum2015 = 1 if schYear == 2015
gen int dum2016 = 0
replace dum2016 = 1 if schYear == 2016
gen int dum2017 = 0
replace dum2017 = 1 if schYear == 2017
gen int dum2018 = 0
replace dum2018 = 1 if schYear == 2018
gen int dum2019 = 0
replace dum2019 = 1 if schYear == 2019
gen int dum2020 = 0
replace dum2020 = 1 if schYear == 2020
gen int dum2021 = 0
replace dum2021 = 1 if schYear == 2021
gen int dum2022 = 0
replace dum2022 = 1 if schYear == 2022
gen int dum2023 = 0
replace dum2023 = 1 if schYear == 2023

gen lastYearVirtual = 0
gen lastYearClose = 0
gen lastYearHybrid = 0
gen lastYearOpen = 1
gen lastYearAny = 0

gen dummerVirtual = 0
gen dummerHybrid = 0
gen dummerClose = 0
gen dummerOpen = 0

//This is the year flip
forval i= 1/223924 {
	if dum2021[`i']==1 & dum2022[`i'+1]{
		qui replace lastYearVirtual = dumVirtual[`i'] if schYear == 2022 & county == county[`i']
		qui replace dummerVirtual = dumVirtual[`i'] if county == county[`i']
		qui replace lastYearClose = dumClose[`i'] if schYear == 2022 & county == county[`i']
		qui replace dummerClose = dumClose[`i'] if county == county[`i']
		qui replace lastYearHybrid = dumHybrid[`i'] if schYear == 2022 & county == county[`i']
		qui replace dummerHybrid = dumHybrid[`i'] if county == county[`i']
		qui replace lastYearOpen = dumOpen[`i'] if schYear == 2022 & county == county[`i']
		qui replace dummerOpen = dumOpen[`i'] if county == county[`i']
		qui replace lastYearAny = dumAny[`i'] if schYear == 2022 & county == county[`i']
	}
}
//by county: generate lastYearVirtual = dumVirtual[_n-1]
/*by county: generate lastYearHybrid = dumHybrid[_n-1]
by county: generate lastYearClose = dumClose[_n-1]
by county: generate lastYearOpen = dumOpen[_n-1]
by county: generate lastYearAny = dumAnyButOpen[_n-1]
replace lastYearVirtual = 0 if lastYearVirtual ==.
replace lastYearHybrid = 0 if lastYearHybrid ==.
replace lastYearClose = 0 if lastYearClose ==.
replace lastYearOpen = 0 if lastYearOpen ==.
replace lastYearAny = 0 if lastYearAny ==.
*/

sort county schYear
xtset county
xtreg dumEnroll dumVirtual dumHybrid dumClose dum2013 dum2014 dum2015 dum2016 dum2017 dum2018 dum2019 dum2020 dum2022 dum2023, fe
xtreg dumEnroll dumAnyButOpen dum2013 dum2014 dum2015 dum2016 dum2017 dum2018 dum2019 dum2020 dum2022 dum2023, fe

xtset county
xtreg dumEnroll lastYearVirtual lastYearHybrid lastYearClose dum2013 dum2014 dum2015 dum2016 dum2017 dum2018 dum2019 dum2020 dum2021 dum2023, fe
test lastYearVirtual lastYearHybrid lastYearClose
xtreg dumEnroll lastYearAny dum2013 dum2014 dum2015 dum2016 dum2017 dum2018 dum2019 dum2020 dum2021 dum2023, fe

gen int eventYear = 2021
gen int eventBnA = 0
replace eventBnA = 1 if schYear >=2021

gen timeFrom2021 = schYear - 2021

/*eventdd dumEnroll dumVirtual i.county, timevar(timeFrom2021) ci(rcap) cluster(county) graph_op(ytitle("College Enrollment") legend(label(1 "Enrollment Diff From Baseline") label(2 "Confidence Interval")) ylabel(-0.1(.02)0.1) xlabel(-8(1)2))
eventdd dumEnroll dummerVirtual i.county, timevar(timeFrom2021) ci(rcap) cluster(county) graph_op(ytitle("College Enrollment") legend(label(1 "Enrollment Diff From Baseline") label(2 "Confidence Interval")) ylabel(-0.1(.02)0.1) xlabel(-8(1)2))
eventdd dumEnroll dummerHybrid i.county, timevar(timeFrom2021) ci(rcap) cluster(county) graph_op(ytitle("College Enrollment") legend(label(1 "Enrollment Diff From Baseline") label(2 "Confidence Interval")) ylabel(-0.1(.02)0.1) xlabel(-8(1)2))
eventdd dumEnroll dummerClose i.county, timevar(timeFrom2021) ci(rcap) cluster(county) graph_op(ytitle("College Enrollment") legend(label(1 "Enrollment Diff From Baseline") label(2 "Confidence Interval")) ylabel(-0.1(.02)0.1) xlabel(-8(1)2))*/
//eventdd dumEnroll dumHybrid i.county, timevar(timeFrom2021) ci(rcap) cluster(county) graph_op(ytitle("College Enrollment") legend(label(1 "Enrollment Diff From Baseline") label(2 "Confidence Interval")) ylabel(-0.1(.02)0.1) xlabel(-8(1)2))
//eventdd dumEnroll dumClose i.county, timevar(timeFrom2021) ci(rcap) cluster(county) graph_op(ytitle("College Enrollment") legend(label(1 "Enrollment Diff From Baseline") label(2 "Confidence Interval")) ylabel(-0.1(.02)0.1) xlabel(-8(1)2))



//eventdd dumEnroll dummerVirtual dummerHybrid dummerClose i.county, timevar(timeFrom2021) ci(rcap) cluster(county) graph_op(ytitle("College Enrollment") legend(label(1 "Enrollment Diff From Baseline") label(2 "Confidence Interval")) ylabel(-0.1(.02)0.1) xlabel(-8(1)2))

//eventdd dumEnroll dumVirtual dumHybrid dumClose i.county, timevar(timeFrom2021) ci(rcap) cluster(county) graph_op(ytitle("College Enrollment") legend(label(1 "Enrollment Diff From Baseline") label(2 "Confidence Interval")) ylabel(-0.1(.02)0.1) xlabel(-8(1)2))

//gen tmp=dumVirtual if year==2021
//Egen dumVirtual2021=max(tmp), by(county)
gen yl1virtual=(schYear==2019)*dummerVirtual
label var yl1virtual "2018-2019"
gen yl2virtual=(schYear==2018)*dummerVirtual
label var yl2virtual "2017-2018"
gen yl3virtual=(schYear==2017)*dummerVirtual
label var yl3virtual "2016-2017"
gen yl4virtual=(schYear==2016)*dummerVirtual
label var yl4virtual "2015-2016"
gen yl5virtual=(schYear==2015)*dummerVirtual
label var yl5virtual "2014-2015"
gen yl6virtual=(schYear==2014)*dummerVirtual
label var yl6virtual "2013-2014"
gen yl7virtual=(schYear==2013)*dummerVirtual
label var yl7virtual "2012-2013"

gen ylea0virtual=(schYear==2020)*dummerVirtual
label var ylea0virtual "2019-2020"
gen ylea1virtual=(schYear==2021)*dummerVirtual
label var ylea1virtual "2020-2021"
gen ylea2virtual=(schYear==2022)*dummerVirtual
label var ylea2virtual "2021-2022"
gen ylea3virtual=(schYear==2023)*dummerVirtual
label var ylea3virtual "2022-2023"

gen yl1hybrid=(schYear==2019)*dummerHybrid
label var yl1hybrid "2018-2019"
gen yl2hybrid=(schYear==2018)*dummerHybrid
label var yl2hybrid "2017-2018"
gen yl3hybrid=(schYear==2017)*dummerHybrid
label var yl3hybrid "2016-2017"
gen yl4hybrid=(schYear==2016)*dummerHybrid
label var yl4hybrid "2015-2016"
gen yl5hybrid=(schYear==2015)*dummerHybrid
label var yl5hybrid "2014-2015"
gen yl6hybrid=(schYear==2014)*dummerHybrid
label var yl6hybrid "2013-2014"
gen yl7hybrid=(schYear==2013)*dummerHybrid
label var yl7hybrid "2012-2013"

gen ylea0hybrid=(schYear==2020)*dummerHybrid
label var ylea0hybrid "2019-2020"
gen ylea1hybrid=(schYear==2021)*dummerHybrid
label var ylea1hybrid "2020-2021"
gen ylea2hybrid=(schYear==2022)*dummerHybrid
label var ylea2hybrid "2021-2022"
gen ylea3hybrid=(schYear==2023)*dummerHybrid
label var ylea3hybrid "2022-2023"

gen yl1close=(schYear==2019)*dummerClose
label var yl1close "2018-2019"
gen yl2close=(schYear==2018)*dummerClose
label var yl2close "2017-2018"
gen yl3close=(schYear==2017)*dummerClose
label var yl3close "2016-2017"
gen yl4close=(schYear==2016)*dummerClose
label var yl4close "2015-2016"
gen yl5close=(schYear==2015)*dummerClose
label var yl5close "2014-2015"
gen yl6close=(schYear==2014)*dummerClose
label var yl6close "2013-2014"
gen yl7close=(schYear==2013)*dummerClose
label var yl7close "2012-2013"

gen ylea0close=(schYear==2020)*dummerClose
label var ylea0close "2019-2020"
gen ylea1close=(schYear==2021)*dummerClose
label var ylea1close "2020-2021"
gen ylea2close=(schYear==2022)*dummerClose
label var ylea2close "2021-2022"
gen ylea3close=(schYear==2023)*dummerClose
label var ylea3close "2022-2023"

xtset county
xtreg dumEnroll yl7virtual yl6virtual yl5virtual yl4virtual yl3virtual yl2virtual ylea0virtual ylea1virtual ylea2virtual ylea3virtual yl7hybrid yl6hybrid yl5hybrid yl4hybrid yl3hybrid yl2hybrid ylea0hybrid ylea1hybrid ylea2hybrid ylea3hybrid yl7close yl6close yl5close yl4close yl3close yl2close ylea0close ylea1close ylea2close ylea3close dum2013 dum2014 dum2015 dum2016 dum2017 dum2018 dum2020 dum2021 dum2022 dum2023, fe

test yl7virtual yl6virtual yl5virtual yl4virtual yl3virtual yl2virtual
test ylea0virtual ylea1virtual ylea2virtual ylea3virtual

test yl7hybrid yl6hybrid yl5hybrid yl4hybrid yl3hybrid yl2hybrid
test ylea0hybrid ylea1hybrid ylea2hybrid ylea3hybrid

test yl7close yl6close yl5close yl4close yl3close yl2close
test ylea0close ylea1close ylea2close ylea3close

coefplot, keep(yl7virtual yl6virtual yl5virtual yl4virtual yl3virtual yl2virtual ylea0virtual ylea1virtual ylea2virtual ylea3virtual) xline(0) name(virtual) title("Virtual") ytitle("School Years") xtitle("Difference from Baseline, 2018-2019")

coefplot, keep(yl7hybrid yl6hybrid yl5hybrid yl4hybrid yl3hybrid yl2hybrid ylea0hybrid ylea1hybrid ylea2hybrid ylea3hybrid) xline(0) name(hybrid) title("Hybrid") ytitle("School Years") xtitle("Difference from Baseline, 2018-2019")

coefplot, keep(yl7close yl6close yl5close yl4close yl3close yl2close ylea0close ylea1close ylea2close ylea3close) xline(0) name(closed) title("Closed") ytitle("School Years") xtitle("Difference from Baseline, 2018-2019")

graph combine virtual hybrid closed


//test lastYearVirtual lastYearHybrid lastYearClose

//xtreg enroll yl8Vvirtual


//eventdd dumEnroll dumAnyButOpen i.county, timevar(timeFrom2021) ci(rcap) cluster(county) graph_op(ytitle("College Enrollment") ylabel(-0.01(.001)0.01) xlabel(-8(1)3))
//eventdd dumEnroll dumAnyButOpen i.schYear, timevar(timeFrom2021) ci(rcap) cluster(county) graph_op(ytitle("College Enrollment") ylabel(-0.01(.001)0.01) xlabel(-8(1)3))

//eventdd dumEnroll dumAnyButOpen i.schYear, timevar(timeFrom2021) method(fe, cluster(county)) graph_op(ytitle("College Enrollment") ylabel(-0.1(0.01)0.1) xlabel(-8(1)3))

/*
format yeardate %td

by county: gen datenum=_n
by county: gen target=datenum if yeardate == td(01mar2020)
egen td=min(target), by(county)
drop target
gen dif = datenum-td
by county: gen event_window = 1 if dif>=-2 & dif<=2
egen count_event_obs = count(event_window), by(county)
by county: gen estimation_window=1 if dif<-2 | dif>2
egen count_est_obs=count(estimation_window), by(county)
replace event_window=0 if event_window==.
replace estimation_window=0 if estimation_window==.

tab county if count_event_obs<5
tab county if count_est_obs<30

drop if count_event_obs < 5
drop if count_est_obs < 30

gen predictedEnroll=. 
egen id=group(county)
foreach i in id{
reg dumEnroll dummy_learning if id== `i' & estimation_window==1 
predict p if id==`i' 
replace predictedEnroll = p if id==`i' & event_window==1
drop p
} 
 
sort id yeardate
gen abnormalEnroll=dumEnroll-predictedEnroll if event_window==1
by id: egen cumulative_abnormalEnroll = total(abnormalEnroll)

sort id yeardate
by id: egen ar_sd = sd(abnormalEnroll)
gen test =(1/sqrt(5)) *(cumulative_abnormalEnroll /ar_sd)
list county cumulative_abnormalEnroll test if dif==0 

twoway (sc dumEnroll dummy_learning, mcolor(navy) lcolor(navy) connect(direct)) (sc predictedEnroll dummy_learning, mcolor(maroon) lcolor(maroon) connect(direct)), legend(lab(1 "Foreign") lab(2 "Foreign CI") lab(3 "Domestic") lab(4 "Domestic CI")) xlab(,val)

