*******************************************
* Topic: Diabetes Risk Prediction Dataset *
* Date: Friday, Sept 4 2026               *
*******************************************;

/* Import Data */
PROC import datafile="/home/u64315163/Diabetes_K/Code/diabetes_riskRe.csv"
            out=work.diabetes
            dbms=csv
            replace;
            getnames=yes;

/* Review Dataset Structure */
PROC contents data=work.diabetes;
run;

/* Preview First 10 Observations */
PROC print data=work.diabetes (obs=10);
run;

***********************************************
/* Step 1: Examine Variable Distributions */
***********************************************;
PROC univariate data=work.diabetes normal;
    var
        Age
        BMI
        Blood_Glucose
        Blood_Pressure_Diastolic
        Blood_Pressure_Systolic
        Daily_Walking_Minutes
        Daily_Water_Intake_L
        Diabetes_Risk_Score
        Exercise_Hours_Per_Week
        Fasting_Blood_Sugar
        HDL
        HbA1c
        Heart_Rate
        Height_cm
        Insulin_Level
        LDL
        Sleep_Hours
        Triglycerides
        Waist_Circumference_cm
        Weight_kg
        ;

    histogram / normal;
    qqplot / normal(mu=est sigma=est);
run;

/*
Negative kurtosis indicates a distribution flatter than the normal distribution.
Skewness < 0 indicates left skew; skewness > 0 indicates right skew.
*/

*************************************************
/* Ordinal Glycemic Status Analysis */
*************************************************;
/*
Research Question:
Which demographic, anthropometric, lifestyle, and clinical factors are
independently associated with progressively worse HbA1c-defined
glycemic status?
*/

/*
Ordered Outcome:
1 = Normal
2 = Prediabetes
3 = Diabetes
HbA1c is measured as a percentage.
*/
************************************************
************************************************
/* Analysis Workflow

1. Create and examine Glycemic_Status
2. Describe continuous predictors by Glycemic_Status
3. Describe categorical predictors by Glycemic_Status
4. Check correlations / redundancy among predictors
5. Run unadjusted ordinal logistic regression
6. Assess missing data
7. Build adjusted ordinal logistic regression
8. Create forest plot
9. Conduct sensitivity analysis
*/
************************************************
************************************************;
/* Create labels for the three glycemic categories */
PROC format;
    value gly
        1="Normal"
        2="Prediabetes"
        3="Diabetes"
        ;
run;

/* Create ordinal glycemic-status outcome */
DATA work.diabetes_a;
    set work.diabetes;

    if missing(HbA1c) then Glycemic_Status=.;
    else if HbA1c < 5.7 then Glycemic_Status=1;
    else if HbA1c < 6.5 then Glycemic_Status=2;
    else Glycemic_Status=3;

    format Glycemic_Status gly.;
run;

/* Preview New Outcome Variable */
PROC print data=work.diabetes_a (obs=10);
run;

************************************************
/* 1. Check Glycemic Status Frequency */
************************************************;
PROC freq data=work.diabetes_a;
    tables Glycemic_Status / missing;
run;

***********************************************
/* 2. Describe Continuous Predictors by Glycemic Status */
***********************************************;
PROC means data=work.diabetes_a
    n mean std median q1 q3 min max;

    class Glycemic_Status;

    var
        Age
        BMI
        Waist_Circumference_cm
        Blood_Pressure_Systolic
        Blood_Pressure_Diastolic
        Exercise_Hours_Per_Week
        Daily_Walking_Minutes
        Sleep_Hours
        HDL
        LDL
        Triglycerides
        Heart_Rate
        ;
run;

/*
Primary Continuous Predictors

Age
    - Demographic factor strongly related to diabetes risk.

BMI
    - Measure of overall adiposity.
    - Commonly associated with insulin resistance and diabetes risk.

Waist_Circumference_cm
    - Measure of central/abdominal adiposity.
    - May capture metabolic risk differently from BMI.

Blood_Pressure_Systolic
Blood_Pressure_Diastolic
    - Clinical cardiovascular/metabolic measures.
    - Hypertension frequently co-occurs with diabetes and metabolic syndrome.

Exercise_Hours_Per_Week
Daily_Walking_Minutes
    - Continuous measures of physical activity.
    - Lifestyle factors potentially associated with glycemic status.

Sleep_Hours
    - Lifestyle factor associated with metabolic health and glycemic regulation.

HDL
LDL
Triglycerides
    - Lipid measures related to metabolic and cardiovascular health.

Heart_Rate
    - General clinical/physiologic measure.
    - Included initially for descriptive comparison across glycemic groups.
*/



/*
Secondary / Sensitivity Analysis Variables

HbA1c
Blood_Glucose
Fasting_Blood_Sugar
Diabetes_Risk_Score
Height_cm
Weight_kg
Insulin_Level
Daily_Water_Intake_L
Total_Cholesterol
*/

***********************************************
/* 2A. Test Predictor Differences Across Glycemic Groups */
***********************************************;

PROC glm data=work.diabetes_a;
    class Glycemic_Status;
    /*
    Each continuous variable is treated as an outcome here to compare
    its mean across the three glycemic-status groups.
    */
    model
        Age
        BMI
        Waist_Circumference_cm
        Blood_Pressure_Systolic
        Blood_Pressure_Diastolic
        Exercise_Hours_Per_Week
        Daily_Walking_Minutes
        Sleep_Hours
        HDL
        LDL
        Triglycerides
        Heart_Rate
        = Glycemic_Status
        ;
    /*
    Tukey-adjusted pairwise comparisons and Levene's test
    for homogeneity of variance.
    */
    means Glycemic_Status / tukey hovtest=levene;
run;
quit;

***********************************************
/* 3. Describe Categorical Predictors by Glycemic Status */
***********************************************;

PROC freq data=work.diabetes_a;
    /* Cross-tabulate each categorical predictor with Glycemic_Status */
    tables Glycemic_Status *
        (
        Gender
        Alcohol_Consumption
        BMI_CATEGORY
        Country
        Diet_Quality
        Family_History_Diabetes
        Fatty_Liver
        Heart_Disease
        Hypertension
        Medication_Adherence
        PCOS
        Physical_Activity_Level
        Residence_Type
        Smoking_Status
        Stress_Level
        Sugar_Intake_Level
        Work_Type
        )
        / chisq missing
        ;
run;

***********************************************
/* 4. Check Correlations / Redundancy Among Predictors */
***********************************************;
PROC corr data=work.diabetes_a;
    var
        BMI
        Waist_Circumference_cm
        Blood_Pressure_Systolic
        Blood_Pressure_Diastolic
        Exercise_Hours_Per_Week
        Daily_Walking_Minutes
        Sleep_Hours
        HDL
        LDL
        Triglycerides
        Heart_Rate
        Age
        ;
run;
/*
Pearson correlation output includes:
1. Correlation coefficient (r)
2. p-value
3. Number of observations used

The correlation coefficient ranges from -1 to +1.
*/

***********************************************
/* Save Pearson Correlation Output */
***********************************************;
ods output PearsonCorr=work.corr_r;
PROC corr data=work.diabetes_a;
    var
        BMI
        Waist_Circumference_cm
        Blood_Pressure_Systolic
        Blood_Pressure_Diastolic
        Exercise_Hours_Per_Week
        Daily_Walking_Minutes
        Sleep_Hours
        HDL
        LDL
        Triglycerides
        Heart_Rate
        Age
        ;
run;

***********************************************
/* Identify Strong Pairwise Correlations */
***********************************************;
DATA work.strong_corr;
    set work.corr_r;
    length Var1 Var2 $32;
    /* Correlation coefficients */
    array rvars[*]
        BMI
        Waist_Circumference_cm
        Blood_Pressure_Systolic
        Blood_Pressure_Diastolic
        Exercise_Hours_Per_Week
        Daily_Walking_Minutes
        Sleep_Hours
        HDL
        LDL
        Triglycerides
        Heart_Rate
        Age
        ;
    /* Corresponding p-values */
    array pvars[*]
        PBMI
        PWaist_Circumference_cm
        PBlood_Pressure_Systolic
        PBlood_Pressure_Diastolic
        PExercise_Hours_Per_Week
        PDaily_Walking_Minutes
        PSleep_Hours
        PHDL
        PLDL
        PTriglycerides
        PHeart_Rate
        PAge
        ;
    do i=1 to dim(rvars);
        Var1=Variable;
        Var2=vname(rvars[i]);
        Correlation=rvars[i];
        P_Value=pvars[i];
        /* Report each pair once and flag |r| >= 0.70 */
        if abs(Correlation) >= 0.70 and Var1 < Var2 then output;
end;
    keep Var1 Var2 Correlation P_Value;
run;

PROC print data=work.strong_corr noobs;
run;
/*
P-values are not used to identify redundant predictors because they test
whether a correlation is statistically different from zero rather than
whether the correlation is large enough to be practically important.

With a large sample size, even very small correlations can have small
p-values. For multicollinearity screening, the magnitude of the
correlation is more useful.
 Predictor pairs are therefore flagged using: ABS(Correlation) >= 0.70
ABS() is used because both strong positive and strong negative
correlations can indicate redundancy.
*/

***********************************************
/* 5. Run Unadjusted Ordinal Logistic Regression */
***********************************************;
/*
DESCENDING specifies higher/worse glycemic status as the modeled direction:
Normal -> Prediabetes -> Diabetes
*/

***********************************************
/* Continuous Predictors */
***********************************************;
/* BMI */

PROC logistic data=work.diabetes_a order=internal descending;
    model Glycemic_Status=BMI;
run;

/* Waist Circumference */
PROC logistic data=work.diabetes_a order=internal descending;
    model Glycemic_Status=Waist_Circumference_cm;
run;

/* Age */
PROC logistic data=work.diabetes_a order=internal descending;
    model Glycemic_Status=Age;
run;

/* Systolic Blood Pressure */
PROC logistic data=work.diabetes_a order=internal descending;
    model Glycemic_Status=Blood_Pressure_Systolic;
run;

/* Exercise Hours per Week */
PROC logistic data=work.diabetes_a order=internal descending;
    model Glycemic_Status=Exercise_Hours_Per_Week;
run;

/* Sleep Hours */
PROC logistic data=work.diabetes_a order=internal descending;
    model Glycemic_Status=Sleep_Hours;
run;

/* HDL */
PROC logistic data=work.diabetes_a order=internal descending;
    model Glycemic_Status=HDL;
run;

/* LDL */
PROC logistic data=work.diabetes_a order=internal descending;
    model Glycemic_Status=LDL;
run;

/* Triglycerides */
PROC logistic data=work.diabetes_a order=internal descending;
    model Glycemic_Status=Triglycerides;
run;

/* Heart Rate */
PROC logistic data=work.diabetes_a order=internal descending;
    model Glycemic_Status=Heart_Rate;
run;

***********************************************
/* Categorical Predictors */
***********************************************;
/* Gender */
PROC logistic data=work.diabetes_a order=internal descending;
    class Gender(ref="Male") / param=ref;
    model Glycemic_Status=Gender;
run;

/* Country */
PROC logistic data=work.diabetes_a order=internal descending;
    class Country(ref="United States") / param=ref;
    model Glycemic_Status=Country;
run;

/* Physical Activity Level */
PROC logistic data=work.diabetes_a order=internal descending;
    class Physical_Activity_Level(ref="Low") / param=ref;
    model Glycemic_Status=Physical_Activity_Level;
run;

/* Diet Quality */
PROC logistic data=work.diabetes_a order=internal descending;
    class Diet_Quality(ref="Healthy") / param=ref;
    model Glycemic_Status=Diet_Quality;
run;

/* Sugar Intake Level */
PROC logistic data=work.diabetes_a order=internal descending;
    class Sugar_Intake_Level(ref="Low") / param=ref;
    model Glycemic_Status=Sugar_Intake_Level;
run;

/* Stress Level */
PROC logistic data=work.diabetes_a order=internal descending;
    class Stress_Level(ref="Low") / param=ref;
    model Glycemic_Status=Stress_Level;
run;

/* Smoking Status */

PROC logistic data=work.diabetes_a order=internal descending;
    class Smoking_Status(ref="Never") / param=ref;
    model Glycemic_Status=Smoking_Status;
run;

/* Alcohol Consumption */
PROC logistic data=work.diabetes_a order=internal descending;
    class Alcohol_Consumption(ref="Never") / param=ref;
    model Glycemic_Status=Alcohol_Consumption;
run;

/* Family History of Diabetes */
PROC logistic data=work.diabetes_a order=internal descending;
    class Family_History_Diabetes(ref="No") / param=ref;
    model Glycemic_Status=Family_History_Diabetes;
run;

/* Hypertension */

PROC logistic data=work.diabetes_a order=internal descending;
    class Hypertension(ref="No") / param=ref;
    model Glycemic_Status=Hypertension;
run;

/* Heart Disease */
PROC logistic data=work.diabetes_a order=internal descending;
    class Heart_Disease(ref="No") / param=ref;
    model Glycemic_Status=Heart_Disease;
run;

/* Fatty Liver */
PROC logistic data=work.diabetes_a order=internal descending;
    class Fatty_Liver(ref="No") / param=ref;
    model Glycemic_Status=Fatty_Liver;
run;

/* PCOS */
PROC logistic data=work.diabetes_a order=internal descending;
    class PCOS(ref="No") / param=ref;
    model Glycemic_Status=PCOS;
run;

/* Work Type */
PROC logistic data=work.diabetes_a order=internal descending;
    class Work_Type(ref="Retired") / param=ref;
    model Glycemic_Status=Work_Type;
run;

/* Medication Adherence */
PROC logistic data=work.diabetes_a order=internal descending;
    class Medication_Adherence(ref="Average") / param=ref;
    model Glycemic_Status=Medication_Adherence;
run;

/* Residence Type */
PROC logistic data=work.diabetes_a order=internal descending;
    class Residence_Type(ref="Urban") / param=ref;
    model Glycemic_Status=Residence_Type;
run;

/* Diabetes Risk */
PROC logistic data=work.diabetes_a order=internal descending;
    class Diabetes_Risk(ref="Moderate") / param=ref;
    model Glycemic_Status=Diabetes_Risk;
run;

/* BMI Category */
PROC logistic data=work.diabetes_a order=internal descending;
    class BMI_CATEGORY(ref="Normal") / param=ref;
    model Glycemic_Status=BMI_CATEGORY;
run;

**********************************************
/* 6. Assess Missing Data */
**********************************************;
**********************************************
/* 6A. Missingness in Continuous Variables */
**********************************************;
PROC means data=work.diabetes_a n nmiss;
    var
        Age
        BMI
        Waist_Circumference_cm
        Blood_Pressure_Systolic
        Blood_Pressure_Diastolic
        Exercise_Hours_Per_Week
        Daily_Walking_Minutes
        Sleep_Hours
        HDL
        LDL
        Triglycerides
        Heart_Rate
        ;
run;

**********************************************
/* 6B. Missingness in Categorical Variables */
**********************************************;
PROC freq data=work.diabetes_a;
    tables
        Glycemic_Status
        Gender
        Diet_Quality
        Smoking_Status
        Alcohol_Consumption
        Family_History_Diabetes
        Hypertension
        Heart_Disease
        Fatty_Liver
        Residence_Type
        / missing
        ;
run;

**********************************************
/* 6C. Determine Complete-Case Sample */
**********************************************;
DATA work.missingcheck;
    set work.diabetes_a;
    /* Count missing values among variables required
    for the final adjusted model */
    Number_Missing=cmiss(
        Glycemic_Status,
        Age,
        BMI,
        Waist_Circumference_cm,
        Blood_Pressure_Systolic,
        Blood_Pressure_Diastolic,
        Exercise_Hours_Per_Week,
        Daily_Walking_Minutes,
        Sleep_Hours,
        HDL,
        LDL,
        Triglycerides,
        Heart_Rate,
        Gender,
        Diet_Quality,
        Smoking_Status,
        Alcohol_Consumption,
        Family_History_Diabetes,
        Hypertension,
        Heart_Disease,
        Fatty_Liver,
        Residence_Type
        );
    /* 1 = complete case; 0 = at least one missing model variable */
    Complete_Case=(Number_Missing=0);
run;

PROC print data=work.missingcheck (obs=50);
run;

**********************************************
/* 6D. Compare Complete vs Incomplete Observations */
**********************************************;
/* Continuous Variables */
PROC means data=work.missingcheck
    n mean std median q1 q3;
    class Complete_Case;
    var
        Age
        BMI
        Waist_Circumference_cm
        Blood_Pressure_Systolic
        Blood_Pressure_Diastolic
        Exercise_Hours_Per_Week
        Daily_Walking_Minutes
        Sleep_Hours
        HDL
        LDL
        Triglycerides
        Heart_Rate
        ;
run;

/* Categorical Variables */
PROC freq data=work.missingcheck;
    tables Complete_Case *
        (
        Glycemic_Status
        Gender
        Diet_Quality
        Smoking_Status
        Alcohol_Consumption
        Family_History_Diabetes
        Hypertension
        Heart_Disease
        Fatty_Liver
        Residence_Type
        )
        / missing
        ;
run;

***********************************************
/* 7. Build Adjusted Ordinal Logistic Regression */
***********************************************;
/*
Save parameter estimates and odds ratios from the final model
for reporting and visualization.
*/
ods output
    ParameterEstimates=work.par_estimate
    OddsRatios=work.odds_ratios
    ;
PROC logistic data=work.diabetes_a order=internal descending;
    class
        Gender(ref="Male")
        Diet_Quality(ref="Healthy")
        Smoking_Status(ref="Never")
        Alcohol_Consumption(ref="Never")
        Family_History_Diabetes(ref="No")
        Hypertension(ref="No")
        Heart_Disease(ref="No")
        Fatty_Liver(ref="No")
        Residence_Type(ref="Urban")
        / param=ref
        ;
    model Glycemic_Status=
        Age
        BMI
        Waist_Circumference_cm
        Blood_Pressure_Systolic
        Blood_Pressure_Diastolic
        Exercise_Hours_Per_Week
        Daily_Walking_Minutes
        Sleep_Hours
        HDL
        LDL
        Triglycerides
        Heart_Rate
        Gender
        Diet_Quality
        Smoking_Status
        Alcohol_Consumption
        Family_History_Diabetes
        Hypertension
        Heart_Disease
        Fatty_Liver
        Residence_Type
        / rsquare
        ;
run;

/* Review captured parameter estimates */

PROC print data=work.par_estimate;
run;
/* Review captured adjusted odds ratios */
PROC print data=work.odds_ratios;
run;

***********************************************
/* 8. Forest Plot for Adjusted Model */
***********************************************;
/* Prepare ODS odds-ratio output for plotting */
DATA work.forestplot;
    set work.odds_ratios;
    length Predictor $100;
    Predictor=Effect;
run;

	ods graphics / width=900px height=700px;
PROC sgplot data=work.forestplot noautolegend;
    /* Adjusted ORs with 95% confidence intervals */
    highlow
        y=Predictor
        low=LowerCL
        high=UpperCL
        / type=line
        ;
    scatter
        y=Predictor
        x=OddsRatioEst
        / markerattrs=(symbol=circlefilled size=8)
        ;
    /* OR = 1 indicates no association */
    refline 1 / axis=x
        lineattrs=(pattern=shortdash);
    xaxis label="Adjusted Odds Ratio (95% CI)";
    yaxis
        label=""
        discreteorder=data
        reverse
        ;
    title "Adjusted Odds Ratios for Glycemic Status";
run;
title;

****************************************************
/* 9. Sensitivity Analysis: BMI vs Waist Circumference */
****************************************************;
/*
Model A:
Retain BMI and remove Waist_Circumference_cm.
All other predictors remain unchanged.
*/
PROC logistic data=work.diabetes_a order=internal descending;
    class
        Gender(ref="Male")
        Diet_Quality(ref="Healthy")
        Smoking_Status(ref="Never")
        Alcohol_Consumption(ref="Never")
        Family_History_Diabetes(ref="No")
        Hypertension(ref="No")
        Heart_Disease(ref="No")
        Fatty_Liver(ref="No")
        Residence_Type(ref="Urban")
        / param=ref
        ;
    model Glycemic_Status=
        Age
        BMI
        Blood_Pressure_Systolic
        Blood_Pressure_Diastolic
        Exercise_Hours_Per_Week
        Daily_Walking_Minutes
        Sleep_Hours
        HDL
        LDL
        Triglycerides
        Heart_Rate
        Gender
        Diet_Quality
        Smoking_Status
        Alcohol_Consumption
        Family_History_Diabetes
        Hypertension
        Heart_Disease
        Fatty_Liver
        Residence_Type
        / rsquare
        ;
run;

/*
Model B:
Retain Waist_Circumference_cm and remove BMI.
All other predictors remain unchanged.
*/
PROC logistic data=work.diabetes_a order=internal descending;
    class
        Gender(ref="Male")
        Diet_Quality(ref="Healthy")
        Smoking_Status(ref="Never")
        Alcohol_Consumption(ref="Never")
        Family_History_Diabetes(ref="No")
        Hypertension(ref="No")
        Heart_Disease(ref="No")
        Fatty_Liver(ref="No")
        Residence_Type(ref="Urban")
        / param=ref
        ;
    model Glycemic_Status=
        Age
        Waist_Circumference_cm
        Blood_Pressure_Systolic
        Blood_Pressure_Diastolic
        Exercise_Hours_Per_Week
        Daily_Walking_Minutes
        Sleep_Hours
        HDL
        LDL
        Triglycerides
        Heart_Rate
        Gender
        Diet_Quality
        Smoking_Status
        Alcohol_Consumption
        Family_History_Diabetes
        Hypertension
        Heart_Disease
        Fatty_Liver
        Residence_Type
        / rsquare
        ;
run;

*********************************************
**************** THE END ********************
*********************************************;